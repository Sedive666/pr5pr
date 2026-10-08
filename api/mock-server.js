#!/usr/bin/env node
/**
 * Мок-сервер учебного API «Магазин кроссовок».
 *
 * Реализует контракт из файла КОНТРАКТ-API.md.
 * Зависимостей нет — нужен только Node.js 18 или новее.
 *
 *   node mock-server.js
 *   node mock-server.js --port 8080 --origin http://localhost:5555
 *
 * Данные хранятся в памяти и сбрасываются при перезапуске
 * либо запросом POST /api/__reset
 *
 * Учебные возможности:
 *   ?__delay=1500   задержка ответа в миллисекундах (проверка индикатора загрузки)
 *   ?__fail=500     принудительный код ошибки (проверка обработки ошибок)
 */

'use strict';

const http = require('node:http');
const crypto = require('node:crypto');

// ─────────────────────────── параметры запуска ───────────────────────────

const args = process.argv.slice(2);
function arg(name, fallback) {
  const i = args.indexOf('--' + name);
  return i !== -1 && args[i + 1] ? args[i + 1] : fallback;
}

const PORT = Number(arg('port', 8080));
const ORIGIN = arg('origin', '*');
const SECRET = 'учебный-ключ-не-для-продакшена';
const ACCESS_TTL = Number(arg('ttl', 900)); // секунд
const REFRESH_TTL = 60 * 60 * 24 * 7;

// ─────────────────────────────── токены ───────────────────────────────

function b64url(buf) {
  return Buffer.from(buf).toString('base64url');
}

function sign(payload) {
  const withId = { ...payload, jti: crypto.randomUUID() };
  const body = b64url(JSON.stringify(withId));
  const mac = crypto.createHmac('sha256', SECRET).update(body).digest('base64url');
  return body + '.' + mac;
}

function verify(token) {
  if (typeof token !== 'string' || !token.includes('.')) return null;
  const [body, mac] = token.split('.');
  const expected = crypto.createHmac('sha256', SECRET).update(body).digest('base64url');
  if (mac !== expected) return null;
  let payload;
  try {
    payload = JSON.parse(Buffer.from(body, 'base64url').toString('utf8'));
  } catch {
    return null;
  }
  if (payload.exp && payload.exp * 1000 < Date.now()) return null;
  return payload;
}

function hash(password) {
  return crypto.createHash('sha256').update(password + SECRET).digest('hex');
}

// ─────────────────────────────── данные ───────────────────────────────

let db;

const iso = (y, m, d) => new Date(Date.UTC(y, m - 1, d, 9, 0, 0)).toISOString();

function seed() {
  db = {
    brands: [
      { id: 1, name: 'Nike', country: 'США', foundedYear: 1964, deletedAt: null },
      { id: 2, name: 'Adidas', country: 'Германия', foundedYear: 1949, deletedAt: null },
      { id: 3, name: 'New Balance', country: 'США', foundedYear: 1906, deletedAt: null },
    ],
    categories: [
      { id: 1, name: 'Беговые', description: 'Для бега и тренировок', deletedAt: null },
      { id: 2, name: 'Баскетбольные', description: 'Для игры в зале', deletedAt: null },
      { id: 3, name: 'Повседневные', description: 'На каждый день', deletedAt: null },
      { id: 4, name: 'Скейтбординг', description: 'Усиленная конструкция', deletedAt: null },
      { id: 5, name: 'Ретро', description: 'Переиздания прошлых лет', deletedAt: null },
    ],
    series: [
      { id: 1, name: 'Air Max', brandId: 1, country: 'США', launchYear: 1987, deletedAt: null },
      { id: 2, name: 'Air Force 1', brandId: 1, country: 'США', launchYear: 1982, deletedAt: null },
      { id: 3, name: 'Dunk', brandId: 1, country: 'США', launchYear: 1985, deletedAt: null },
      { id: 4, name: 'Air Jordan 1', brandId: 1, country: 'США', launchYear: 1985, deletedAt: null },
      { id: 5, name: 'Ultraboost', brandId: 2, country: 'Германия', launchYear: 2015, deletedAt: null },
      { id: 6, name: 'Samba', brandId: 2, country: 'Германия', launchYear: 1950, deletedAt: null },
      { id: 7, name: 'Gazelle', brandId: 2, country: 'Германия', launchYear: 1966, deletedAt: null },
      { id: 8, name: '574', brandId: 3, country: 'США', launchYear: 1988, deletedAt: null },
      { id: 9, name: '990', brandId: 3, country: 'США', launchYear: 1982, deletedAt: null },
      { id: 10, name: '2002R', brandId: 3, country: 'Япония', launchYear: 2010, deletedAt: null },
      { id: 11, name: 'Superstar', brandId: 2, country: 'Германия', launchYear: 1969, deletedAt: null },
      { id: 12, name: '991', brandId: 3, country: 'Великобритания', launchYear: 2001, deletedAt: null },
      { id: 13, name: 'SB', brandId: 1, country: 'США', launchYear: 2002, deletedAt: null },
    ],
    sneakers: [
      { id: 1, name: 'Nike Air Max 90', sku: 'CN8490-002', year: 2020, price: 14990, brandId: 1, seriesIds: [1], categoryIds: [3, 5], stockTotal: 12, stockAvailable: 7, deletedAt: null },
      { id: 2, name: 'Nike Air Max 97', sku: '921826-101', year: 2017, price: 18990, brandId: 1, seriesIds: [1], categoryIds: [3], stockTotal: 8, stockAvailable: 3, deletedAt: null },
      { id: 3, name: 'Nike Air Max Plus', sku: '604133-139', year: 2019, price: 17490, brandId: 1, seriesIds: [1], categoryIds: [1, 3], stockTotal: 6, stockAvailable: 6, deletedAt: null },
      { id: 4, name: "Nike Air Force 1 '07", sku: 'CW2288-111', year: 2021, price: 11990, brandId: 1, seriesIds: [2], categoryIds: [3], stockTotal: 20, stockAvailable: 15, deletedAt: null },
      { id: 5, name: 'Nike Air Force 1 Mid', sku: 'DV0806-100', year: 2022, price: 13490, brandId: 1, seriesIds: [2], categoryIds: [3], stockTotal: 10, stockAvailable: 4, deletedAt: null },
      { id: 6, name: 'Nike Dunk Low Panda', sku: 'DD1391-100', year: 2021, price: 12990, brandId: 1, seriesIds: [3, 13], categoryIds: [4, 3], stockTotal: 15, stockAvailable: 0, deletedAt: null },
      { id: 7, name: 'Nike SB Dunk Low Pro', sku: 'BQ6817-100', year: 2019, price: 10990, brandId: 1, seriesIds: [3, 13], categoryIds: [4], stockTotal: 9, stockAvailable: 5, deletedAt: null },
      { id: 8, name: 'Nike Dunk High Retro', sku: 'DD1399-105', year: 2022, price: 13990, brandId: 1, seriesIds: [3], categoryIds: [3, 5], stockTotal: 7, stockAvailable: 2, deletedAt: null },
      { id: 9, name: 'Air Jordan 1 Retro High OG', sku: '555088-134', year: 2020, price: 21990, brandId: 1, seriesIds: [4], categoryIds: [2, 5], stockTotal: 5, stockAvailable: 1, deletedAt: null },
      { id: 10, name: 'Air Jordan 1 Mid', sku: '554724-173', year: 2021, price: 15490, brandId: 1, seriesIds: [4], categoryIds: [2], stockTotal: 11, stockAvailable: 8, deletedAt: null },
      { id: 11, name: 'Air Jordan 1 Low', sku: '553558-161', year: 2023, price: 12490, brandId: 1, seriesIds: [4], categoryIds: [3], stockTotal: 14, stockAvailable: 10, deletedAt: null },
      { id: 12, name: 'Adidas Ultraboost 22', sku: 'GX5459', year: 2022, price: 17990, brandId: 2, seriesIds: [5], categoryIds: [1], stockTotal: 10, stockAvailable: 6, deletedAt: null },
      { id: 13, name: 'Adidas Ultraboost Light', sku: 'HQ6351', year: 2023, price: 19990, brandId: 2, seriesIds: [5], categoryIds: [1], stockTotal: 8, stockAvailable: 8, deletedAt: null },
      { id: 14, name: 'Adidas Ultraboost 1.0', sku: 'HQ4201', year: 2023, price: 16990, brandId: 2, seriesIds: [5], categoryIds: [1, 5], stockTotal: 6, stockAvailable: 2, deletedAt: null },
      { id: 15, name: 'Adidas Samba OG', sku: 'B75806', year: 2018, price: 11990, brandId: 2, seriesIds: [6], categoryIds: [3, 5], stockTotal: 18, stockAvailable: 9, deletedAt: null },
      { id: 16, name: 'Adidas Samba ADV', sku: 'GW3159', year: 2022, price: 10490, brandId: 2, seriesIds: [6], categoryIds: [4], stockTotal: 7, stockAvailable: 3, deletedAt: null },
      { id: 17, name: 'Adidas Gazelle', sku: 'BB5476', year: 2017, price: 9990, brandId: 2, seriesIds: [7], categoryIds: [3, 5], stockTotal: 12, stockAvailable: 12, deletedAt: null },
      { id: 18, name: 'Adidas Gazelle Indoor', sku: 'IG1640', year: 2024, price: 12490, brandId: 2, seriesIds: [7], categoryIds: [3], stockTotal: 9, stockAvailable: 4, deletedAt: null },
      { id: 19, name: 'Adidas Superstar', sku: 'EG4958', year: 2019, price: 9490, brandId: 2, seriesIds: [11], categoryIds: [3, 5], stockTotal: 16, stockAvailable: 11, deletedAt: null },
      { id: 20, name: 'New Balance 574 Core', sku: 'ML574EVG', year: 2020, price: 9990, brandId: 3, seriesIds: [8], categoryIds: [3], stockTotal: 14, stockAvailable: 9, deletedAt: null },
      { id: 21, name: 'New Balance 574 Legacy', sku: 'U574LGG1', year: 2022, price: 10990, brandId: 3, seriesIds: [8], categoryIds: [3, 5], stockTotal: 8, stockAvailable: 5, deletedAt: null },
      { id: 22, name: 'New Balance 990v6', sku: 'M990GL6', year: 2022, price: 24990, brandId: 3, seriesIds: [9], categoryIds: [1], stockTotal: 5, stockAvailable: 2, deletedAt: null },
      { id: 23, name: 'New Balance 990v5', sku: 'M990GL5', year: 2019, price: 21990, brandId: 3, seriesIds: [9], categoryIds: [1, 5], stockTotal: 4, stockAvailable: 0, deletedAt: null },
      { id: 24, name: 'New Balance 2002R', sku: 'M2002RXD', year: 2021, price: 15990, brandId: 3, seriesIds: [10], categoryIds: [1, 3], stockTotal: 9, stockAvailable: 6, deletedAt: null },
      { id: 25, name: 'New Balance 2002R Protection Pack', sku: 'M2002RDA', year: 2022, price: 17990, brandId: 3, seriesIds: [10], categoryIds: [3], stockTotal: 6, stockAvailable: 3, deletedAt: null },
      { id: 26, name: 'New Balance 991v2', sku: 'U991GL2', year: 2023, price: 27990, brandId: 3, seriesIds: [12], categoryIds: [3, 5], stockTotal: 4, stockAvailable: 4, deletedAt: null },
    ],
    customers: [
      { id: 1, firstName: 'Иван', lastName: 'Петров', email: 'ivan.petrov@mail.ru', phone: '+7 916 123-45-67', city: 'Москва', card: { number: '10000001', level: 'Золотая', bonusPoints: 2400, issuedAt: iso(2023, 5, 12) }, deletedAt: null },
      { id: 2, firstName: 'Анна', lastName: 'Смирнова', email: 'anna.smirnova@gmail.com', phone: '+7 903 555-12-34', city: 'Санкт-Петербург', card: { number: '10000002', level: 'Платиновая', bonusPoints: 7800, issuedAt: iso(2022, 11, 3) }, deletedAt: null },
      { id: 3, firstName: 'Дмитрий', lastName: 'Козлов', email: 'd.kozlov@yandex.ru', phone: '+7 925 777-88-99', city: 'Москва', card: null, deletedAt: null },
      { id: 4, firstName: 'Мария', lastName: 'Волкова', email: 'maria.volkova@mail.ru', phone: '+7 911 222-33-44', city: 'Казань', card: { number: '10000004', level: 'Серебряная', bonusPoints: 450, issuedAt: iso(2024, 2, 20) }, deletedAt: null },
      { id: 5, firstName: 'Алексей', lastName: 'Новиков', email: 'alex.novikov@gmail.com', phone: '+7 952 404-10-10', city: 'Новосибирск', card: null, deletedAt: null },
      { id: 6, firstName: 'Ольга', lastName: 'Егорова', email: 'olga.egorova@mail.ru', phone: '+7 937 616-20-20', city: 'Екатеринбург', card: { number: '10000006', level: 'Золотая', bonusPoints: 3100, issuedAt: iso(2023, 9, 1) }, deletedAt: null },
    ],
    orders: [
      { id: 1, number: 'ORD-1001', customerId: 1, sneakerId: 4, size: 42, quantity: 1, price: 11990, status: 'Доставлен', createdAt: iso(2025, 3, 14), deletedAt: null },
      { id: 2, number: 'ORD-1002', customerId: 2, sneakerId: 12, size: 38, quantity: 2, price: 17990, status: 'Отправлен', createdAt: iso(2025, 4, 2), deletedAt: null },
      { id: 3, number: 'ORD-1003', customerId: 1, sneakerId: 22, size: 43, quantity: 1, price: 24990, status: 'Оплачен', createdAt: iso(2025, 4, 18), deletedAt: null },
      { id: 4, number: 'ORD-1004', customerId: 3, sneakerId: 15, size: 41, quantity: 1, price: 11990, status: 'Новый', createdAt: iso(2025, 5, 7), deletedAt: null },
      { id: 5, number: 'ORD-1005', customerId: 4, sneakerId: 9, size: 39, quantity: 1, price: 21990, status: 'Отменён', createdAt: iso(2025, 5, 21), deletedAt: null },
      { id: 6, number: 'ORD-1006', customerId: 2, sneakerId: 19, size: 37, quantity: 3, price: 9490, status: 'Доставлен', createdAt: iso(2025, 6, 9), deletedAt: null },
      { id: 7, number: 'ORD-1007', customerId: 5, sneakerId: 24, size: 44, quantity: 1, price: 15990, status: 'Оплачен', createdAt: iso(2025, 6, 30), deletedAt: null },
      { id: 8, number: 'ORD-1008', customerId: 6, sneakerId: 17, size: 40, quantity: 2, price: 9990, status: 'Новый', createdAt: iso(2025, 7, 11), deletedAt: null },
      { id: 9, number: 'ORD-1009', customerId: 1, sneakerId: 26, size: 42, quantity: 1, price: 27990, status: 'Отправлен', createdAt: iso(2025, 8, 3), deletedAt: null },
      { id: 10, number: 'ORD-1010', customerId: 4, sneakerId: 6, size: 38, quantity: 1, price: 12990, status: 'Доставлен', createdAt: iso(2025, 8, 25), deletedAt: null },
      { id: 11, number: 'ORD-1011', customerId: 3, sneakerId: 13, size: 43, quantity: 1, price: 19990, status: 'Новый', createdAt: iso(2025, 9, 6), deletedAt: null },
      { id: 12, number: 'ORD-1012', customerId: 6, sneakerId: 1, size: 41, quantity: 2, price: 14990, status: 'Оплачен', createdAt: iso(2025, 9, 19), deletedAt: null },
    ],
    reviews: [
      { id: 1, customerId: 1, sneakerId: 4, rating: 5, text: 'Классика, которая никогда не подведёт. Размер в размер.', createdAt: iso(2025, 3, 20), deletedAt: null },
      { id: 2, customerId: 2, sneakerId: 12, rating: 4, text: 'Очень мягкие, но для узкой стопы великоваты.', createdAt: iso(2025, 4, 10), deletedAt: null },
      { id: 3, customerId: 1, sneakerId: 22, rating: 5, text: 'Лучшие кроссовки для долгой ходьбы, ноги не устают.', createdAt: iso(2025, 4, 25), deletedAt: null },
      { id: 4, customerId: 3, sneakerId: 15, rating: 4, text: 'Стильные, но подошва скользит на мокром асфальте.', createdAt: iso(2025, 5, 15), deletedAt: null },
      { id: 5, customerId: 4, sneakerId: 9, rating: 3, text: 'Качество хорошее, но цена завышена.', createdAt: iso(2025, 5, 30), deletedAt: null },
      { id: 6, customerId: 2, sneakerId: 19, rating: 5, text: 'Беру уже третью пару, лучше ничего не придумали.', createdAt: iso(2025, 6, 18), deletedAt: null },
      { id: 7, customerId: 5, sneakerId: 24, rating: 4, text: 'Удобные, качество отличное, цвет как на фото.', createdAt: iso(2025, 7, 5), deletedAt: null },
      { id: 8, customerId: 6, sneakerId: 17, rating: 5, text: 'Лёгкие и дышащие, идеальны на лето.', createdAt: iso(2025, 7, 20), deletedAt: null },
      { id: 9, customerId: 1, sneakerId: 26, rating: 5, text: 'Дорого, но оправдано: обувь премиального уровня.', createdAt: iso(2025, 8, 12), deletedAt: null },
      { id: 10, customerId: 4, sneakerId: 6, rating: 2, text: 'Пришли с царапиной на мыске, пришлось менять.', createdAt: iso(2025, 9, 1), deletedAt: null },
      { id: 11, customerId: 3, sneakerId: 1, rating: 4, text: 'Хорошая амортизация, но шнурки коротковаты.', createdAt: iso(2025, 9, 14), deletedAt: null },
      { id: 12, customerId: 6, sneakerId: 13, rating: 5, text: 'Бегаю каждый день, за три месяца износа нет.', createdAt: iso(2025, 9, 28), deletedAt: null },
    ],
    users: [
      { id: 1, login: 'admin', passwordHash: hash('admin123'), role: 'admin', name: 'Администратор', customerId: null, deletedAt: null },
      { id: 2, login: 'manager', passwordHash: hash('manager123'), role: 'manager', name: 'Менеджер зала', customerId: null, deletedAt: null },
      { id: 3, login: 'client', passwordHash: hash('client123'), role: 'client', name: 'Дмитрий Козлов', customerId: 3, deletedAt: null },
    ],
    refreshTokens: new Set(),
  };
}

const COLLECTIONS = ['sneakers', 'brands', 'series', 'categories', 'customers', 'orders', 'reviews'];

function nextId(collection) {
  return db[collection].reduce((m, x) => (x.id > m ? x.id : m), 0) + 1;
}

function byId(collection, id) {
  return db[collection].find((x) => x.id === id) || null;
}

function alive(collection) {
  return db[collection].filter((x) => !x.deletedAt);
}

// ───────────────────────── развёртывание связей ─────────────────────────

const slimBrand = (id) => {
  const b = byId('brands', id);
  return b ? { id: b.id, name: b.name, country: b.country } : null;
};
const slimSneaker = (id) => {
  const s = byId('sneakers', id);
  return s ? { id: s.id, name: s.name, sku: s.sku, price: s.price } : null;
};
const slimCustomer = (id) => {
  const c = byId('customers', id);
  return c ? { id: c.id, fullName: `${c.lastName} ${c.firstName}`, email: c.email } : null;
};

const expandSneaker = (s) => ({
  ...s,
  brand: slimBrand(s.brandId),
  series: s.seriesIds.map((id) => byId('series', id)).filter(Boolean).map((x) => ({ id: x.id, name: x.name })),
  categories: s.categoryIds.map((id) => byId('categories', id)).filter(Boolean).map((x) => ({ id: x.id, name: x.name })),
});

const expandSeries = (s) => ({ ...s, brand: slimBrand(s.brandId) });

const expandOrder = (o) => ({
  ...o,
  total: o.price * o.quantity,
  customer: slimCustomer(o.customerId),
  sneaker: slimSneaker(o.sneakerId),
});

const expandReview = (r) => ({
  ...r,
  customer: slimCustomer(r.customerId),
  sneaker: slimSneaker(r.sneakerId),
});

const expandCustomer = (c) => ({ ...c, fullName: `${c.lastName} ${c.firstName}` });

const EXPANDERS = {
  sneakers: expandSneaker,
  brands: (b) => ({ ...b }),
  series: expandSeries,
  categories: (c) => ({ ...c }),
  customers: expandCustomer,
  orders: expandOrder,
  reviews: expandReview,
};

const expandUser = (u) => ({ id: u.id, login: u.login, role: u.role, name: u.name, customerId: u.customerId ?? null, blocked: !!u.deletedAt });

// ──────────────────── поиск, фильтры, сортировка, страницы ────────────────────

function searchableText(collection, x) {
  switch (collection) {
    case 'sneakers': return [x.name, x.sku].join(' ');
    case 'brands': return [x.name, x.country].join(' ');
    case 'series': return [x.name, x.country].join(' ');
    case 'categories': return [x.name, x.description].join(' ');
    case 'customers': return [x.lastName, x.firstName, x.email, x.phone, x.city].join(' ');
    case 'orders': return [x.number, x.status].join(' ');
    case 'reviews': return [x.text].join(' ');
    default: return '';
  }
}

function applyFilters(collection, rows, q) {
  let result = rows;
  const num = (v) => Number(v);

  if (q.search) {
    const needle = String(q.search).toLowerCase();
    result = result.filter((x) => searchableText(collection, x).toLowerCase().includes(needle));
  }

  if (collection === 'sneakers') {
    if (q.brandId) result = result.filter((s) => s.brandId === num(q.brandId));
    if (q.seriesId) result = result.filter((s) => s.seriesIds.includes(num(q.seriesId)));
    if (q.categoryId) result = result.filter((s) => s.categoryIds.includes(num(q.categoryId)));
    if (q.yearFrom) result = result.filter((s) => s.year >= num(q.yearFrom));
    if (q.yearTo) result = result.filter((s) => s.year <= num(q.yearTo));
    if (q.available === 'true') result = result.filter((s) => s.stockAvailable > 0);
  }
  if (collection === 'series') {
    if (q.brandId) result = result.filter((s) => s.brandId === num(q.brandId));
  }
  if (collection === 'customers') {
    if (q.city) result = result.filter((c) => c.city === q.city);
  }
  if (collection === 'orders') {
    if (q.status) result = result.filter((o) => o.status === q.status);
    if (q.customerId) result = result.filter((o) => o.customerId === num(q.customerId));
    if (q.sneakerId) result = result.filter((o) => o.sneakerId === num(q.sneakerId));
  }
  if (collection === 'reviews') {
    if (q.rating) result = result.filter((r) => r.rating === num(q.rating));
    if (q.sneakerId) result = result.filter((r) => r.sneakerId === num(q.sneakerId));
    if (q.customerId) result = result.filter((r) => r.customerId === num(q.customerId));
  }

  return result;
}

const SORT_VALUE = {
  sneakers: (x, f) => ({ name: x.name, year: x.year, price: x.price, stock: x.stockAvailable }[f]),
  brands: (x, f) => ({ name: x.name, country: x.country, year: x.foundedYear }[f]),
  series: (x, f) => ({ name: x.name, country: x.country, year: x.launchYear }[f]),
  categories: (x, f) => ({ name: x.name }[f]),
  customers: (x, f) => ({ name: `${x.lastName} ${x.firstName}`, city: x.city, bonus: x.card ? x.card.bonusPoints : 0 }[f]),
  orders: (x, f) => ({ number: x.number, date: x.createdAt, total: x.price * x.quantity }[f]),
  reviews: (x, f) => ({ date: x.createdAt, rating: x.rating }[f]),
};

function applySort(collection, rows, sort) {
  if (!sort) return rows;
  const [field, dirRaw] = String(sort).split(',');
  const dir = (dirRaw || 'asc').toLowerCase() === 'desc' ? -1 : 1;
  const value = SORT_VALUE[collection];
  return [...rows].sort((a, b) => {
    const av = value(a, field);
    const bv = value(b, field);
    if (av == null && bv == null) return 0;
    if (av == null) return 1;
    if (bv == null) return -1;
    if (typeof av === 'number' && typeof bv === 'number') return (av - bv) * dir;
    return String(av).localeCompare(String(bv), 'ru') * dir;
  });
}

function paginate(rows, q) {
  const page = Math.max(1, Number(q.page) || 1);
  const size = Math.min(100, Math.max(1, Number(q.size) || 10));
  const total = rows.length;
  const totalPages = Math.max(1, Math.ceil(total / size));
  return { items: rows.slice((page - 1) * size, page * size), page, size, total, totalPages };
}

// ─────────────────────────────── валидация ───────────────────────────────

const ORDER_STATUSES = ['Новый', 'Оплачен', 'Отправлен', 'Доставлен', 'Отменён'];
const CARD_LEVELS = ['Серебряная', 'Золотая', 'Платиновая'];
const SHOE_SIZES = [36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46];

const EMAIL_RE = /^[\w.+-]+@[\w-]+\.[\w.-]{2,}$/;
const PHONE_RE = /^\+?\d[\d ()-]{9,17}$/;
const SKU_RE = /^[A-Za-z0-9-]{4,20}$/;
const CARD_RE = /^\d{8,16}$/;

function validate(collection, body, id = null) {
  const e = {};
  const str = (v) => (typeof v === 'string' ? v.trim() : '');
  const int = (v) => (Number.isInteger(v) ? v : Number.parseInt(v, 10));

  const text = (field, label, min, max) => {
    const v = str(body[field]);
    if (!v) e[field] = 'Поле обязательно для заполнения';
    else if (v.length < min) e[field] = `Не короче ${min} символов`;
    else if (v.length > max) e[field] = `Не длиннее ${max} символов`;
    return v;
  };
  const range = (field, min, max) => {
    const v = int(body[field]);
    if (!Number.isInteger(v)) e[field] = 'Введите целое число';
    else if (v < min || v > max) e[field] = `Значение от ${min} до ${max}`;
    return v;
  };
  const ref = (field, target) => {
    const v = int(body[field]);
    if (!Number.isInteger(v) || !byId(target, v) || byId(target, v).deletedAt) {
      e[field] = 'Выберите значение из списка';
    }
    return v;
  };
  const refList = (field, target, label) => {
    const list = Array.isArray(body[field]) ? body[field].map(Number) : [];
    if (!list.length) e[field] = `Выберите хотя бы ${label}`;
    else if (list.some((x) => !byId(target, x))) e[field] = 'В списке есть несуществующая запись';
    return list;
  };
  const unique = (field, label, value) => {
    if (e[field] || !value) return;
    const needle = String(value).trim().toLowerCase();
    const clash = db[collection].some(
      (x) => x.id !== id && String(x[field] ?? '').trim().toLowerCase() === needle
    );
    if (clash) e[field] = `${label} «${value}» уже используется`;
  };

  switch (collection) {
    case 'sneakers': {
      text('name', 'Название', 3, 80);
      const sku = text('sku', 'Артикул', 4, 20);
      if (!e.sku && !SKU_RE.test(sku)) e.sku = 'Артикул: 4–20 латинских букв, цифр и дефисов';
      unique('sku', 'Артикул', sku);
      range('year', 1970, 2026);
      range('price', 1, 1000000);
      ref('brandId', 'brands');
      refList('seriesIds', 'series', 'одну линейку');
      refList('categoryIds', 'categories', 'одну категорию');
      const total = range('stockTotal', 0, 10000);
      const available = range('stockAvailable', 0, 10000);
      if (!e.stockAvailable && Number.isInteger(total) && available > total) {
        e.stockAvailable = 'Доступно пар не может быть больше общего количества';
      }
      break;
    }
    case 'brands': {
      const name = text('name', 'Название', 2, 40);
      unique('name', 'Бренд', name);
      text('country', 'Страна', 2, 40);
      range('foundedYear', 1800, 2026);
      break;
    }
    case 'series': {
      text('name', 'Название', 2, 80);
      ref('brandId', 'brands');
      text('country', 'Страна', 2, 40);
      range('launchYear', 1900, 2026);
      break;
    }
    case 'categories': {
      const name = text('name', 'Название', 3, 40);
      unique('name', 'Категория', name);
      if (str(body.description).length > 200) e.description = 'Не длиннее 200 символов';
      break;
    }
    case 'customers': {
      text('lastName', 'Фамилия', 2, 40);
      text('firstName', 'Имя', 2, 40);
      const email = text('email', 'Почта', 5, 80);
      if (!e.email && !EMAIL_RE.test(email)) e.email = 'Неверный формат почты';
      unique('email', 'Почта', email);
      const phone = str(body.phone);
      if (!phone) e.phone = 'Поле обязательно для заполнения';
      else if (!PHONE_RE.test(phone)) e.phone = 'Неверный формат телефона';
      text('city', 'Город', 2, 40);
      if (body.card) {
        const card = body.card;
        if (!CARD_RE.test(str(card.number))) e.cardNumber = 'Номер карты: от 8 до 16 цифр';
        if (!CARD_LEVELS.includes(str(card.level))) e.cardLevel = 'Выберите уровень карты';
        const points = int(card.bonusPoints);
        if (!Number.isInteger(points) || points < 0 || points > 1000000) {
          e.bonusPoints = 'Значение от 0 до 1 000 000';
        }
      }
      break;
    }
    case 'orders': {
      const number = text('number', 'Номер заказа', 4, 20);
      unique('number', 'Номер заказа', number);
      ref('customerId', 'customers');
      ref('sneakerId', 'sneakers');
      const size = int(body.size);
      if (!SHOE_SIZES.includes(size)) e.size = 'Выберите размер';
      range('quantity', 1, 100);
      if (!ORDER_STATUSES.includes(str(body.status))) e.status = 'Выберите статус заказа';
      break;
    }
    case 'reviews': {
      ref('customerId', 'customers');
      ref('sneakerId', 'sneakers');
      const rating = int(body.rating);
      if (!Number.isInteger(rating) || rating < 1 || rating > 5) e.rating = 'Выберите оценку от 1 до 5';
      text('text', 'Текст отзыва', 10, 500);
      break;
    }
  }

  return e;
}

// ────────────────────────── целостность связей ──────────────────────────

const REFERENCES = {
  brands: [
    (id) => db.sneakers.filter((s) => !s.deletedAt && s.brandId === id).length,
    (id) => db.series.filter((s) => !s.deletedAt && s.brandId === id).length,
  ],
  series: [(id) => db.sneakers.filter((s) => !s.deletedAt && s.seriesIds.includes(id)).length],
  categories: [(id) => db.sneakers.filter((s) => !s.deletedAt && s.categoryIds.includes(id)).length],
  customers: [
    (id) => db.orders.filter((o) => !o.deletedAt && o.customerId === id).length,
    (id) => db.reviews.filter((r) => !r.deletedAt && r.customerId === id).length,
  ],
  sneakers: [
    (id) => db.orders.filter((o) => !o.deletedAt && o.sneakerId === id).length,
    (id) => db.reviews.filter((r) => !r.deletedAt && r.sneakerId === id).length,
  ],
};

function referenceCount(collection, id) {
  return (REFERENCES[collection] || []).reduce((sum, check) => sum + check(id), 0);
}

// ─────────────────────────────── ответы ───────────────────────────────

function allowedOrigin(res) {
  const requested = res.requestOrigin;
  if (ORIGIN === '*' || !requested) return ORIGIN;
  if (requested === ORIGIN) return requested;
  const twin = ORIGIN.includes('localhost')
    ? ORIGIN.replace('localhost', '127.0.0.1')
    : ORIGIN.replace('127.0.0.1', 'localhost');
  return requested === twin ? requested : ORIGIN;
}

function cors(res) {
  res.setHeader('Access-Control-Allow-Origin', allowedOrigin(res));
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  res.setHeader('Access-Control-Max-Age', '86400');
  res.setHeader('Vary', 'Origin');
}

function send(res, status, payload) {
  cors(res);
  if (payload === undefined || status === 204) {
    res.writeHead(204);
    res.end();
    return;
  }
  const body = JSON.stringify(payload, null, 2);
  res.writeHead(status, {
    'Content-Type': 'application/json; charset=utf-8',
    'Content-Length': Buffer.byteLength(body),
  });
  res.end(body);
}

function fail(res, status, message) {
  send(res, status, { message });
}

function failValidation(res, errors) {
  send(res, 422, { message: 'Ошибка валидации', errors });
}

async function readBody(req) {
  const chunks = [];
  for await (const chunk of req) chunks.push(chunk);
  if (!chunks.length) return {};
  try {
    return JSON.parse(Buffer.concat(chunks).toString('utf8'));
  } catch {
    return null; // признак некорректного JSON
  }
}

function currentUser(req) {
  const header = req.headers['authorization'] || '';
  if (!header.startsWith('Bearer ')) return null;
  const payload = verify(header.slice(7));
  if (!payload || payload.type !== 'access') return null;
  return db.users.find((u) => u.id === payload.sub && !u.deletedAt) || null;
}

const ROLES = ['client', 'manager', 'admin'];
const ROLE_TITLE = { client: 'покупатель', manager: 'менеджер', admin: 'администратор' };
const PASSWORD_RE = /^(?=.*\d)(?=.*[^\p{L}\d\s]).{8,}$/u;
const LOGIN_RE = /^[A-Za-z0-9_.-]{3,20}$/;

function requireRole(req, res, roles) {
  const user = currentUser(req);
  if (!user) {
    fail(res, 401, 'Требуется аутентификация');
    return null;
  }
  if (!roles.includes(user.role)) {
    fail(res, 403, `Операция недоступна для роли «${ROLE_TITLE[user.role]}»`);
    return null;
  }
  return user;
}

function issueTokens(user) {
  const now = Math.floor(Date.now() / 1000);
  const accessToken = sign({ sub: user.id, role: user.role, type: 'access', exp: now + ACCESS_TTL });
  const refreshToken = sign({ sub: user.id, type: 'refresh', exp: now + REFRESH_TTL });
  db.refreshTokens.add(refreshToken);
  return { accessToken, refreshToken, expiresIn: ACCESS_TTL, user: expandUser(user) };
}

const PUBLIC_READ = ['sneakers', 'brands', 'series', 'categories', 'reviews'];

const ANY = ROLES;
const STAFF = ['manager', 'admin'];
const MANAGER = ['manager'];
const ADMIN = ['admin'];

function allowedRoles(collection, method, action, q) {
  if (action === 'restore' || q.hard === 'true' || q.includeDeleted === 'true') return ADMIN;
  if (method === 'GET') return PUBLIC_READ.includes(collection) ? ANY : STAFF;
  return MANAGER;
}

// ─────────────────────────────── маршруты ───────────────────────────────

const ROUTE_RE = /^\/api\/([a-z]+)(?:\/(\d+))?(?:\/([a-z-]+))?$/;

function buildPayload(collection, body) {
  const num = (v) => Number.parseInt(v, 10);
  switch (collection) {
    case 'sneakers':
      return {
        name: String(body.name).trim(),
        sku: String(body.sku).trim(),
        year: num(body.year),
        price: num(body.price),
        brandId: num(body.brandId),
        seriesIds: (body.seriesIds || []).map(Number),
        categoryIds: (body.categoryIds || []).map(Number),
        stockTotal: num(body.stockTotal),
        stockAvailable: num(body.stockAvailable),
      };
    case 'brands':
      return {
        name: String(body.name).trim(),
        country: String(body.country).trim(),
        foundedYear: num(body.foundedYear),
      };
    case 'series':
      return {
        name: String(body.name).trim(),
        brandId: num(body.brandId),
        country: String(body.country).trim(),
        launchYear: num(body.launchYear),
      };
    case 'categories':
      return {
        name: String(body.name).trim(),
        description: String(body.description || '').trim(),
      };
    case 'customers':
      return {
        firstName: String(body.firstName).trim(),
        lastName: String(body.lastName).trim(),
        email: String(body.email).trim(),
        phone: String(body.phone).trim(),
        city: String(body.city).trim(),
        card: body.card
          ? {
              number: String(body.card.number).trim(),
              level: String(body.card.level).trim(),
              bonusPoints: num(body.card.bonusPoints),
              issuedAt: body.card.issuedAt || new Date().toISOString(),
            }
          : null,
      };
    case 'orders':
      return {
        number: String(body.number).trim(),
        customerId: num(body.customerId),
        sneakerId: num(body.sneakerId),
        size: num(body.size),
        quantity: num(body.quantity),
        price: num(body.price),
        status: String(body.status).trim(),
        createdAt: body.createdAt || new Date().toISOString(),
      };
    case 'reviews':
      return {
        customerId: num(body.customerId),
        sneakerId: num(body.sneakerId),
        rating: num(body.rating),
        text: String(body.text).trim(),
        createdAt: body.createdAt || new Date().toISOString(),
      };
    default:
      return {};
  }
}

async function handle(req, res, url) {
  const q = Object.fromEntries(url.searchParams.entries());
  const path = url.pathname.replace(/\/+$/, '') || '/';
  const method = req.method.toUpperCase();

  if (q.__fail) {
    return fail(res, Number(q.__fail), 'Ошибка вызвана намеренно параметром __fail');
  }

  // ── служебные ──
  if (path === '/api/__reset' && method === 'POST') {
    seed();
    return send(res, 200, { message: 'Данные восстановлены в исходное состояние' });
  }

  if (path === '/api/__health' && method === 'GET') {
    return send(res, 200, { status: 'ok', time: new Date().toISOString() });
  }

  // ── аутентификация ──
  if (path === '/api/auth/login' && method === 'POST') {
    const body = await readBody(req);
    if (!body) return fail(res, 400, 'Тело запроса не является корректным JSON');
    const found = db.users.find((u) => u.login === body.login && u.passwordHash === hash(String(body.password || '')));
    if (!found) return fail(res, 401, 'Неверный логин или пароль');
    if (found.deletedAt) return fail(res, 403, 'Учётная запись заблокирована администратором');
    return send(res, 200, issueTokens(found));
  }

  if (path === '/api/auth/register' && method === 'POST') {
    const body = await readBody(req);
    if (!body) return fail(res, 400, 'Тело запроса не является корректным JSON');
    const errors = {};
    const login = String(body.login || '').trim();
    const password = String(body.password || '');
    const name = String(body.name || '').trim();
    if (!LOGIN_RE.test(login)) errors.login = 'Логин: 3–20 латинских букв, цифр или знаков _ . -';
    else if (db.users.some((u) => u.login === login)) errors.login = 'Такой логин уже занят';
    if (!PASSWORD_RE.test(password)) errors.password = 'Пароль: не короче 8 символов, с цифрой и спецсимволом';
    if (name.length < 2) errors.name = 'Укажите имя';
    if (Object.keys(errors).length) return failValidation(res, errors);
    const user = { id: nextId('users'), login, passwordHash: hash(password), role: 'client', name, customerId: null, deletedAt: null };
    db.users.push(user);
    return send(res, 201, issueTokens(user));
  }

  if (path === '/api/auth/refresh' && method === 'POST') {
    const body = await readBody(req);
    const token = body && body.refreshToken;
    const payload = token && db.refreshTokens.has(token) ? verify(token) : null;
    const user = payload && payload.type === 'refresh'
      ? db.users.find((u) => u.id === payload.sub && !u.deletedAt)
      : null;
    if (token) db.refreshTokens.delete(token);
    if (!user) return fail(res, 401, 'Сессия истекла, войдите заново');
    return send(res, 200, issueTokens(user));
  }

  if (path === '/api/auth/me' && method === 'GET') {
    const user = currentUser(req);
    if (!user) return fail(res, 401, 'Требуется аутентификация');
    return send(res, 200, expandUser(user));
  }

  if (path === '/api/auth/logout' && method === 'POST') {
    const body = await readBody(req);
    if (body && body.refreshToken) db.refreshTokens.delete(body.refreshToken);
    return send(res, 204);
  }

  // ── личный кабинет покупателя ──
  if (path === '/api/my/orders' && method === 'GET') {
    const user = requireRole(req, res, ['client']);
    if (!user) return;
    const rows = alive('orders').filter((o) => o.customerId === user.customerId);
    return send(res, 200, { items: rows.map(EXPANDERS.orders), total: rows.length, page: 1, size: rows.length || 1 });
  }

  const myCancel = path.match(/^\/api\/my\/orders\/(\d+)\/cancel$/);
  if (myCancel && method === 'POST') {
    const user = requireRole(req, res, ['client']);
    if (!user) return;
    const order = byId('orders', Number(myCancel[1]));
    if (!order || order.deletedAt || order.customerId !== user.customerId) {
      return fail(res, 403, 'Можно отменять только собственные заказы');
    }
    if (order.status !== 'Новый') return fail(res, 409, `Заказ в статусе «${order.status}» отменить нельзя`);
    order.status = 'Отменён';
    const sneaker = byId('sneakers', order.sneakerId);
    if (sneaker) sneaker.stockAvailable += order.quantity;
    return send(res, 200, EXPANDERS.orders(order));
  }

  // ── администрирование ──
  if (path === '/api/users' && method === 'GET') {
    if (!requireRole(req, res, ADMIN)) return;
    return send(res, 200, { items: db.users.map(expandUser), total: db.users.length, page: 1, size: db.users.length });
  }

  const userRoute = path.match(/^\/api\/users\/(\d+)$/);
  if (userRoute && method === 'PUT') {
    const admin = requireRole(req, res, ADMIN);
    if (!admin) return;
    const target = db.users.find((u) => u.id === Number(userRoute[1]));
    if (!target) return fail(res, 404, 'Пользователь не найден');
    const body = (await readBody(req)) || {};
    if (target.id === admin.id && (body.role !== undefined || body.blocked)) {
      return fail(res, 409, 'Нельзя менять роль или блокировать самого себя');
    }
    if (body.role !== undefined) {
      if (!ROLES.includes(body.role)) return failValidation(res, { role: 'Неизвестная роль' });
      target.role = body.role;
    }
    if (body.blocked !== undefined) target.deletedAt = body.blocked ? new Date().toISOString() : null;
    return send(res, 200, expandUser(target));
  }

  if (path === '/api/stats' && method === 'GET') {
    if (!requireRole(req, res, ADMIN)) return;
    const orders = alive('orders');
    const revenue = orders
      .filter((o) => o.status !== 'Отменён')
      .reduce((sum, o) => sum + o.price * o.quantity, 0);
    const byStatus = Object.fromEntries(ORDER_STATUSES.map((s) => [s, orders.filter((o) => o.status === s).length]));
    const counts = Object.fromEntries(COLLECTIONS.map((c) => [c, alive(c).length]));
    const deleted = Object.fromEntries(COLLECTIONS.map((c) => [c, db[c].length - alive(c).length]));
    const users = Object.fromEntries(ROLES.map((r) => [r, db.users.filter((u) => u.role === r).length]));
    return send(res, 200, { revenue, byStatus, counts, deleted, users });
  }

  // ── множественное удаление ──
  const bulk = path.match(/^\/api\/([a-z]+)\/bulk-delete$/);
  if (bulk && method === 'POST') {
    if (!requireRole(req, res, MANAGER)) return;
    const collection = bulk[1];
    if (!COLLECTIONS.includes(collection)) return fail(res, 404, 'Ресурс не найден');
    const body = await readBody(req);
    if (!body || !Array.isArray(body.ids)) return fail(res, 400, 'Ожидается поле ids со списком идентификаторов');
    let deleted = 0;
    for (const rawId of body.ids) {
      const row = byId(collection, Number(rawId));
      if (!row || row.deletedAt) continue;
      if (referenceCount(collection, row.id) > 0) continue;
      row.deletedAt = new Date().toISOString();
      deleted += 1;
    }
    return send(res, 200, { deleted });
  }

  const m = path.match(ROUTE_RE);
  if (!m) return fail(res, 404, 'Ресурс не найден');

  const collection = m[1];
  const id = m[2] ? Number(m[2]) : null;
  const action = m[3] || null;
  if (!COLLECTIONS.includes(collection)) return fail(res, 404, 'Ресурс не найден');
  const expand = EXPANDERS[collection];

  if (!requireRole(req, res, allowedRoles(collection, method, action, q))) return;

  if (action === 'restore' && method === 'POST') {
    const row = byId(collection, id);
    if (!row) return fail(res, 404, 'Объект не найден');
    row.deletedAt = null;
    return send(res, 200, expand(row));
  }

  if (id === null && method === 'GET') {
    let rows = q.includeDeleted === 'true' ? db[collection] : alive(collection);
    rows = applyFilters(collection, rows, q);
    rows = applySort(collection, rows, q.sort);
    const page = paginate(rows, q);
    return send(res, 200, { ...page, items: page.items.map(expand) });
  }

  if (id !== null && method === 'GET') {
    const row = byId(collection, id);
    if (!row || (row.deletedAt && q.includeDeleted !== 'true')) return fail(res, 404, 'Объект не найден');
    return send(res, 200, expand(row));
  }

  if (id === null && method === 'POST') {
    const body = await readBody(req);
    if (!body) return fail(res, 400, 'Тело запроса не является корректным JSON');
    const errors = validate(collection, body);
    if (Object.keys(errors).length) return failValidation(res, errors);

    if (collection === 'orders') {
      const sneaker = byId('sneakers', Number(body.sneakerId));
      if (sneaker && sneaker.stockAvailable < Number(body.quantity)) {
        return fail(
          res,
          409,
          sneaker.stockAvailable === 0
            ? `Модель «${sneaker.name}» распродана: свободных пар нет`
            : `Свободных пар модели «${sneaker.name}»: ${sneaker.stockAvailable}`
        );
      }
    }

    const row = { id: nextId(collection), ...buildPayload(collection, body), deletedAt: null };
    db[collection].push(row);
    if (collection === 'orders') {
      const sneaker = byId('sneakers', row.sneakerId);
      if (sneaker) sneaker.stockAvailable -= row.quantity;
    }
    return send(res, 201, expand(row));
  }

  if (id !== null && method === 'PUT') {
    const row = byId(collection, id);
    if (!row) return fail(res, 404, 'Объект не найден');
    const body = await readBody(req);
    if (!body) return fail(res, 400, 'Тело запроса не является корректным JSON');
    const errors = validate(collection, body, id);
    if (Object.keys(errors).length) return failValidation(res, errors);
    Object.assign(row, buildPayload(collection, body));
    return send(res, 200, expand(row));
  }

  if (id !== null && method === 'DELETE') {
    const row = byId(collection, id);
    if (!row) return fail(res, 404, 'Объект не найден');
    const count = referenceCount(collection, id);
    if (count > 0) {
      return fail(res, 409, `Запись нельзя удалить: на неё ссылается связанных записей — ${count}`);
    }
    if (q.hard === 'true') {
      db[collection] = db[collection].filter((x) => x.id !== id);
    } else {
      row.deletedAt = new Date().toISOString();
    }
    return send(res, 204);
  }

  return fail(res, 404, 'Ресурс не найден');
}

// ─────────────────────────────── запуск ───────────────────────────────

seed();

const server = http.createServer(async (req, res) => {
  const url = new URL(req.url, `http://${req.headers.host || 'localhost'}`);
  res.requestOrigin = req.headers.origin || null;

  if (req.method === 'OPTIONS') {
    cors(res);
    res.writeHead(204);
    return res.end();
  }

  const delay = Number(url.searchParams.get('__delay') || 0);
  if (delay > 0) await new Promise((r) => setTimeout(r, Math.min(delay, 10000)));

  const started = Date.now();
  try {
    await handle(req, res, url);
  } catch (err) {
    console.error(err);
    if (!res.headersSent) fail(res, 500, 'Внутренняя ошибка сервера: ' + err.message);
  }
  console.log(
    `${req.method.padEnd(6)} ${url.pathname}${url.search}  → ${res.statusCode}  ${Date.now() - started} мс`
  );
});

server.listen(PORT, () => {
  console.log('');
  console.log('  Учебное API «Магазин кроссовок»');
  console.log(`  Адрес:                http://localhost:${PORT}/api`);
  console.log(`  Разрешённый источник: ${ORIGIN}`);
  console.log('');
  console.log('  Проверка живости:     GET  /api/__health');
  console.log('  Сброс данных:         POST /api/__reset');
  console.log('  Задержка ответа:      любой запрос с ?__delay=1500');
  console.log('  Ошибка по требованию: любой запрос с ?__fail=500');
  console.log('');
});
