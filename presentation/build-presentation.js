const pptxgen = require("pptxgenjs");
const OUT = process.argv[2];
const ASSETS = process.env.ASSETS || require("path").join(__dirname, "assets");
const pres = new pptxgen();
pres.layout = "LAYOUT_16x9"; // 10 x 5.625
pres.title = "ClothesShop — дипломная работа";

const INK = "15130F", GOLD = "B08D57", PAPER = "FFFFFF", MIST = "F2F0EC", GREY = "6B665F", LINE = "D9D4CB", DARKCARD = "26221C";
const HEAD = "Arial", BODY = "Arial";

let n = 0;
function slide(title, opts = {}) {
  const s = pres.addSlide();
  n++;
  s.background = { color: opts.dark ? INK : PAPER };
  if (title) {
    s.addText(title, { x: 0.5, y: 0.3, w: 9, h: 0.7, fontFace: HEAD, fontSize: 26, bold: true,
      color: opts.dark ? PAPER : INK, margin: 0, valign: "middle", isTextBox: true });
  }
  s.addText(String(n), { x: 9.0, y: 5.2, w: 0.5, h: 0.25, fontFace: BODY, fontSize: 10,
    color: opts.dark ? "9A9488" : GREY, align: "right", margin: 0, isTextBox: true });
  return s;
}
function box(s, x, y, w, h, o = {}) {
  const shape = o.round === false ? pres.ShapeType.rect : pres.ShapeType.roundRect;
  const opt = { x, y, w, h, fill: { color: o.fill || MIST },
    line: o.line ? { color: o.line, width: o.lw || 1, dashType: o.dash } : { type: "none" } };
  if (o.round !== false) opt.rectRadius = o.r || 0.08;
  s.addShape(shape, opt);
  if (o.text !== undefined) {
    s.addText(o.text, { x: x + 0.05, y, w: w - 0.1, h, fontFace: o.font || BODY, fontSize: o.size || 13,
      bold: !!o.bold, color: o.color || INK, align: o.align || "center", valign: o.valign || "middle",
      margin: 2, isTextBox: true, fit: "shrink" });
  }
}
function arrow(s, x1, y1, x2, y2, o = {}) {
  s.addShape(pres.ShapeType.line, { x: Math.min(x1, x2), y: Math.min(y1, y2), w: Math.abs(x2 - x1), h: Math.abs(y2 - y1),
    flipH: x2 < x1, flipV: y2 < y1,
    line: { color: o.color || GOLD, width: o.w || 1.75, endArrowType: o.both ? undefined : "triangle",
      beginArrowType: o.both ? "triangle" : undefined, dashType: o.dash } });
  if (o.both) s.addShape(pres.ShapeType.line, { x: Math.min(x1, x2), y: Math.min(y1, y2), w: Math.abs(x2 - x1), h: Math.abs(y2 - y1),
    flipH: x2 < x1, flipV: y2 < y1, line: { color: o.color || GOLD, width: o.w || 1.75, endArrowType: "triangle" } });
}
function label(s, text, x, y, w, o = {}) {
  s.addText(text, { x, y, w, h: o.h || 0.3, fontFace: o.font || BODY, fontSize: o.size || 12, color: o.color || GREY,
    bold: !!o.bold, italic: !!o.italic, align: o.align || "left", valign: o.valign || "middle", margin: 0, isTextBox: true });
}
function code(s, x, y, w, h, text, size = 11) {
  s.addShape(pres.ShapeType.roundRect, { x, y, w, h, rectRadius: 0.08, fill: { color: INK }, line: { type: "none" } });
  s.addText(text, { x: x + 0.15, y: y + 0.08, w: w - 0.3, h: h - 0.16, fontFace: "Courier New", fontSize: size,
    color: "E8E2D6", valign: "top", margin: 0, isTextBox: true });
}
function card(s, x, y, w, h, num, head, body) {
  box(s, x, y, w, h, { fill: MIST });
  s.addShape(pres.ShapeType.ellipse, { x: x + 0.2, y: y + 0.2, w: 0.45, h: 0.45, fill: { color: INK }, line: { type: "none" } });
  s.addText(String(num), { x: x + 0.2, y: y + 0.2, w: 0.45, h: 0.45, fontFace: HEAD, fontSize: 16, bold: true, color: GOLD, align: "center", valign: "middle", margin: 0, isTextBox: true });
  s.addText(head, { x: x + 0.8, y: y + 0.15, w: w - 1.0, h: 0.55, fontFace: HEAD, fontSize: 16, bold: true, color: INK, valign: "middle", margin: 0, isTextBox: true });
  s.addText(body, { x: x + 0.2, y: y + 0.8, w: w - 0.4, h: h - 0.9, fontFace: BODY, fontSize: 14, color: GREY, valign: "top", margin: 0, isTextBox: true });
}


// 1 ─ Титул
{
  const s = slide(null, { dark: true });
  s.addText("ClothesShop", { x: 0.7, y: 1.5, w: 8.6, h: 1.2, fontFace: HEAD, fontSize: 60, bold: true, color: PAPER, margin: 0, isTextBox: true });
  s.addText("Концепт мобильного приложения для бренда Montblanc: каталог, избранное, корзина и покупка под одним аккаунтом", { x: 0.7, y: 2.75, w: 6.2, h: 1.2, fontFace: BODY, fontSize: 20, color: "CFC8BA", margin: 0, valign: "top", isTextBox: true });
  s.addText("Дипломная работа  ·  OTUS iOS", { x: 0.7, y: 4.2, w: 6, h: 0.35, fontFace: BODY, fontSize: 16, color: GOLD, margin: 0, isTextBox: true });
  s.addText("Автор: Alex Rimain", { x: 0.7, y: 4.55, w: 6, h: 0.35, fontFace: BODY, fontSize: 14, color: "9A9488", margin: 0, isTextBox: true });
  ["Swift", "SwiftUI", "Clean Architecture", "Firebase"].forEach((t, i) => box(s, 7.2, 2.2 + i * 0.55, 2.2, 0.42, { fill: DARKCARD, line: GOLD, text: t, color: GOLD, size: 14, r: 0.2 }));
  s.addNotes("Представиться, назвать тему. Проект задуман как демо для бренда Montblanc: у бренда нет собственного мобильного приложения, я выступаю в роли заказчика и предлагаю готовое решение.");
}

// 2 ─ Цель
{
  const s = slide("Цель проекта");
  s.addText("Создать приложение под бренд Montblanc, показать демо бренду и проверить, возможна ли сделка", { x: 0.5, y: 1.1, w: 9, h: 0.9, fontFace: BODY, fontSize: 18, color: INK, margin: 0, valign: "top", isTextBox: true });
  const items = [
    ["Создать продукт", "Рабочее демо: каталог, избранное, корзина и покупка под аккаунтом"],
    ["Показать бренду", "Продемонстрировать приложение в фирменном стиле Montblanc"],
    ["Увидеть реакцию", "Понять, как бренд оценит проект и заинтересует ли его решение"],
    ["Выйти на сделку", "От передачи кода до совместного развития продукта"],
  ];
  items.forEach((it, i) => card(s, 0.5 + (i % 2) * 4.6, 2.15 + Math.floor(i / 2) * 1.5, 4.4, 1.35, i + 1, it[0], it[1]));
  s.addNotes("Цель не только техническая, но и продуктовая: проверить интерес бренда. Поэтому приложение сделано так, чтобы его можно было передать или развивать дальше — отсюда Clean Architecture и заменяемый бэкенд.");
}

// 3 ─ Вдохновление
{
  const s = slide("Вдохновление");
  const cols = [
    ["Премиум-бренды", "Montblanc: сдержанная палитра «чёрный, белый, золото», засечные шрифты, много воздуха вокруг товара", "M"],
    ["Маркетплейсы", "Сетка карточек, чипы категорий, быстрый поиск, избранное и корзина с бейджем — привычные сценарии покупателя", "★"],
  ];
  cols.forEach((c, i) => {
    const x = 0.5 + i * 4.6;
    box(s, x, 1.3, 4.4, 3.5, { fill: i === 0 ? INK : MIST });
    if (i === 0) {
      s.addText(c[2], { x: x + 0.35, y: 1.5, w: 1.0, h: 0.9, fontFace: HEAD, fontSize: 44, color: GOLD, margin: 0, isTextBox: true });
    } else {
      s.addImage({ path: ASSETS + "/ozon-logo.png", x: x + 0.35, y: 1.75, w: 1.4, h: 0.306, altText: "Логотип Ozon" });
      s.addImage({ path: ASSETS + "/wildberries-logo.png", x: x + 2.05, y: 1.77, w: 2.0, h: 0.302, altText: "Логотип Wildberries" });
    }
    s.addText(c[0], { x: x + 0.35, y: 2.55, w: 3.7, h: 0.5, fontFace: HEAD, fontSize: 20, bold: true, color: i === 0 ? PAPER : INK, margin: 0, valign: "middle", isTextBox: true });
    s.addText(c[1], { x: x + 0.35, y: 3.15, w: 3.7, h: 1.5, fontFace: BODY, fontSize: 15, color: i === 0 ? "CFC8BA" : GREY, margin: 0, valign: "top", isTextBox: true });
  });
  s.addNotes("Здесь можно добавить собственные референсы и скриншоты. Стиль приложения — по мотивам Montblanc: брендовый логотип и шрифты Babylonica / Dancing Script.");
}

// 3b ─ Сайт Montblanc: десктоп
{
  const s = slide("Сайт Montblanc: десктопная версия");
  const shots = [["desk-home", "Главная"], ["desk-list", "Каталог раздела"], ["desk-product", "Карточка товара"]];
  shots.forEach((t, i) => {
    const x = 0.5 + i * 3.1, w = 2.8, h = 1.75;
    box(s, x, 1.2, w + 0.1, h + 0.1, { fill: PAPER, line: LINE, round: false });
    s.addImage({ path: ASSETS + "/montblanc-" + t[0] + ".jpg", x: x + 0.05, y: 1.25, w, h, altText: "Скриншот montblanc.com: " + t[1] });
    s.addText(t[1], { x, y: 3.1, w: w + 0.1, h: 0.3, fontFace: BODY, fontSize: 13, bold: true, color: INK, margin: 0, isTextBox: true });
  });
  const pts = [
    ["Каталог по категориям", "Меню разделов, сетка товаров, фильтр и сортировка"],
    ["Карточка товара", "Выбор размера, кнопка Add To Cart, избранное"],
    ["Всё в шапке", "Поиск, вход, избранное и корзина всегда под рукой"],
  ];
  pts.forEach((t, i) => {
    const x = 0.5 + i * 3.1;
    box(s, x, 3.55, 2.9, 1.2, { fill: MIST });
    s.addText(t[0], { x: x + 0.15, y: 3.63, w: 2.6, h: 0.35, fontFace: HEAD, fontSize: 14, bold: true, color: INK, margin: 0, valign: "middle", isTextBox: true });
    s.addText(t[1], { x: x + 0.15, y: 4.0, w: 2.6, h: 0.7, fontFace: BODY, fontSize: 12, color: GREY, margin: 0, valign: "top", isTextBox: true });
  });
  label(s, "Источник: montblanc.com (en-us), скриншоты автора", 0.5, 4.88, 8, { size: 10 });
  s.addNotes("Так выглядит официальный сайт Montblanc на десктопе: главная с коллекцией, раздел каталога с сеткой товаров и карточка товара с выбором размера и кнопкой «Add To Cart». Именно эти сценарии — каталог, карточка, размер, корзина, избранное — перенесены в мобильное приложение.");
}

// 3c ─ Сайт Montblanc: мобильная версия
{
  const s = slide("Сайт Montblanc на телефоне");
  const shots = [["mob-home", "Главная"], ["mob-list", "Каталог"], ["mob-product", "Товар"]];
  shots.forEach((t, i) => {
    const x = 0.5 + i * 1.95, w = 1.62, h = 3.5;
    box(s, x, 1.15, w + 0.16, h + 0.16, { fill: INK, r: 0.14 });
    s.addImage({ path: ASSETS + "/montblanc-" + t[0] + ".jpg", x: x + 0.08, y: 1.23, w, h, altText: "Мобильная версия montblanc.com: " + t[1] });
    s.addText(t[1], { x, y: 4.85, w: w + 0.16, h: 0.25, fontFace: BODY, fontSize: 12, bold: true, color: INK, align: "center", margin: 0, isTextBox: true });
  });
  box(s, 6.5, 1.15, 3.0, 3.66, { fill: MIST });
  label(s, "Что видно на мобильной версии", 6.7, 1.25, 2.6, { size: 14, bold: true, color: INK, font: HEAD, h: 0.55 });
  s.addText([
    { text: "Это адаптивный сайт, а не отдельное приложение", options: { bullet: true, breakLine: true } },
    { text: "Меню, поиск и корзина собраны в шапке", options: { bullet: true, breakLine: true } },
    { text: "Сетка в два столбца, как у нас в каталоге", options: { bullet: true, breakLine: true } },
    { text: "Карточка: размер, корзина, избранное", options: { bullet: true } },
  ], { x: 6.7, y: 1.9, w: 2.65, h: 2.8, fontFace: BODY, fontSize: 12, color: INK, valign: "top", margin: 0, paraSpaceAfter: 8, isTextBox: true });
  label(s, "Источник: montblanc.com (en-us), мобильный режим, скриншоты автора", 0.5, 5.12, 8, { size: 10 });
  s.addNotes("Мобильная версия сайта Montblanc, снятая в режиме смартфона: адаптивная веб-страница с поиском, меню и корзиной в шапке. Приложение для покупок бренд не предлагает, поэтому мы переносим те же сценарии в нативный формат.");
}

// 3d ─ Путь покупки на сайте: десктоп
{
  const s = slide("Покупка на сайте Montblanc: десктоп");
  const steps = [["desk-1", "1. Выбор размера"], ["desk-2", "2. Add To Cart"], ["desk-3", "3. Корзина"], ["desk-4", "4. Оформление"]];
  const imgs = ["1-size", "2-added", "3-cart", "4-checkout"];
  steps.forEach((t, i) => {
    const x = 0.5 + (i % 2) * 2.85, y = 1.1 + Math.floor(i / 2) * 2.0, w = 2.6, h = 1.625;
    box(s, x - 0.03, y - 0.03, w + 0.06, h + 0.06, { fill: PAPER, line: LINE, round: false });
    s.addImage({ path: ASSETS + "/montblanc-flow-desk-" + imgs[i] + ".jpg", x, y, w, h, altText: "Скриншот montblanc.com: " + t[1] });
    s.addText(t[1], { x, y: y + h + 0.07, w, h: 0.25, fontFace: BODY, fontSize: 12, bold: true, color: INK, margin: 0, isTextBox: true });
  });
  box(s, 6.3, 1.1, 3.2, 3.85, { fill: MIST });
  label(s, "Путь покупателя", 6.5, 1.2, 2.8, { size: 15, bold: true, color: INK, font: HEAD, h: 0.4 });
  s.addText([
    { text: "Выбрать размер в карточке товара", options: { bullet: { type: "number" }, breakLine: true } },
    { text: "Add To Cart: всплывающее окно «Added to your bag»", options: { bullet: { type: "number" }, breakLine: true } },
    { text: "Корзина: состав, подытог, Proceed To Order", options: { bullet: { type: "number" }, breakLine: true } },
    { text: "Оформление в три шага: Personal details, Shipping, Payment", options: { bullet: { type: "number" } } },
  ], { x: 6.5, y: 1.7, w: 2.8, h: 2.3, fontFace: BODY, fontSize: 12, color: INK, valign: "top", margin: 0, paraSpaceAfter: 6, isTextBox: true });
  box(s, 6.5, 4.05, 2.8, 0.75, { fill: PAPER, text: "Заказ не оформлялся: остановились на первом шаге, данные не вводились", size: 11, align: "left" });
  label(s, "Источник: montblanc.com (en-us), скриншоты автора", 0.5, 5.12, 6, { size: 10 });
  s.addNotes("Путь покупки на сайте Montblanc: выбор размера, добавление в корзину, окно подтверждения, корзина и первый шаг оформления (почта, доставка, оплата). Заказ не оформлялся, данные не вводились. Этот сценарий — образец для корзины и демо-покупки в нашем приложении.");
}

// 3e ─ Путь покупки на сайте: телефон
{
  const s = slide("Покупка на сайте Montblanc: телефон");
  const steps = [["1-size", "1. Размер"], ["2-added", "2. В корзину"], ["3-cart", "3. Корзина"], ["4-checkout", "4. Оформление"]];
  steps.forEach((t, i) => {
    const x = 0.5 + i * 1.75, w = 1.43, h = 3.1;
    box(s, x, 1.1, w + 0.16, h + 0.16, { fill: INK, r: 0.12 });
    s.addImage({ path: ASSETS + "/montblanc-flow-mob-" + t[0] + ".jpg", x: x + 0.08, y: 1.18, w, h, altText: "Мобильная версия montblanc.com: " + t[1] });
    s.addText(t[1], { x, y: 4.45, w: w + 0.16, h: 0.3, fontFace: BODY, fontSize: 12, bold: true, color: INK, align: "center", margin: 0, isTextBox: true });
  });
  box(s, 7.55, 1.1, 1.95, 3.66, { fill: MIST });
  s.addText("Те же четыре шага, но в один столбец: кнопки на всю ширину, на шаге оформления итог закреплён внизу", { x: 7.7, y: 1.25, w: 1.65, h: 3.4, fontFace: BODY, fontSize: 12, color: INK, margin: 0, valign: "top", isTextBox: true });
  label(s, "Источник: montblanc.com (en-us), мобильный режим, скриншоты автора. Заказ не оформлялся.", 0.5, 4.95, 9, { size: 10 });
  s.addNotes("Тот же путь на мобильной версии сайта: размер, добавление в корзину, корзина и первый шаг оформления. Это ориентир для UX нашего приложения.");
}

// 4 ─ Проблема
{
  const s = slide("Какую проблему решаем");
  box(s, 0.5, 1.15, 4.2, 1.65, { fill: INK });
  label(s, "ПРОБЛЕМА", 0.7, 1.25, 3.8, { size: 12, bold: true, color: GOLD });
  s.addText("У Montblanc нет собственного мобильного приложения", { x: 0.7, y: 1.6, w: 3.8, h: 1.1, fontFace: HEAD, fontSize: 18, bold: true, color: PAPER, margin: 0, valign: "top", isTextBox: true });
  arrow(s, 4.75, 1.97, 5.25, 1.97);
  box(s, 5.3, 1.15, 4.2, 1.65, { fill: GOLD });
  label(s, "РЕШЕНИЕ", 5.5, 1.25, 3.8, { size: 12, bold: true, color: INK });
  s.addText("Готовое приложение и коммерческое предложение: я выступаю заказчиком и предлагаю бренду готовый продукт", { x: 5.5, y: 1.6, w: 3.8, h: 1.1, fontFace: BODY, fontSize: 14, bold: true, color: INK, margin: 0, valign: "top", isTextBox: true });
  const v = [
    ["Готов к показу", "Каталог, избранное, корзина и покупка в одном аккаунте"],
    ["Фирменный стиль", "Палитра, шрифты и логотип бренда"],
    ["Любой бэкенд", "Clean Architecture: Firebase можно заменить на сервер бренда"],
  ];
  v.forEach((t, i) => {
    const x = 0.5 + i * 3.05;
    box(s, x, 3.1, 2.9, 1.7, { fill: MIST });
    s.addText(t[0], { x: x + 0.2, y: 3.2, w: 2.5, h: 0.5, fontFace: HEAD, fontSize: 16, bold: true, color: INK, margin: 0, valign: "middle", isTextBox: true });
    s.addText(t[1], { x: x + 0.2, y: 3.75, w: 2.5, h: 0.95, fontFace: BODY, fontSize: 14, color: GREY, margin: 0, valign: "top", isTextBox: true });
  });
  s.addNotes("Главный аргумент для бренда: не идея на бумаге, а работающее приложение. Формат сделки открыт: от передачи кода до совместной доработки.");
}

// 5 ─ Что умеет
{
  const s = slide("Что умеет приложение");
  box(s, 0.5, 1.15, 9, 3.75, { fill: PAPER, line: GOLD, lw: 1.5, dash: "dash", r: 0.12 });
  label(s, "Всё работает под одним слоем авторизации: аккаунт Firebase + подтверждение email", 0.7, 1.22, 8.6, { size: 14, bold: true, color: GOLD });
  const f = [
    ["Просмотр товаров", "Категории, поиск, карточка с фото, ценой и размерами"],
    ["Избранное", "Лайк в каталоге и на карточке, общий список избранного"],
    ["Корзина", "Размеры, количество, итог; хранится в аккаунте"],
    ["Покупка", "Оформление заказа в демо-режиме, без реальной оплаты"],
  ];
  f.forEach((t, i) => {
    const x = 0.7 + i * 2.2;
    box(s, x, 1.75, 2.0, 2.3, { fill: i === 3 ? INK : MIST });
    s.addText(t[0], { x: x + 0.15, y: 1.88, w: 1.7, h: 0.6, fontFace: HEAD, fontSize: 17, bold: true, color: i === 3 ? GOLD : INK, margin: 0, valign: "middle", isTextBox: true });
    s.addText(t[1], { x: x + 0.15, y: 2.55, w: 1.7, h: 1.4, fontFace: BODY, fontSize: 14, color: i === 3 ? "E8E2D6" : GREY, margin: 0, valign: "top", isTextBox: true });
  });
  label(s, "Дополнительно: профиль, смена пароля и email, уведомления, RU / EN, светлая и тёмная темы", 0.7, 4.3, 8.6, { size: 13 });
  s.addNotes("Здесь удобно показать живую демонстрацию в симуляторе. Покупка — демо-оформление: платёжная интеграция в объём диплома не входит.");
}

// 6 ─ Clean Architecture
{
  const s = slide("Архитектура: Clean Architecture");
  const cols = [
    ["UI", "SwiftUI Views, компоненты, DesignSystem, навигация", INK, PAPER],
    ["Presentation", "ViewModel, UI-модели, ViewMode, Router (push / pop), валидаторы", "3A332A", PAPER],
    ["Domain", "Entities, UseCases, протоколы репозиториев", GOLD, INK],
    ["Data", "Репозитории, DTO, Mapper, протоколы DataSource", MIST, INK],
    ["Infrastructure", "Firebase, UserDefaults, URLCache, NWPathMonitor", MIST, INK],
  ];
  cols.forEach((c, i) => {
    const x = 0.5 + i * 1.85;
    box(s, x, 1.15, 1.6, 0.6, { fill: c[2], color: c[3], text: c[0], size: 14, bold: true, font: HEAD });
    box(s, x, 1.85, 1.6, 1.5, { fill: i === 2 ? "F1E6D2" : MIST });
    s.addText(c[1], { x: x + 0.1, y: 1.95, w: 1.4, h: 1.35, fontFace: BODY, fontSize: 12, color: INK, margin: 0, valign: "top", isTextBox: true });
  });
  arrow(s, 2.12, 1.45, 2.33, 1.45, { w: 1.5 });
  arrow(s, 3.97, 1.45, 4.18, 1.45, { w: 1.5 });
  arrow(s, 6.03, 1.45, 5.82, 1.45, { w: 1.5 });
  arrow(s, 7.88, 1.45, 7.67, 1.45, { w: 1.5 });
  box(s, 0.5, 3.85, 9, 0.5, { fill: PAPER, line: GOLD, dash: "dash", text: "App · DI: AppDIContainer — единственное место, где протоколы связываются с реализациями", size: 12 });
  s.addText("Зависимости направлены внутрь, к Domain. В Domain и Data нет импортов Firebase и SwiftUI.", { x: 0.5, y: 4.45, w: 9, h: 0.5, fontFace: BODY, fontSize: 13, bold: true, color: INK, margin: 0, valign: "middle", isTextBox: true });
  s.addNotes("Domain — бизнес-логика без знания о Firebase и UI. Data преобразует данные и реализует репозитории. Infrastructure — конкретные технологии. Проверено по коду: ни одного импорта Firebase в Domain, Data, Presentation и UI.");
}

// 7 ─ Вертикальный срез
{
  const s = slide("Как проходит запрос: загрузка каталога");
  const w = 2.0, g = 0.33;
  const xs = [0, 1, 2, 3].map(i => 0.5 + i * (w + g));
  const r1 = [["UI", "CatalogView", MIST, INK], ["Presentation", "CatalogViewModel", MIST, INK], ["Domain", "GetCatalogUseCase", GOLD, INK], ["Domain", "CatalogRepository Protocol", GOLD, INK]];
  r1.forEach((b, i) => {
    label(s, b[0], xs[i], 1.1, w, { size: 11, bold: true, color: GREY });
    box(s, xs[i], 1.4, w, 0.8, { fill: b[2], color: b[3], text: b[1], size: 12, bold: true });
    if (i < 3) arrow(s, xs[i] + w + 0.02, 1.8, xs[i + 1] - 0.02, 1.8);
  });
  label(s, "реализует", xs[3] + 0.02, 2.3, 0.9, { size: 11, align: "right", h: 0.25 });
  arrow(s, xs[3] + w / 2, 2.22, xs[3] + w / 2, 2.78);
  const r2 = [["Infrastructure", "Cloud Firestore", INK, PAPER], ["Infrastructure", "FirestoreCatalog DataSourceImpl", MIST, INK], ["Data", "CatalogRepository Impl", MIST, INK]];
  r2.forEach((b, i) => {
    const x = xs[i + 1];
    label(s, b[0], x, 2.5, w, { size: 11, bold: true, color: GREY });
    box(s, x, 2.8, w, 0.8, { fill: b[2], color: b[3], text: b[1], size: 12, bold: true });
  });
  arrow(s, xs[3] - 0.02, 3.2, xs[2] + w + 0.02, 3.2);
  arrow(s, xs[2] - 0.02, 3.2, xs[1] + w + 0.02, 3.2);
  // блок подмены DataSource после сделки
  box(s, xs[0], 2.8, w, 0.8, { fill: PAPER, line: GOLD, lw: 1.5, text: "При сделке меняем только DataSource", size: 12, bold: true, color: INK });
  arrow(s, xs[2] + w / 2, 3.64, xs[2] + w / 2, 3.86, { both: true, w: 1.5 });
  box(s, xs[2], 3.88, w, 0.55, { fill: PAPER, line: GOLD, lw: 1.5, dash: "dash", text: "RESTCatalogDataSourceImpl", size: 11, bold: true });
  arrow(s, xs[2] - 0.02, 4.15, xs[1] + w + 0.02, 4.15, { dash: "dash" });
  box(s, xs[1], 3.88, w, 0.55, { fill: PAPER, line: GOLD, lw: 1.5, dash: "dash", text: "Бэкенд Montblanc (REST API)", size: 11, bold: true });
  label(s, "после сделки", xs[3], 3.98, w, { size: 12, bold: true, color: GOLD });
  label(s, "Ответ идёт обратно по цепочке преобразований", 0.5, 4.5, 9, { size: 12, bold: true, color: GREY });
  ["Документ", "ProductDTO", "ProductMapper", "Product", "UI-модель", "View"].forEach((t, i) => {
    const x = 0.5 + i * 1.5;
    box(s, x, 4.8, 1.3, 0.42, { fill: i === 3 ? GOLD : MIST, text: t, size: 12, bold: i === 3 });
    if (i < 5) arrow(s, x + 1.32, 5.01, x + 1.48, 5.01, { w: 1.25 });
  });
  s.addNotes("Сквозной пример одного сценария через все слои. ViewModel знает только UseCase, UseCase — только протокол репозитория; Firestore виден лишь в Infrastructure.");
}

// 8 ─ DI
{
  const s = slide("Dependency Injection");
  box(s, 0.5, 1.2, 2.9, 0.85, { fill: GOLD, text: "live()\nFirebase · UserDefaults", size: 12, bold: true });
  box(s, 0.5, 2.25, 2.9, 0.85, { fill: MIST, text: "mock()\nMock…Repository + MockResponse", size: 12, bold: true });
  arrow(s, 3.45, 1.62, 3.85, 1.95); arrow(s, 3.45, 2.67, 3.85, 2.35);
  box(s, 3.9, 1.2, 2.6, 1.9, { fill: INK, color: PAPER, text: "AppDIContainer\ninit(repositories:)\n\ncomposition root", size: 14, bold: true });
  arrow(s, 6.55, 2.15, 6.95, 2.15);
  box(s, 7.0, 1.2, 2.5, 1.9, { fill: MIST, text: "make…ViewModel()\nUseCase(repository:)\n→ ViewModel", size: 13, bold: true });
  code(s, 0.5, 3.4, 4.7, 1.45, "struct AppRepositories {\n  let auth: AuthRepositoryProtocol\n  let catalog: CatalogRepositoryProtocol\n  let cart: CartRepositoryProtocol\n  …  // всего 9 протоколов\n}", 11);
  s.addText([
    { text: "Зависимости передаются через init", options: { bullet: true, breakLine: true } },
    { text: "ViewModel видит только UseCase и протоколы", options: { bullet: true, breakLine: true } },
    { text: "Превью и тесты подставляют моки без сети", options: { bullet: true } },
  ], { x: 5.5, y: 3.4, w: 4.0, h: 1.45, fontFace: BODY, fontSize: 14, color: GREY, valign: "top", margin: 0, paraSpaceAfter: 6, isTextBox: true });
  s.addNotes("Контейнер — composition root. Для боевого режима он собирается из Firebase-реализаций, для превью — из mock-репозиториев (AppDIContainer.mock). ViewModel создаются фабричными методами контейнера.");
}

// 9 ─ DTO
{
  const s = slide("DTO и Mapper: зачем они нужны");
  const steps = [["Документ Firestore", "Infrastructure", MIST, INK], ["ProductDTO", "Data", MIST, INK], ["ProductMapper", "Data", MIST, INK], ["Product", "Domain", GOLD, INK], ["UI-модель", "Presentation", INK, PAPER]];
  steps.forEach((t, i) => {
    const x = 0.5 + i * 1.85;
    box(s, x, 1.15, 1.6, 0.85, { fill: t[2] });
    s.addText(t[0], { x: x + 0.05, y: 1.2, w: 1.5, h: 0.45, fontFace: HEAD, fontSize: 13, bold: true, color: t[3], align: "center", valign: "middle", margin: 0, isTextBox: true });
    s.addText(t[1], { x: x + 0.05, y: 1.65, w: 1.5, h: 0.3, fontFace: BODY, fontSize: 11, color: t[3] === PAPER ? "CFC8BA" : GREY, align: "center", valign: "middle", margin: 0, isTextBox: true });
    if (i < 4) arrow(s, x + 1.62, 1.57, x + 1.83, 1.57, { w: 1.5 });
  });
  box(s, 0.5, 2.3, 4.5, 2.55, { fill: MIST });
  label(s, "Зачем DTO", 0.7, 2.4, 4.1, { size: 16, bold: true, color: INK, font: HEAD });
  s.addText([
    { text: "DTO — формат конкретного бэкенда, а Product — язык нашего приложения", options: { bullet: true, breakLine: true } },
    { text: "Domain не зависит от схемы базы и SDK", options: { bullet: true, breakLine: true } },
    { text: "Главная цель: заменить Firebase на реальный сервер бренда", options: { bullet: true } },
  ], { x: 0.7, y: 2.85, w: 4.1, h: 1.95, fontFace: BODY, fontSize: 14, color: INK, valign: "top", margin: 0, paraSpaceAfter: 6, isTextBox: true });
  box(s, 5.3, 2.3, 4.2, 0.7, { fill: INK, color: PAPER, text: "CatalogRemoteDataSourceProtocol", size: 12, bold: true, font: "Courier New" });
  box(s, 5.3, 3.55, 2.0, 0.85, { fill: GOLD, text: "Firestore…Impl\nсейчас", size: 12, bold: true });
  box(s, 7.5, 3.55, 2.0, 0.85, { fill: PAPER, line: GOLD, dash: "dash", text: "REST…Impl\nпосле сделки", size: 12, bold: true });
  arrow(s, 6.3, 3.5, 6.3, 3.05); arrow(s, 8.5, 3.5, 8.5, 3.05);
  label(s, "Меняется только реализация DataSource (и при необходимости DTO / Mapper)", 5.3, 4.5, 4.2, { size: 12, h: 0.45, color: GREY });
  s.addNotes("Если сделка с брендом пойдёт дальше передачи кода, Firebase заменят на их сервер. Достаточно написать новую реализацию DataSource под другой JSON; Domain, ViewModel и экраны остаются нетронутыми.");
}

// 10 ─ API
{
  const s = slide("API: интеграция с Firebase");
  box(s, 0.5, 1.15, 2.2, 3.0, { fill: INK });
  label(s, "Слой Data", 0.5, 1.25, 2.2, { size: 16, bold: true, color: GOLD, align: "center", font: HEAD });
  s.addText([
    { text: "Repository Impl", options: { bold: true, color: PAPER, breakLine: true } },
    { text: "отдаёт данные в Domain", options: { color: "CFC8BA", breakLine: true } },
    { text: "DTO", options: { bold: true, color: PAPER, breakLine: true } },
    { text: "формат ответа бэкенда", options: { color: "CFC8BA", breakLine: true } },
    { text: "Mapper", options: { bold: true, color: PAPER, breakLine: true } },
    { text: "переводит DTO в модель приложения", options: { color: "CFC8BA", breakLine: true } },
    { text: "Протоколы DataSource", options: { bold: true, color: PAPER, breakLine: true } },
    { text: "контракт к источнику: Firebase или REST", options: { color: "CFC8BA" } },
  ], { x: 0.65, y: 1.7, w: 1.9, h: 2.4, fontFace: BODY, fontSize: 11, align: "left", valign: "top", margin: 0, paraSpaceAfter: 2, isTextBox: true });
  const ep = [
    ["Firebase Auth", "FirebaseAuthDataSourceImpl: регистрация, вход, письмо подтверждения, смена пароля и email", 1.15],
    ["Cloud Firestore", "Catalog, Cart, Notifications, Settings DataSourceImpl на async/await, FirestoreDecoder и ErrorMapper", 2.2],
    ["Firebase Hosting", "Фото товаров по HTTPS; повторы загрузки и кэш картинок — из settings/store", 3.25],
  ];
  ep.forEach(e => {
    box(s, 3.2, e[2], 6.3, 0.95, { fill: MIST });
    s.addText(e[0], { x: 3.4, y: e[2] + 0.07, w: 5.9, h: 0.3, fontFace: HEAD, fontSize: 14, bold: true, color: INK, margin: 0, isTextBox: true });
    s.addText(e[1], { x: 3.4, y: e[2] + 0.4, w: 5.9, h: 0.5, fontFace: BODY, fontSize: 12, color: GREY, margin: 0, valign: "top", isTextBox: true });
    arrow(s, 2.75, e[2] + 0.47, 3.15, e[2] + 0.47);
  });
  box(s, 0.5, 4.4, 9, 0.5, { fill: GOLD, text: "При входе каталог, корзина и настройки загружаются параллельно (async let в GetShopDataUseCase → ShopData)", size: 12, bold: true });
  s.addNotes("Весь Firebase-код сосредоточен в Infrastructure. Ошибки SDK преобразуются в доменные ошибки (ErrorMapper), поэтому ViewModel не знает про Firebase.");
}

// 11 ─ Firebase: данные и безопасность
{
  const s = slide("Firebase: данные и безопасность");
  box(s, 0.5, 1.15, 4.4, 3.75, { fill: MIST });
  label(s, "Cloud Firestore", 0.7, 1.25, 4, { size: 16, bold: true, color: INK, font: HEAD });
  [["categories", "4 категории"], ["products", "21 товар"], ["notificationList", "уведомления"], ["settings/store", "лимиты и кэш"], ["users/{uid}/cart", "корзина аккаунта"]].forEach((c, i) => {
    box(s, 0.7, 1.75 + i * 0.62, 2.2, 0.5, { fill: INK, color: PAPER, text: c[0], size: 11, font: "Courier New" });
    label(s, c[1], 3.05, 1.75 + i * 0.62, 1.8, { size: 13, h: 0.5 });
  });
  box(s, 5.2, 1.15, 4.3, 2.15, { fill: INK });
  label(s, "firestore.rules", 5.4, 1.23, 4, { size: 14, bold: true, color: GOLD, font: HEAD });
  s.addText("справочники: read только при\n  email_verified, write: false\nusers/{uid}/cart: только владелец,\n  поля проверяются,\n  quantity ≤ лимит из settings/store", { x: 5.4, y: 1.6, w: 3.95, h: 1.65, fontFace: "Courier New", fontSize: 12, color: "E8E2D6", margin: 0, valign: "top", isTextBox: true });
  box(s, 5.2, 3.5, 4.3, 1.4, { fill: GOLD });
  label(s, "Администрирование", 5.4, 3.57, 4, { size: 14, bold: true, color: INK, font: HEAD });
  s.addText("Скрипт firebase/seed (Admin SDK) заполняет каталог, уведомления и настройки. Клиент пишет только свою корзину.", { x: 5.4, y: 3.95, w: 3.95, h: 0.9, fontFace: BODY, fontSize: 13, color: INK, margin: 0, valign: "top", isTextBox: true });
  s.addNotes("Правила проверяются на сервере: даже изменённый клиент не прочитает каталог без подтверждённого email и не запишет чужую корзину или количество выше лимита.");
}

// 11b ─ Как это выглядит в Firestore
{
  const s = slide("Как данные выглядят в Firestore");
  box(s, 0.5, 1.1, 5.3, 3.85, { fill: INK });
  s.addText("products  ›  glasses-navigator", { x: 0.7, y: 1.2, w: 4.9, h: 0.3, fontFace: "Courier New", fontSize: 11, bold: true, color: GOLD, margin: 0, valign: "middle", isTextBox: true });
  s.addText("ID документа = id товара", { x: 0.7, y: 1.5, w: 4.9, h: 0.25, fontFace: BODY, fontSize: 10.5, color: "9A9488", margin: 0, valign: "middle", isTextBox: true });
  const rows = [
    ["id", "string", '"glasses-navigator"'],
    ["categoryId", "string", '"glasses"'],
    ["title", "string", '"Авиаторы Navigator"'],
    ["shortDescription", "string", '"Графитовые линзы, двойной мост"'],
    ["description", "string", '"Прямоугольные авиаторы…"'],
    ["price", "number", "32900"],
    ["order", "number", "1"],
    ["imageURL", "string", '"https://test-6d334.web.app/…"'],
    ["sizes", "array", '["S", "M", "L"]  (у часов)'],
  ];
  rows.forEach((r, i) => {
    const y = 1.82 + i * 0.31;
    s.addText(r[0], { x: 0.7, y, w: 1.55, h: 0.3, fontFace: "Courier New", fontSize: 10.5, bold: true, color: "E8E2D6", margin: 0, valign: "middle", isTextBox: true });
    s.addText(r[1], { x: 2.3, y, w: 0.65, h: 0.3, fontFace: BODY, fontSize: 10.5, color: "9A9488", margin: 0, valign: "middle", isTextBox: true });
    s.addText(r[2], { x: 3.0, y, w: 2.7, h: 0.3, fontFace: "Courier New", fontSize: 10.5, color: GOLD, margin: 0, valign: "middle", isTextBox: true });
  });
  label(s, "Поле: тип и значение, как в консоли Firebase", 0.7, 4.62, 4.9, { size: 10.5, italic: true, color: "9A9488" });

  label(s, "Как добавить или изменить", 6.05, 1.1, 3.45, { size: 15, bold: true, color: INK, font: HEAD });
  s.addText([
    { text: "Firebase Console → Firestore Database → Data", options: { bullet: { type: "number" }, breakLine: true } },
    { text: "Выбрать коллекцию и документ", options: { bullet: { type: "number" }, breakLine: true } },
    { text: "Карандаш у поля — изменить, Add field — добавить поле, Add document — новый документ (свой ID и поля)", options: { bullet: { type: "number" }, breakLine: true } },
    { text: "Удаление — через меню документа", options: { bullet: { type: "number" } } },
  ], { x: 6.05, y: 1.5, w: 3.45, h: 1.95, fontFace: BODY, fontSize: 11, color: INK, valign: "top", margin: 0, paraSpaceAfter: 3, isTextBox: true });
  box(s, 6.05, 3.5, 3.45, 0.7, { fill: GOLD, text: "Приложение подхватит правки при следующей загрузке или обновлении свайпом", size: 11, align: "left" });
  box(s, 6.05, 4.3, 3.45, 0.65, { fill: MIST, text: "Каталог перезаписывает скрипт seed: постоянные правки вносите в catalog.json", size: 11, align: "left" });
  s.addNotes("Так выглядит документ товара в Cloud Firestore: ID документа совпадает с id товара, поля имеют типы string, number, array. Править можно прямо в консоли Firebase: изменить значение поля, добавить поле или новый документ. Консоль обходит правила безопасности, поэтому это работает как админка. Важно: коллекции categories и products скрипт seed приводит в соответствие с catalog.json, поэтому постоянные правки каталога нужно делать в этом файле. Настройки магазина (settings/store, например maximumCartItemQuantity) можно менять в консоли без обновления приложения.");
}

// 12 ─ UserDefaults
{
  const s = slide("UserDefaults: локальные данные");
  const chain = [
    ["Репозиторий (Data)", "FavoritesRepositoryImpl", "Решает, что и когда сохранять. Реализует контракт из Domain", MIST],
    ["Контракт хранилища (Data)", "FavoritesLocalDataSource\nProtocol", "Только два действия: прочитать и сохранить id избранных", GOLD],
    ["Реализация (Infrastructure)", "UserDefaultsFavorites\nDataSourceImpl", "Пишет и читает данные в UserDefaults устройства", MIST],
  ];
  chain.forEach((c, i) => {
    const x = 0.5 + i * 3.15;
    box(s, x, 1.1, 2.7, 1.5, { fill: c[3] });
    s.addText(c[0], { x: x + 0.12, y: 1.15, w: 2.46, h: 0.3, fontFace: BODY, fontSize: 10.5, color: GREY, margin: 0, valign: "middle", isTextBox: true });
    s.addText(c[1], { x: x + 0.12, y: 1.45, w: 2.46, h: 0.5, fontFace: BODY, fontSize: 12, bold: true, color: INK, margin: 0, valign: "middle", isTextBox: true });
    s.addText(c[2], { x: x + 0.12, y: 1.98, w: 2.46, h: 0.58, fontFace: BODY, fontSize: 11, color: INK, margin: 0, valign: "top", isTextBox: true });
  });
  arrow(s, 3.22, 1.85, 3.62, 1.85); arrow(s, 6.78, 1.85, 6.38, 1.85);
  s.addText("Impl — реализация (implementation). В имени класса указана технология хранения: для Firestore был бы FirestoreFavoritesDataSourceImpl.", { x: 0.5, y: 2.68, w: 9, h: 0.45, fontFace: BODY, fontSize: 11, italic: true, color: GREY, margin: 0, valign: "top", isTextBox: true });
  label(s, "Ключ в UserDefaults", 0.5, 3.18, 2.6, { size: 10.5 });
  label(s, "Значение", 3.2, 3.18, 2.2, { size: 10.5 });
  label(s, "Что это", 5.5, 3.18, 4, { size: 10.5 });
  [["favorites.<uid>", '["p1", "p7"]', "Избранные товары пользователя. uid — id аккаунта Firebase"], ["notifications.seenIds", '["n1", "n2"]', "Прочитанные уведомления (общий список на устройстве)"]].forEach((r, i) => {
    const y = 3.45 + i * 0.58;
    box(s, 0.5, y, 9, 0.5, { fill: INK });
    s.addText(r[0], { x: 0.65, y, w: 2.5, h: 0.5, fontFace: "Courier New", fontSize: 11, bold: true, color: GOLD, margin: 0, valign: "middle", isTextBox: true });
    s.addText(r[1], { x: 3.2, y, w: 2.2, h: 0.5, fontFace: "Courier New", fontSize: 11, color: "E8E2D6", margin: 0, valign: "middle", isTextBox: true });
    s.addText(r[2], { x: 5.5, y, w: 3.9, h: 0.5, fontFace: BODY, fontSize: 11, color: PAPER, margin: 0, valign: "middle", isTextBox: true });
  });
  s.addText([
    { text: "Избранное привязано к UID: аккаунты на одном устройстве не смешиваются", options: { bullet: true, breakLine: true } },
    { text: "Работает без сети, но не синхронизируется между устройствами (потом стоит перенести в Firestore)", options: { bullet: true, breakLine: true } },
    { text: "Корзина в Firestore (users/{uid}/cart), а не в UserDefaults — так сделано изначально", options: { bullet: true } },
  ], { x: 0.5, y: 4.62, w: 9, h: 0.6, fontFace: BODY, fontSize: 11, color: GREY, valign: "top", margin: 0, paraSpaceAfter: 1, isTextBox: true });
  s.addNotes("Цепочка слева направо: репозиторий (Data) обращается к контракту хранилища (протокол в Data), а реализация на UserDefaults (Infrastructure) этот контракт выполняет. favorites.<uid> — ключ в UserDefaults, в котором лежит массив id избранных товаров этого пользователя. notifications.seenIds — ключ со списком прочитанных уведомлений.");
}

// 14 ─ Выводы
{
  const s = slide("Результаты и выводы");
  const stats = [["0", "импортов Firebase\nв Domain и Data"], ["9", "репозиториев\nза протоколами"], ["iOS 17+", "минимальная\nверсия"], ["2", "языка\nRU / EN"]];
  stats.forEach((t, i) => {
    const x = 0.5 + i * 2.3;
    box(s, x, 1.15, 2.1, 1.5, { fill: i === 0 ? INK : MIST });
    s.addText(t[0], { x, y: 1.25, w: 2.1, h: 0.7, fontFace: HEAD, fontSize: 36, bold: true, color: i === 0 ? GOLD : INK, align: "center", margin: 0, valign: "middle", isTextBox: true });
    s.addText(t[1], { x, y: 1.95, w: 2.1, h: 0.6, fontFace: BODY, fontSize: 13, color: i === 0 ? "CFC8BA" : GREY, align: "center", margin: 0, valign: "top", isTextBox: true });
  });
  s.addText([
    { text: "Готово рабочее демо: каталог, избранное, корзина и покупка в демо-режиме под аккаунтом", options: { bullet: true, breakLine: true } },
    { text: "Clean Architecture отделила бизнес-логику от Firebase: смена бэкенда затрагивает только Infrastructure и Data", options: { bullet: true, breakLine: true } },
    { text: "Корзина привязана к аккаунту и хранится в облаке, а доступ защищён правилами Firestore", options: { bullet: true, breakLine: true } },
    { text: "Цена гибкости: больше слоёв и кода (протоколы, DTO, Mapper)", options: { bullet: true } },
  ], { x: 0.5, y: 2.9, w: 9, h: 2.1, fontFace: BODY, fontSize: 14, color: INK, valign: "top", margin: 0, paraSpaceAfter: 6, isTextBox: true });
  s.addNotes("Итоги: что получилось и какую цену заплатили за архитектуру. Эта цена оправдана, если проект пойдёт к реальному серверу бренда.");
}

// 15 ─ Планы развития после сделки
{
  const s = slide("Планы развития после сделки");
  const items = [
    ["Реальный сервер", "Собственный сервер или существующий бэкенд Montblanc: новая реализация DataSource вместо Firebase"],
    ["Оплата и заказы", "Настоящее оформление заказа и оплата вместо демо-режима"],
    ["Аналитика в Firebase", "Просмотры товаров, лайки и добавления в корзину для бизнес-аналитики бренда"],
  ];
  items.forEach((it, i) => {
    const y = 1.2 + i * 1.2;
    box(s, 0.5, y, 9, 1.05, { fill: MIST });
    s.addShape(pres.ShapeType.ellipse, { x: 0.75, y: y + 0.3, w: 0.45, h: 0.45, fill: { color: INK }, line: { type: "none" } });
    s.addText(String(i + 1), { x: 0.75, y: y + 0.3, w: 0.45, h: 0.45, fontFace: HEAD, fontSize: 16, bold: true, color: GOLD, align: "center", valign: "middle", margin: 0, isTextBox: true });
    s.addText(it[0], { x: 1.45, y, w: 2.9, h: 1.05, fontFace: HEAD, fontSize: 17, bold: true, color: INK, margin: 0, valign: "middle", isTextBox: true });
    s.addText(it[1], { x: 4.5, y, w: 4.8, h: 1.05, fontFace: BODY, fontSize: 14, color: GREY, margin: 0, valign: "middle", isTextBox: true });
  });
  s.addNotes("Что будет после сделки. Сервер: новая реализация DataSource, остальные слои не меняются. Оплата и заказы: настоящий checkout вместо демо. Аналитика: события просмотров, лайков и добавления в корзину в Firebase Analytics для бизнес-аналитики бренда.");
}

// 16 ─ Спасибо
{
  const s = slide(null, { dark: true });
  s.addText("Спасибо за внимание!", { x: 0.7, y: 1.7, w: 8.6, h: 1.2, fontFace: HEAD, fontSize: 48, bold: true, color: PAPER, margin: 0, valign: "middle", isTextBox: true });
  s.addText("Буду рад ответить на вопросы", { x: 0.7, y: 3.0, w: 8.6, h: 0.5, fontFace: BODY, fontSize: 20, color: GOLD, margin: 0, valign: "middle", isTextBox: true });
  s.addText("ClothesShop  ·  Alex Rimain", { x: 0.7, y: 4.4, w: 8.6, h: 0.4, fontFace: BODY, fontSize: 14, color: "9A9488", margin: 0, valign: "middle", isTextBox: true });
  s.addNotes("Поблагодарить комиссию и перейти к вопросам.");
}

pres.writeFile({ fileName: OUT }).then(() => console.log("saved", OUT, n));
