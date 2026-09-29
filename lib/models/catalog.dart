const brands = {1: 'Nike', 2: 'Adidas', 3: 'New Balance'};

const categories = {
  1: 'Беговые',
  2: 'Баскетбольные',
  3: 'Повседневные',
  4: 'Скейтбординг',
};

String formatPrice(int value) => value.toString().replaceAllMapped(
  RegExp(r'\B(?=(\d{3})+(?!\d))'),
  (_) => ' ',
);
