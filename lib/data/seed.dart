import '../models/brand.dart';
import '../models/category.dart';
import '../models/customer.dart';
import '../models/order.dart';
import '../models/review.dart';
import '../models/series.dart';
import '../models/sneaker.dart';

const seedBrands = [
  Brand(id: 1, name: 'Nike', country: 'США', foundedYear: 1964),
  Brand(id: 2, name: 'Adidas', country: 'Германия', foundedYear: 1949),
  Brand(id: 3, name: 'New Balance', country: 'США', foundedYear: 1906),
];

const seedCategories = [
  Category(id: 1, name: 'Беговые', description: 'Для бега и тренировок'),
  Category(id: 2, name: 'Баскетбольные', description: 'Для игры в зале'),
  Category(id: 3, name: 'Повседневные', description: 'На каждый день'),
  Category(id: 4, name: 'Скейтбординг', description: 'Усиленная конструкция'),
  Category(id: 5, name: 'Ретро', description: 'Переиздания прошлых лет'),
];

const seedSeries = [
  Series(id: 1, name: 'Air Max', brandId: 1, country: 'США', launchYear: 1987),
  Series(id: 2, name: 'Air Force 1', brandId: 1, country: 'США', launchYear: 1982),
  Series(id: 3, name: 'Dunk', brandId: 1, country: 'США', launchYear: 1985),
  Series(id: 4, name: 'Air Jordan 1', brandId: 1, country: 'США', launchYear: 1985),
  Series(id: 5, name: 'Ultraboost', brandId: 2, country: 'Германия', launchYear: 2015),
  Series(id: 6, name: 'Samba', brandId: 2, country: 'Германия', launchYear: 1950),
  Series(id: 7, name: 'Gazelle', brandId: 2, country: 'Германия', launchYear: 1966),
  Series(id: 8, name: '574', brandId: 3, country: 'США', launchYear: 1988),
  Series(id: 9, name: '990', brandId: 3, country: 'США', launchYear: 1982),
  Series(id: 10, name: '2002R', brandId: 3, country: 'Япония', launchYear: 2010),
  Series(id: 11, name: 'Superstar', brandId: 2, country: 'Германия', launchYear: 1969),
  Series(id: 12, name: '991', brandId: 3, country: 'Великобритания', launchYear: 2001),
  Series(id: 13, name: 'SB', brandId: 1, country: 'США', launchYear: 2002),
];

const seedSneakers = [
  Sneaker(id: 1, name: 'Nike Air Max 90', sku: 'CN8490-002', year: 2020, price: 14990, brandId: 1, seriesIds: [1], categoryIds: [3, 5], stockTotal: 12, stockAvailable: 7),
  Sneaker(id: 2, name: 'Nike Air Max 97', sku: '921826-101', year: 2017, price: 18990, brandId: 1, seriesIds: [1], categoryIds: [3], stockTotal: 8, stockAvailable: 3),
  Sneaker(id: 3, name: 'Nike Air Max Plus', sku: '604133-139', year: 2019, price: 17490, brandId: 1, seriesIds: [1], categoryIds: [1, 3], stockTotal: 6, stockAvailable: 6),
  Sneaker(id: 4, name: "Nike Air Force 1 '07", sku: 'CW2288-111', year: 2021, price: 11990, brandId: 1, seriesIds: [2], categoryIds: [3], stockTotal: 20, stockAvailable: 15),
  Sneaker(id: 5, name: 'Nike Air Force 1 Mid', sku: 'DV0806-100', year: 2022, price: 13490, brandId: 1, seriesIds: [2], categoryIds: [3], stockTotal: 10, stockAvailable: 4),
  Sneaker(id: 6, name: 'Nike Dunk Low Panda', sku: 'DD1391-100', year: 2021, price: 12990, brandId: 1, seriesIds: [3, 13], categoryIds: [4, 3], stockTotal: 15, stockAvailable: 0),
  Sneaker(id: 7, name: 'Nike SB Dunk Low Pro', sku: 'BQ6817-100', year: 2019, price: 10990, brandId: 1, seriesIds: [3, 13], categoryIds: [4], stockTotal: 9, stockAvailable: 5),
  Sneaker(id: 8, name: 'Nike Dunk High Retro', sku: 'DD1399-105', year: 2022, price: 13990, brandId: 1, seriesIds: [3], categoryIds: [3, 5], stockTotal: 7, stockAvailable: 2),
  Sneaker(id: 9, name: 'Air Jordan 1 Retro High OG', sku: '555088-134', year: 2020, price: 21990, brandId: 1, seriesIds: [4], categoryIds: [2, 5], stockTotal: 5, stockAvailable: 1),
  Sneaker(id: 10, name: 'Air Jordan 1 Mid', sku: '554724-173', year: 2021, price: 15490, brandId: 1, seriesIds: [4], categoryIds: [2], stockTotal: 11, stockAvailable: 8),
  Sneaker(id: 11, name: 'Air Jordan 1 Low', sku: '553558-161', year: 2023, price: 12490, brandId: 1, seriesIds: [4], categoryIds: [3], stockTotal: 14, stockAvailable: 10),
  Sneaker(id: 12, name: 'Adidas Ultraboost 22', sku: 'GX5459', year: 2022, price: 17990, brandId: 2, seriesIds: [5], categoryIds: [1], stockTotal: 10, stockAvailable: 6),
  Sneaker(id: 13, name: 'Adidas Ultraboost Light', sku: 'HQ6351', year: 2023, price: 19990, brandId: 2, seriesIds: [5], categoryIds: [1], stockTotal: 8, stockAvailable: 8),
  Sneaker(id: 14, name: 'Adidas Ultraboost 1.0', sku: 'HQ4201', year: 2023, price: 16990, brandId: 2, seriesIds: [5], categoryIds: [1, 5], stockTotal: 6, stockAvailable: 2),
  Sneaker(id: 15, name: 'Adidas Samba OG', sku: 'B75806', year: 2018, price: 11990, brandId: 2, seriesIds: [6], categoryIds: [3, 5], stockTotal: 18, stockAvailable: 9),
  Sneaker(id: 16, name: 'Adidas Samba ADV', sku: 'GW3159', year: 2022, price: 10490, brandId: 2, seriesIds: [6], categoryIds: [4], stockTotal: 7, stockAvailable: 3),
  Sneaker(id: 17, name: 'Adidas Gazelle', sku: 'BB5476', year: 2017, price: 9990, brandId: 2, seriesIds: [7], categoryIds: [3, 5], stockTotal: 12, stockAvailable: 12),
  Sneaker(id: 18, name: 'Adidas Gazelle Indoor', sku: 'IG1640', year: 2024, price: 12490, brandId: 2, seriesIds: [7], categoryIds: [3], stockTotal: 9, stockAvailable: 4),
  Sneaker(id: 19, name: 'Adidas Superstar', sku: 'EG4958', year: 2019, price: 9490, brandId: 2, seriesIds: [11], categoryIds: [3, 5], stockTotal: 16, stockAvailable: 11),
  Sneaker(id: 20, name: 'New Balance 574 Core', sku: 'ML574EVG', year: 2020, price: 9990, brandId: 3, seriesIds: [8], categoryIds: [3], stockTotal: 14, stockAvailable: 9),
  Sneaker(id: 21, name: 'New Balance 574 Legacy', sku: 'U574LGG1', year: 2022, price: 10990, brandId: 3, seriesIds: [8], categoryIds: [3, 5], stockTotal: 8, stockAvailable: 5),
  Sneaker(id: 22, name: 'New Balance 990v6', sku: 'M990GL6', year: 2022, price: 24990, brandId: 3, seriesIds: [9], categoryIds: [1], stockTotal: 5, stockAvailable: 2),
  Sneaker(id: 23, name: 'New Balance 990v5', sku: 'M990GL5', year: 2019, price: 21990, brandId: 3, seriesIds: [9], categoryIds: [1, 5], stockTotal: 4, stockAvailable: 0),
  Sneaker(id: 24, name: 'New Balance 2002R', sku: 'M2002RXD', year: 2021, price: 15990, brandId: 3, seriesIds: [10], categoryIds: [1, 3], stockTotal: 9, stockAvailable: 6),
  Sneaker(id: 25, name: 'New Balance 2002R Protection Pack', sku: 'M2002RDA', year: 2022, price: 17990, brandId: 3, seriesIds: [10], categoryIds: [3], stockTotal: 6, stockAvailable: 3),
  Sneaker(id: 26, name: 'New Balance 991v2', sku: 'U991GL2', year: 2023, price: 27990, brandId: 3, seriesIds: [12], categoryIds: [3, 5], stockTotal: 4, stockAvailable: 4),
];

final seedCustomers = [
  Customer(
    id: 1,
    firstName: 'Иван',
    lastName: 'Петров',
    email: 'ivan.petrov@mail.ru',
    phone: '+7 916 123-45-67',
    city: 'Москва',
    card: LoyaltyCard(
      number: '10000001',
      level: 'Золотая',
      bonusPoints: 2400,
      issuedAt: DateTime(2023, 5, 12),
    ),
  ),
  Customer(
    id: 2,
    firstName: 'Анна',
    lastName: 'Смирнова',
    email: 'anna.smirnova@gmail.com',
    phone: '+7 903 555-12-34',
    city: 'Санкт-Петербург',
    card: LoyaltyCard(
      number: '10000002',
      level: 'Платиновая',
      bonusPoints: 7800,
      issuedAt: DateTime(2022, 11, 3),
    ),
  ),
  const Customer(
    id: 3,
    firstName: 'Дмитрий',
    lastName: 'Козлов',
    email: 'd.kozlov@yandex.ru',
    phone: '+7 925 777-88-99',
    city: 'Москва',
  ),
  Customer(
    id: 4,
    firstName: 'Мария',
    lastName: 'Волкова',
    email: 'maria.volkova@mail.ru',
    phone: '+7 911 222-33-44',
    city: 'Казань',
    card: LoyaltyCard(
      number: '10000004',
      level: 'Серебряная',
      bonusPoints: 450,
      issuedAt: DateTime(2024, 2, 20),
    ),
  ),
  const Customer(
    id: 5,
    firstName: 'Алексей',
    lastName: 'Новиков',
    email: 'alex.novikov@gmail.com',
    phone: '+7 952 404-10-10',
    city: 'Новосибирск',
  ),
  Customer(
    id: 6,
    firstName: 'Ольга',
    lastName: 'Егорова',
    email: 'olga.egorova@mail.ru',
    phone: '+7 937 616-20-20',
    city: 'Екатеринбург',
    card: LoyaltyCard(
      number: '10000006',
      level: 'Золотая',
      bonusPoints: 3100,
      issuedAt: DateTime(2023, 9, 1),
    ),
  ),
];

final seedOrders = [
  Order(id: 1, number: 'ORD-1001', customerId: 1, sneakerId: 4, size: 42, quantity: 1, price: 11990, status: 'Доставлен', createdAt: DateTime(2025, 3, 14)),
  Order(id: 2, number: 'ORD-1002', customerId: 2, sneakerId: 12, size: 38, quantity: 2, price: 17990, status: 'Отправлен', createdAt: DateTime(2025, 4, 2)),
  Order(id: 3, number: 'ORD-1003', customerId: 1, sneakerId: 22, size: 43, quantity: 1, price: 24990, status: 'Оплачен', createdAt: DateTime(2025, 4, 18)),
  Order(id: 4, number: 'ORD-1004', customerId: 3, sneakerId: 15, size: 41, quantity: 1, price: 11990, status: 'Новый', createdAt: DateTime(2025, 5, 7)),
  Order(id: 5, number: 'ORD-1005', customerId: 4, sneakerId: 9, size: 39, quantity: 1, price: 21990, status: 'Отменён', createdAt: DateTime(2025, 5, 21)),
  Order(id: 6, number: 'ORD-1006', customerId: 2, sneakerId: 19, size: 37, quantity: 3, price: 9490, status: 'Доставлен', createdAt: DateTime(2025, 6, 9)),
  Order(id: 7, number: 'ORD-1007', customerId: 5, sneakerId: 24, size: 44, quantity: 1, price: 15990, status: 'Оплачен', createdAt: DateTime(2025, 6, 30)),
  Order(id: 8, number: 'ORD-1008', customerId: 6, sneakerId: 17, size: 40, quantity: 2, price: 9990, status: 'Новый', createdAt: DateTime(2025, 7, 11)),
  Order(id: 9, number: 'ORD-1009', customerId: 1, sneakerId: 26, size: 42, quantity: 1, price: 27990, status: 'Отправлен', createdAt: DateTime(2025, 8, 3)),
  Order(id: 10, number: 'ORD-1010', customerId: 4, sneakerId: 6, size: 38, quantity: 1, price: 12990, status: 'Доставлен', createdAt: DateTime(2025, 8, 25)),
  Order(id: 11, number: 'ORD-1011', customerId: 3, sneakerId: 13, size: 43, quantity: 1, price: 19990, status: 'Новый', createdAt: DateTime(2025, 9, 6)),
  Order(id: 12, number: 'ORD-1012', customerId: 6, sneakerId: 1, size: 41, quantity: 2, price: 14990, status: 'Оплачен', createdAt: DateTime(2025, 9, 19)),
];

final seedReviews = [
  Review(id: 1, customerId: 1, sneakerId: 4, rating: 5, text: 'Классика, которая никогда не подведёт. Размер в размер.', createdAt: DateTime(2025, 3, 20)),
  Review(id: 2, customerId: 2, sneakerId: 12, rating: 4, text: 'Очень мягкие, но для узкой стопы великоваты.', createdAt: DateTime(2025, 4, 10)),
  Review(id: 3, customerId: 1, sneakerId: 22, rating: 5, text: 'Лучшие кроссовки для долгой ходьбы, ноги не устают.', createdAt: DateTime(2025, 4, 25)),
  Review(id: 4, customerId: 3, sneakerId: 15, rating: 4, text: 'Стильные, но подошва скользит на мокром асфальте.', createdAt: DateTime(2025, 5, 15)),
  Review(id: 5, customerId: 4, sneakerId: 9, rating: 3, text: 'Качество хорошее, но цена завышена.', createdAt: DateTime(2025, 5, 30)),
  Review(id: 6, customerId: 2, sneakerId: 19, rating: 5, text: 'Беру уже третью пару, лучше ничего не придумали.', createdAt: DateTime(2025, 6, 18)),
  Review(id: 7, customerId: 5, sneakerId: 24, rating: 4, text: 'Удобные, качество отличное, цвет как на фото.', createdAt: DateTime(2025, 7, 5)),
  Review(id: 8, customerId: 6, sneakerId: 17, rating: 5, text: 'Лёгкие и дышащие, идеальны на лето.', createdAt: DateTime(2025, 7, 20)),
  Review(id: 9, customerId: 1, sneakerId: 26, rating: 5, text: 'Дорого, но оправдано: обувь премиального уровня.', createdAt: DateTime(2025, 8, 12)),
  Review(id: 10, customerId: 4, sneakerId: 6, rating: 2, text: 'Пришли с царапиной на мыске, пришлось менять.', createdAt: DateTime(2025, 9, 1)),
  Review(id: 11, customerId: 3, sneakerId: 1, rating: 4, text: 'Хорошая амортизация, но шнурки коротковаты.', createdAt: DateTime(2025, 9, 14)),
  Review(id: 12, customerId: 6, sneakerId: 13, rating: 5, text: 'Бегаю каждый день, за три месяца износа нет.', createdAt: DateTime(2025, 9, 28)),
];
