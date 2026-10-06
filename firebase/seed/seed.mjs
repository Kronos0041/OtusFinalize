// Загружает демо-данные в Firestore.
//
//   npm install
//   GOOGLE_APPLICATION_CREDENTIALS=./service-account.json npm run seed
//   npm run seed:cli     — использовать существующий вход Firebase CLI
//   npm run seed:dry     — только проверить файлы, без записи
//
// catalog.json используется только администратором для первоначального наполнения Firestore.
// В iOS-приложение он не входит. Категории и товары, которых нет в файле, удаляются.
// Уведомления из notifications.json добавляются/обновляются; остальные документы
// notificationList (например, welcome и catalog) не трогаются.

import { readFile } from 'node:fs/promises';

const PROJECT_ID = 'test-6d334';
const dryRun = process.argv.includes('--dry-run');
const settingsOnly = process.argv.includes('--settings-only');

const readJson = async (relativePath) =>
  JSON.parse(await readFile(new URL(relativePath, import.meta.url), 'utf8'));

const catalog = await readJson('./catalog.json');
const notifications = await readJson('./notifications.json');
const settings = await readJson('./settings.json');

validate(catalog, notifications, settings);
console.log(`Категорий: ${catalog.categories.length}, товаров: ${catalog.products.length}, уведомлений: ${notifications.length}, лимит корзины: ${settings.maximumCartItemQuantity}, повторов картинок: ${settings.imageLoadMaxAttempts}, кэш картинок: ${settings.imageMemoryCacheCapacityMB}/${settings.imageDiskCacheCapacityMB} МБ`);

if (dryRun) {
  console.log(`Dry run: файлы корректны, запись ${settingsOnly ? 'настроек ' : ''}в Firestore не выполнялась.`);
  process.exit(0);
}

const { initializeApp, applicationDefault } = await import('firebase-admin/app');
const { initializeFirestore } = await import('firebase-admin/firestore');

const app = initializeApp({ credential: applicationDefault(), projectId: PROJECT_ID });
// HTTPS работает также в сетях, где gRPC/HTTP2 недоступен.
const db = initializeFirestore(app, { preferRest: true });

if (settingsOnly) {
  await db.collection('settings').doc('store').set(settings);
  console.log(`Готово: настройки магазина загружены в проект ${PROJECT_ID}.`);
  process.exit(0);
}

const batch = db.batch();

await syncCollection('categories', catalog.categories);
await syncCollection('products', catalog.products);

for (const { docId, ...data } of notifications) {
  batch.set(db.collection('notificationList').doc(docId), data);
}
batch.set(db.collection('settings').doc('store'), settings);

await batch.commit();
console.log(`Готово: данные загружены в проект ${PROJECT_ID}.`);

/** Кладёт документы с id из поля `id` и удаляет из коллекции всё, чего нет в файле. */
async function syncCollection(name, items) {
  const collection = db.collection(name);
  const keep = new Set(items.map((item) => item.id));
  const existing = await collection.listDocuments();
  for (const ref of existing) {
    if (!keep.has(ref.id)) batch.delete(ref);
  }
  for (const item of items) {
    batch.set(collection.doc(item.id), item);
  }
}

function validate(catalog, notifications, settings) {
  const errors = [];
  const categoryIds = new Set(catalog.categories.map((c) => c.id));
  const productIds = new Set();

  for (const c of catalog.categories) {
    if (!c.id || !c.title) errors.push(`Категория без id/title: ${JSON.stringify(c)}`);
  }
  for (const p of catalog.products) {
    for (const key of ['id', 'categoryId', 'title', 'imageURL', 'shortDescription', 'description']) {
      if (typeof p[key] !== 'string' || !p[key]) errors.push(`Товар ${p.id ?? '?'}: нет поля ${key}`);
    }
    try {
      const url = new URL(p.imageURL);
      if (url.protocol !== 'https:' || !url.hostname || url.username || url.password) throw new Error();
    } catch {
      errors.push(`Товар ${p.id}: imageURL должен быть корректным HTTPS URL`);
    }
    if ('imageName' in p) errors.push(`Товар ${p.id}: устаревшее поле imageName`);
    if (!Number.isInteger(p.price) || p.price <= 0) errors.push(`Товар ${p.id}: price должен быть целым числом рублей`);
    if (!categoryIds.has(p.categoryId)) errors.push(`Товар ${p.id}: неизвестная категория ${p.categoryId}`);
    if (productIds.has(p.id)) errors.push(`Дубликат id товара: ${p.id}`);
    productIds.add(p.id);
  }
  for (const n of notifications) {
    if (!n.docId || !n.title || !Number.isInteger(n.id)) errors.push(`Уведомление без docId/title/id: ${JSON.stringify(n)}`);
  }
  // Диапазоны совпадают с GetStoreSettingsUseCase в приложении.
  const settingRanges = {
    maximumCartItemQuantity: [1, 999],
    imageLoadMaxAttempts: [0, 10],
    imageMemoryCacheCapacityMB: [1, 512],
    imageDiskCacheCapacityMB: [1, 2048],
  };
  for (const [key, [min, max]] of Object.entries(settingRanges)) {
    const value = settings[key];
    if (!Number.isInteger(value) || value < min || value > max) {
      errors.push(`Настройка ${key} должна быть целым числом от ${min} до ${max}`);
    }
  }
  if (catalog.products.length > 450) errors.push('Слишком много документов для одного batch (лимит 500)');

  if (errors.length) {
    console.error(errors.join('\n'));
    process.exit(1);
  }
}
