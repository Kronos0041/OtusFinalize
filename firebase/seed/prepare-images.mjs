// Подготавливает фото для Firebase Hosting; после миграции источником служит public/products.
// Повторный запуск сохраняет те же пути и URL. В iOS-приложение эти файлы не входят.
import { access, copyFile, mkdir, readFile, writeFile } from 'node:fs/promises';
import { createHash } from 'node:crypto';

const catalogPath = new URL('./catalog.json', import.meta.url);
const catalog = JSON.parse(await readFile(catalogPath, 'utf8'));
const output = new URL('../hosting/public/products/', import.meta.url);
const assets = new URL('../../ClothesShop/Assets.xcassets/AppImage/Category/', import.meta.url);
const mapping = {
  Glas1: 'glasses-navigator', Glas2: 'glasses-panto-rose', Glas3: 'glasses-browline-tortoise',
  Glas4: 'glasses-slim-black', Glas5: 'glasses-titanium-round', Glas6: 'glasses-pilot-gold',
  Glas7: 'glasses-aviator-silver', Bag1: 'luggage-cabin-black', Bag2: 'luggage-medium-black',
  Bag3: 'luggage-cabin-aluminium', Bag4: 'luggage-trunk-aluminium', Bag5: 'luggage-cabin-red-line',
  Pen1: 'pen-blue-resin', Pen2: 'pen-classic-black', Pen3: 'pen-night-star', Pen4: 'pen-limited-gold',
  Watch1: 'watch-moonphase-rose', Watch2: 'watch-bronze-green', Watch3: 'watch-night-pattern',
  Watch4: 'watch-steel-black', Watch5: 'watch-blue-brown',
};
const exists = async (path) => access(path).then(() => true, () => false);
const jobs = [];

// Проверяем всё сопоставление до записи любых файлов.
for (const product of catalog.products) {
  const asset = Object.keys(mapping).find((name) => mapping[name] === product.id);
  if (!asset) throw new Error(`Нет сопоставления для товара ${product.id}`);
  if (product.imageName && product.imageName !== asset) throw new Error(`Неверный imageset для ${product.id}`);
  const group = asset.startsWith('Glas') ? 'Glass' : asset.replace(/\d+$/, '');
  const imageset = new URL(`${group}/${asset}.imageset/`, assets);
  let source;
  let filename;
  if (await exists(new URL('Contents.json', imageset))) {
    const contents = JSON.parse(await readFile(new URL('Contents.json', imageset), 'utf8'));
    const files = [...new Set(contents.images.map((image) => image.filename).filter(Boolean))];
    if (files.length !== 1) throw new Error(`${asset}: ожидается один исходный файл`);
    source = new URL(files[0], imageset);
    const extension = files[0].split('.').pop().toLowerCase();
    if (!['png', 'jpg', 'jpeg'].includes(extension)) throw new Error(`${asset}: неизвестный формат`);
    filename = `${product.id}.${extension}`;
  } else {
    const url = new URL(product.imageURL);
    if (url.origin !== 'https://test-6d334.web.app' || !url.pathname.startsWith('/products/')) {
      throw new Error(`${product.id}: неизвестный URL Hosting`);
    }
    filename = url.pathname.split('/').pop();
    if (!new RegExp(`^${product.id}\\.(png|jpg|jpeg)$`).test(filename)) throw new Error(`Неверный файл: ${filename}`);
    source = new URL(filename, output);
  }
  const data = await readFile(source);
  const version = createHash('sha256').update(data).digest('hex').slice(0, 12);
  jobs.push({ product, source, destination: new URL(filename, output), filename, version });
}

await mkdir(output, { recursive: true });
for (const job of jobs) {
  if (job.source.href !== job.destination.href) await copyFile(job.source, job.destination);
  delete job.product.imageName;
  job.product.imageURL = `https://test-6d334.web.app/products/${job.filename}?v=${job.version}`;
}
await writeFile(catalogPath, JSON.stringify(catalog, null, 2) + '\n');
console.log(`Подготовлено ${jobs.length} фото для Hosting. URL обновлены в catalog.json.`);
