# ClothesShop — разбор архитектуры и рефакторинг

Исходники до рефакторинга: `_backup_before_refactor.tar.gz`; состояние после правок команды от 28.09, до второго прохода: `_backup_before_refactor_2.tar.gz` (в git ничего не закоммичено).
Код не собирался (на машине, где делался разбор, нет Xcode) — **перед мержем соберите проект и прогоните сценарии из раздела «Как проверить»**.

## 1. Архитектура (как было)

SwiftUI + «MVVM без правил», Firebase Auth + Firestore через CocoaPods, iOS 15.
С 28.09 зависимости подключаются через SPM (Firebase Apple SDK 12.x), актуальная схема — в разделе 6.

```
ClothesShopApp ──► LoadPreview ─(AuthVM)──► AuthView ──► TabViewContent
                        │  Auth listener: юзер есть ───────►  TabViewContent
                                                                ├─ MainView (MainGrideVM)
                                                                │    ├─ MainTopBar → NotificationView ── Firestore "notificationList"
                                                                │    └─ MainTabView
                                                                │         ├─ CategoryCollectionView (чипы категорий)
                                                                │         └─ CategoryCollectionTab (TabView-страницы)
                                                                │              └─ MainGridView → MainGridCellView → ShopDescriptionView
                                                                └─ ProfileView (MainViewModel) ───────── Firebase Auth
```

Потоки данных:
- **Каталог** — полностью захардкожен в инициализаторе `MainGrideVM` (~170 строк). Раздел «Все» собирался копированием товаров в `onAppear`, лайки хранились в каждой копии и синхронизировались вручную.
- **Авторизация** — `AuthVM` ↔ `NetworkService` (FirebaseAuth). Корневой экран переключается по состоянию сессии: выход, ожидание подтверждения email, подтверждённый вход.
- **Уведомления / профиль** — вью сами ходят в Firebase-сервисы из `onAppear`.

## 2. Слабые места

### Структура
| Проблема | Где |
|---|---|
| Данные каталога внутри ViewModel; SwiftUI `Image` внутри модели | `MainGrideVM`, `MainGrideDateModel` |
| Состояние выбора дублируется: `selected` + `style` в каждой категории; `changeStateItem` игнорирует свои параметры | `MainGrideVM`, `CategoryCollectionTab` |
| Лайки дублируются в «Все» и в категории; синхронизация через `setToggle`, которая полагается на то, что `categoryId == индекс в массиве` | `MainGrideVM.changeLike` |
| Вью сами ходят в Firestore, VM профиля не умеет грузить профиль | `ProfileView`, `NotificationView` |
| Логика валидации e-mail прямо во вью | `AuthView` |
| `ResponseBody` — класс-«конверт» с фиктивным `id` и полем `error`, в котором при успехе лежит «Отлично!» | `NetworkService` |
| `ButtonStyle` затеняет протокол `SwiftUI.ButtonStyle` | `ButtonModel.swift` |
| Имена врут: `singIn` = регистрация, `singUp` = вход; `juliet`; опечатки в файлах/папках (`Utilits`, `Profil`, `MainGride`, `Elemants`, `SearchTextFiled`) | — |
| Мёртвый код: пустой `CategoryCollectionVM.swift`, `ShopDataModels`, `myText()`, `likeIconSize`, 5 неиспользуемых `@State` в `ProfileView`, `showProfile`/`searchText` в `MainView` | — |

### Дублирование
- Размытый фон с обоями — копия в `LoadPreview` и `AuthView`.
- `ButtonView(... frame: (getWidth() - 40, 50))` — 6 раз; `if/else` вокруг двух почти одинаковых кнопок.
- Два одинаковых метода авторизации в `NetworkService`, одинаковый парсинг в `DataBaseService`.
- 18 одинаковых товаров-заглушек, расписанных вручную.
- Одинаковые `tabItem` в `TabViewContent`.

### Производительность
- **Таймер на стартовом экране тикает всю жизнь приложения** и раз в секунду перерисовывает `LoadPreview`, даже когда он перекрыт таб-баром.
- `ForEach(indices, id: \.self)` для товаров — SwiftUI не может нормально диффить.
- `@State` для входных параметров (`ButtonView`, `MainGridView`, `TopBarDescriptionView`…) — лишнее хранилище + вью игнорирует новые значения от родителя (из-за этого в `AuthView` появился `if/else`).
- Лайк мутировал массив `list` целиком → перерисовка всех страниц каталога.
- `NSPredicate` создаётся на каждую проверку e-mail.

### Поддержка
- Force unwrap'ы, которые роняют приложение (`Image(base64String:)!` при пустой картинке профиля, `categoryId!`, `item.id!`).
- `UIScreen.main.bounds` повсюду — ломается на iPad/Split View, deprecated в iOS 16.
- Вложенные `NavigationView` (в `LoadPreview` и в `MainView`), `NavigationLink(isActive:)` deprecated.
- Нет ни одного теста, нет слоя абстракции над Firebase — тестировать нечего подменить.

## 3. Что сделано (поведение не менялось)

| Было | Стало |
|---|---|
| `MainGrideVM` 243 строки | `MainGrideVM` 42 строки + `Models/CatalogSeed.swift` (данные, генератор заглушек) |
| Лайки в каждой копии + ручная синхронизация | `Set<Int>` лайкнутых id — один источник правды |
| `style` хранится в модели категории | Вычисляется: `CategoryCollectionButtonEnum(isSelected:)` |
| `@Binding` в ячейку + `index` для лайка | Ячейка получает значение и `isLiked`, действия — замыканиями |
| `NetworkService` c `ResponseBody` | `register` / `signIn` / `observeAuthState` → `Result<Void, Error>` |
| Парсинг уведомлений внутри сервиса, классы с опционалами | `NotificationItem` — структура с `init(document:)`; идентичность по `documentID` |
| Загрузка профиля во вью | `MainViewModel.loadProfile()` через Firebase Authentication |
| Валидация e-mail во вью | `AuthVM.emailEditingChanged(isEditing:)`, `submit(mode:)` |
| Кортеж `error: (value, state)` | `AuthBanner { message, isVisible }` |
| Копия фона | `View/Elements/BlurredWallpaperBackground.swift` |
| Магические `-40`, `50` | `AppLayout.sideInset`, `buttonHeight`, `fullWidthButton` (дефолт у `ButtonView`) |
| `ButtonStyle` | `ButtonAppearance` |
| `@State` для входных параметров | `let` |
| Таймер логотипа всегда | Работает только пока экран видим |
| `ForEach(indices)` для товаров/уведомлений | `ForEach` по `Identifiable` |

Итого: 2028 → ~1830 строк Swift, добавлено 2 файла (прописаны в `project.pbxproj`).

Намеренные отличия, невидимые пользователю:
- убраны force unwrap'ы — где раньше был краш, теперь просто не рисуется аватар;
- убраны `.onTapGesture { selected = N }` на содержимом вкладок (выставляли уже выбранную вкладку);
- раздел «Все» собирается в `init` VM, а не в `onAppear` (разница видна только в превью).

## 4. Найденные баги

Исправлены командой 28.09: скрытые ошибки входа, неснимаемый слушатель авторизации, двойная навигация после входа, подпись второго поля пароля. `addNotification` удалён: запись с клиента запрещена `firestore.rules`.

Все остальные баги исправлены в третьем проходе (раздел 7).

## 5. Дальнейший план

1. **Переименования через Xcode (Refactor → Rename)** отдельным PR: `MainGrideVM` → `CatalogViewModel`, `MainGrideDateModel` → `Product`, `ShopItemModel` → `CatalogSection`, `CategoryCollectionButtonModel` → `ProductCategory`, `MainViewModel` → `ProfileViewModel`; папки `Utilits` → `Services`, `Profil` → `Profile` и т. д. Удалить пустой `CategoryCollectionVM.swift`.
2. **Протоколы над Firebase** (`AuthServicing`, `CatalogRepository`, `ProfileRepository`) + внедрение через init VM → появится возможность писать unit-тесты на VM.
3. **Навигация:** корневое переключение по состоянию сессии уже есть; дальше — `enum Route` вместо оставшихся булевых флагов и `NavigationStack` при переходе на iOS 16+.
4. ~~Каталог из Firestore/JSON вместо `CatalogSeed`~~ — сделано (раздел 7).
5. Корзина и демо-оформление заказа — схема в разделе 8.
6. Заменить `UIScreen.main` на `GeometryReader`/гибкие фреймы.
7. `async/await` вместо completion-колбэков (Firebase 10 это поддерживает).

## Как проверить

1. Открыть `ClothesShop.xcodeproj`; Xcode загрузит Firebase через Swift Package Manager. Собрать проект.
2. Старт: логотип крутится; «Авторизация»/«Регистрация» открывают нужный режим; «Назад» возвращает.
3. Некорректный e-mail при уходе с поля → красный баннер, тап скрывает. Несовпадающие пароли при регистрации → баннер.
   Регистрация с паролем короче 6 символов → баннер; вход с неверным паролем → текст ошибки Firebase; во время запроса кнопка неактивна и виден спиннер. После входа — таб-бар; при повторном запуске сразу таб-бар.
4. Каталог: чипы и свайп синхронны; лайк в «Все» виден в категории и наоборот; лайк на карточке товара отражается в сетке.
5. Колокольчик → уведомления из Firestore; вкладка «Профиль» подтягивает имя.

## 6. Правки команды от 28.09 и второй проход рефакторинга

Что изменилось в проекте:
- CocoaPods → **SPM**, Firebase Apple SDK **12.x** (FirebaseCore, FirebaseAuth, FirebaseFirestore; FirebaseUI убран). Для Firebase 12 нужен Xcode 16.2+.
- Подключён Firebase-проект `test-6d334`: `.firebaserc`, `firebase.json`, `firestore.rules` (чтение `notificationList` — только вошедшим, запись с клиента запрещена).
- Авторизация: ошибки Firebase показываются в баннере, валидация перед отправкой, `isSubmitting` + спиннер, слушатель снимается в `deinit`, после входа корневой экран переключается по `isSignedIn` — вместо push-переходов.

Актуальная схема входа:
```
ClothesShopApp ──► LoadPreview ── isSignedIn? ──┬─ да ─► TabViewContent (MainView, ProfileView)
                     (AuthVM)                    └─ нет ─► NavigationView: логотип → AuthView
```

Что доработано во втором проходе (поведение не менялось):

| После правок команды | Стало |
|---|---|
| `AuthVM` импортирует FirebaseAuth и сам снимает слушателя в `deinit` | FirebaseAuth — только в `NetworkService`; VM хранит токен `AuthStateObservation`, который снимает слушателя сам |
| `DispatchQueue.main.async` в каждом колбэке VM | `NetworkService` гарантирует главный поток для всех колбэков |
| Цепочка проверок и захардкоженные тексты внутри `submit` | `validationError(for:)` + тексты в `AppErrorService`, минимум длины пароля в `AuthRules` |
| `isSignedIn`, `isSubmitting` изменяемы снаружи | `private(set)` |
| `LoadPreview` сам сбрасывает `banner` и `nextAuth` | `AuthVM.openAuthScreen()` |
| `nextAuth` оставался `true` после входа | Сбрасывается при входе (важно для будущего «Выхода») |
| `.navigationBarHidden(true)` у `TabViewContent` — он больше не внутри `NavigationView` | Удалено |
| Неиспользуемые `checkPassword()`, `addNotification`, `authError`, `regError`, `userNotFindError`, `success` | Удалены |

Firebase теперь импортируют только `ClothesShopApp` и сервисы в `Services/Firebase` — хорошая точка для протоколов из п. 2 плана.

## 7. Третий проход: исправления и демо-данные в Firebase (поведение меняется намеренно)

| Проблема | Решение |
|---|---|
| Бесконечный спиннер в уведомлениях | `NotificationsVM` с состояниями загрузка / список / пусто / ошибка, кнопка «Обновить», обновление свайпом |
| Счётчик уведомлений захардкожен (7) | Бейдж = число непрочитанных; прочитанными считаются уведомления, которые были на экране при уходе с него; id хранятся в `UserDefaults` |
| Мигание стартового экрана у вошедшего пользователя | `AuthVM.sessionState` стартует с `AuthenticationService.sessionState`; `FirebaseApp.configure()` перенесён в `ClothesShopApp.init`, поэтому к созданию `AuthVM` Firebase уже настроен (`AppDelegate` больше не нужен) |
| Тексты «Неправильная пароль», «Chose size», «Заголовок» в шапке товара | «Пароли не совпадают», «Размер», «О товаре» |
| Pull-to-refresh на карточке товара ничего не делал | Убран |
| Нет выхода из аккаунта | Кнопка в профиле → `AuthenticationService.signOut()`; экран входа возвращает слушатель авторизации. При входе очищаются пароли и баннер |
| Каталог захардкожен в Swift, заглушки «название ффыва», «asdf…», нецензурное название товара, фото Montblanc подписаны как Ray-Ban, чемоданы в разделе «Сумка», одна цена «140 ₽» на всё, фото-дубли | Учебные данные Firestore: 4 категории, 21 товар без дублей, описания по фото, цены `Int` в рублях с форматированием, размеры только у часов |
| Каталог только локальный | `FirestoreService.fetchCatalog` читает `categories` + `products`; локальной runtime-копии нет, ошибка отображается на экране с повторной загрузкой |

Данные в Firestore загружает `firebase/seed/seed.mjs` (Admin SDK, инструкция в README). Скрипт валидирует файлы (`npm run seed:dry`) и синхронизирует коллекции. Правила дополнены чтением `categories` и `products`; запись с клиента по-прежнему запрещена.

Модели: `CatalogDTO` / `CategoryDTO` / `ProductDTO` декодируют документы Firestore через `document.data(as:)`; id товаров и категорий строковые (id документов Firestore), перечисление `CategoryName` удалено.

## 8. Покупка: серверная корзина и дальнейший план

Оплата в объём диплома не входит. Корзина уже сохраняется в Firestore; создание документа заказа остаётся дальнейшим этапом. Всё работает на тарифе Spark, Cloud Functions не нужны.

**Данные** (всё под пользователем — правила простые):
```
users/{uid}/cart/{productId_size}   { productId, size, quantity, updatedAt }
settings/store                       { maximumCartItemQuantity }
users/{uid}/orders/{orderId}        { items: [{ productId, title, size, quantity, price }],
                                      total, status: "created", createdAt }
```
- В корзине — только ссылка на товар и количество: название и цена берутся из актуального каталога.
- Максимальное количество одной позиции загружается из `settings/store` и проверяется также правилами Firestore.
- В заказе — снимок позиций с ценой на момент оформления: заказ не должен меняться, если каталог обновится.

**Правила:**
```
match /users/{uid}/{document=**} {
  allow read, write: if request.auth != null && request.auth.uid == uid;
}
```
Для заказа дополнительно проверять `status == "created"` и запрещать `update`/`delete`, чтобы клиент не мог «переписать» историю.

**Клиент:**
- `FirestoreService` + `CartVM` находятся на уровне `TabViewContent`, поэтому корзину видят каталог, карточка и вкладка корзины. При входе каталог, настройки магазина и корзина читаются параллельно одним объединённым сценарием загрузки.
- Карточка товара: выбор размера (обязателен, если `sizes` не пуст) и кнопка «Добавить» → `CartVM.add(product, size)`; добавленная позиция показывает «Добавлено» и удаляется повторным нажатием.
- Третья вкладка «Корзина» с бейджем: позиции, ± количество, удаление, итог через `PriceFormatter`, кнопка «Оформить заказ (демо)».
- Текущее демо-оформление очищает серверную корзину одной `WriteBatch`. Следующий этап — в том же batch создать документ заказа, затем показывать номер заказа и историю в профиле.
- Итог считает клиент. В реальном магазине цену пересчитывал бы сервер (Cloud Function по `products`), но Functions требуют тарифа Blaze. Для диплома это стоит упомянуть как известное ограничение.

## 9. Четвёртый проход: режимы экрана, локализация, ресурсы

Резервная копия перед проходом: `_backup_before_refactor_3.tar.gz`.

### Режим экрана `ViewMode`

`Models/ViewMode.swift` — один enum для всех экранов, которые грузят данные с сервера:

| Режим | Когда | Что видит пользователь |
|---|---|---|
| `.loading` | первая загрузка | спиннер |
| `.content(T)` | сервер прислал данные | контент |
| `.empty` | сервер ответил, данных нет | заглушка «пусто» |
| `.noInternet` | нет сети (`NetworkMonitor`) или ошибка связи от URLSession / Firestore / Auth | заглушка «нет интернета», автоповтор при появлении сети |
| `.error(String)` | сервер вернул ошибку | заглушка с текстом ошибки и «Повторить» |

- `ViewMode.make(from:isEmpty:)` — единое правило разбора `Result`: ViewModel только говорит, что считать пустым.
- `View/Elements/ViewModeView.swift` делает `switch` и рисует заглушки (`StatePlaceholder`), экран передаёт только контент.
- `Services/Network/NetworkMonitor.swift` (`NWPathMonitor`): проверка до запроса нужна, потому что Firestore без сети может вернуть пустой кэш вместо ошибки. Когда сеть вернулась, ViewModel в режимах `.noInternet` / `.error` перезагружается сама.
- Уже показанный контент при неудачном обновлении не заменяется заглушкой.
- Подключено к каталогу (`MainGrideVM`) и уведомлениям (`NotificationsVM`). Профиль — следующим шагом по тому же шаблону.

### Уведомления
- Уведомление становится прочитанным по нажатию (`NotificationsVM.markRead`), а не при уходе с экрана. У непрочитанных синяя точка и жирный заголовок; бейдж на колокольчике считается из них.

### Обновление свайпом
- Каталог: `.refreshable` на сетке товаров. На iOS 15 `ScrollView` его не поддерживает, работает с iOS 16.
- Карточка товара: свайп перезагружает каталог из Firestore, экран берёт свежую версию товара по id (`MainGrideVM.product(id:)`). Работает с iOS 15 (`List`).
- Уведомления: как и раньше.

### Локализация
- `ClothesShop/Localizable.xcstrings` (String Catalog): исходный язык — русский, полный английский перевод. `developmentRegion` = `ru`.
- Ключ — сам русский текст (рекомендация Apple для String Catalog). SwiftUI локализует литералы в `Text`, `Button`, `Section` и т. п. автоматически; `SWIFT_EMIT_LOC_STRINGS = YES` сам добавляет новые строки в каталог при сборке.
- Вне View — `String(localized:)`. Параметры, которые показываются через `Text`, теперь `LocalizedStringKey`: `ButtonModel.title`, заголовок `TopBarDescriptionView`, подписи вкладок.
- Данные с сервера (названия товаров, уведомления, сообщения ошибок) выводятся через `Text(verbatim:)`: они не ключи локализации. Для мультиязычного каталога понадобятся поля по языкам в Firestore.
- Удалены `AppErrorService` (тексты ошибок — прямо в `AuthVM` через `String(localized:)`, отдельный тип не нужен) и `ElemantsTitle`.

### Цвета, картинки, шрифты
- **Цвета** уже лежат в Assets (`AppColor/*.colorset`, со светлой и тёмной темой). `AppColor.swift` стал расширением `Color`: `.appBlack`, `.appGray` и т. д. — ровно те имена, которые Xcode генерирует сам. Генерация (`Color.appBlack` / `ColorResource`) требует iOS 17, а проект — iOS 15, поэтому пока расширение ручное. Чтобы имена не конфликтовали, в проекте выставлено `ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = NO`. При переходе на iOS 17: удалить `AppColor.swift` и включить настройку — вызовы не меняются.
- **Картинки** тоже в Assets; в `AppImage` оставлены только иконки интерфейса. Фото товаров приходят из Firestore по имени.
- **Шрифты** в Assets не кладут: каталог ассетов их не поддерживает, iOS регистрирует шрифты только из бандла через `UIAppFonts`. Сделано: `Font.babylonica(size:)` вместо строки имени, из `Info.plist` убран пустой элемент. Файл `Font/ofont.ru_Miama Nueva 2.ttf` не входит в проект и не используется — его можно удалить.

## 10. VIPER поверх текущего MVVM (ViewModel остаётся)

В SwiftUI отдельный Presenter не нужен: его роль — готовить состояние для View и принимать действия — уже выполняет `ObservableObject`. Поэтому **ViewModel = Presenter**, остальные буквы VIPER добавляются вокруг неё.

| Слой | Отвечает за | Знает о | В проекте сейчас |
|---|---|---|---|
| **View** | Разметка, `switch` по `viewMode`, передача действий в VM | только ViewModel | `MainView`, `NotificationView`… |
| **ViewModel** (Presenter) | Состояние экрана (`ViewMode`, выбор, лайки), реакция на действия | Interactor (протокол), Router (протокол) | `MainGrideVM`, `NotificationsVM` |
| **Interactor** | Сценарии: «загрузить каталог», «отметить прочитанным», «добавить в корзину». Правила без UI | Repository (протоколы) | логика внутри VM |
| **Repository / Service** | Доступ к данным: Firestore, Auth, UserDefaults | Firebase SDK | `FirestoreService`, `AuthenticationService` |
| **Entity** | Модели предметной области | ничего | `ProductDTO`, `NotificationItem`… |
| **Router** | Навигация: открыть товар, уведомления, вход | Builder следующих экранов | флаги `NavigationLink(isActive:)` во View |
| **Builder** (Assembly) | Собирает модуль и внедряет зависимости | всё | `@StateObject private var vm = MainGrideVM()` во View |

### Структура папок

```
ClothesShop/
├── App/                      ClothesShopApp, AppRouter (корень: вход / подтверждение / табы)
├── Core/
│   ├── Network/              NetworkMonitor
│   ├── UI/                   ViewMode, ViewModeView, ButtonView, цвета, шрифты
│   └── Extensions/
├── Data/                     Repository-реализации
│   ├── Firebase/             FirestoreCatalogRepository, FirebaseAuthRepository…
│   └── Local/                ReadNotificationsStore (UserDefaults)
├── Domain/
│   ├── Entities/             Product, Category, NotificationItem, CartItem, Order
│   └── Repositories/         CatalogRepository, NotificationsRepository, AuthRepository (протоколы)
└── Modules/
    ├── Catalog/
    │   ├── CatalogView.swift
    │   ├── CatalogViewModel.swift      // бывший MainGrideVM
    │   ├── CatalogInteractor.swift
    │   ├── CatalogRouter.swift
    │   └── CatalogBuilder.swift
    ├── ProductDetails/
    ├── Notifications/
    ├── Auth/
    ├── Cart/                          // следующий модуль — покупка (раздел 8)
    └── Profile/
```

### Модуль каталога — скелет

```swift
// Domain/Repositories
protocol CatalogRepository {
    func fetchCatalog() async throws -> CatalogDTO
}

// Modules/Catalog/CatalogInteractor.swift
protocol CatalogInteractorProtocol {
    func loadSections() async throws -> [ShopItemModel]
}

final class CatalogInteractor: CatalogInteractorProtocol {
    private let repository: CatalogRepository
    init(repository: CatalogRepository) { self.repository = repository }

    func loadSections() async throws -> [ShopItemModel] {
        ShopItemModel.sections(from: try await repository.fetchCatalog())
    }
}

// Modules/Catalog/CatalogRouter.swift
protocol CatalogRouterProtocol: AnyObject {
    func openProduct(_ product: MainGrideDateModel)
    func openNotifications()
}

// Modules/Catalog/CatalogViewModel.swift — Presenter
@MainActor
final class CatalogViewModel: ObservableObject {
    @Published private(set) var viewMode: ViewMode<[ShopItemModel]> = .loading
    private let interactor: CatalogInteractorProtocol
    private weak var router: CatalogRouterProtocol?

    init(interactor: CatalogInteractorProtocol, router: CatalogRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

    func reload() async {
        do {
            let sections = try await interactor.loadSections()
            viewMode = sections.allSatisfy { $0.product.isEmpty } ? .empty : .content(sections)
        } catch {
            viewMode = error.isConnectivityError ? .noInternet : .error(error.localizedDescription)
        }
    }

    func didSelect(_ product: MainGrideDateModel) { router?.openProduct(product) }
}

// Modules/Catalog/CatalogBuilder.swift
enum CatalogBuilder {
    @MainActor
    static func build(router: CatalogRouterProtocol) -> some View {
        let interactor = CatalogInteractor(repository: FirestoreCatalogRepository())
        return CatalogView(viewModel: CatalogViewModel(interactor: interactor, router: router))
    }
}
```

### Навигация (Router) в SwiftUI на iOS 15
- Router — `ObservableObject` с `@Published var route: CatalogRoute?` (`enum CatalogRoute { case product(MainGrideDateModel), notifications }`). View делает один `NavigationLink(isActive:)` по этому значению, а экран назначения получает от `Builder`.
- Так из View уходят флаги `showDescription`, `openedProduct`, `showNotification`, а переходы можно тестировать без UI.
- С iOS 16 то же самое ложится на `NavigationStack(path:)` почти без изменений.

### Что это даёт
- **Тесты:** Interactor и ViewModel тестируются с фейковым `CatalogRepository`, без Firebase.
- **Моки для защиты:** `MockCatalogRepository` показывает все режимы (`noInternet`, `empty`, `error`) без реальной сети.
- **Порядок миграции** — по одному модулю, начиная с каталога: протокол Repository → Interactor → Router → Builder. `ViewMode` и `ViewModeView` уже готовы и переносятся как есть.
