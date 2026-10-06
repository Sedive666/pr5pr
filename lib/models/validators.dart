typedef Validator = String? Function(String?);

String? _trimmed(String? v) => v?.trim();

Validator notEmpty([String message = 'Поле обязательно для заполнения']) =>
    (v) => (_trimmed(v) ?? '').isEmpty ? message : null;

Validator length(int min, int max) => (v) {
  final text = _trimmed(v) ?? '';
  if (text.isEmpty) return null;
  if (text.length < min) return 'Не короче $min символов';
  if (text.length > max) return 'Не длиннее $max символов';
  return null;
};

Validator intRange(int min, int max) => (v) {
  final text = _trimmed(v) ?? '';
  if (text.isEmpty) return null;
  final n = int.tryParse(text);
  if (n == null) return 'Введите целое число';
  if (n < min || n > max) return 'Значение от $min до $max';
  return null;
};

Validator positive([String message = 'Значение должно быть больше нуля']) =>
    (v) {
      final n = int.tryParse(_trimmed(v) ?? '');
      return n != null && n <= 0 ? message : null;
    };

final _emailRe = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]{2,}$');
final _phoneRe = RegExp(r'^\+?\d[\d ()-]{9,17}$');
final _skuRe = RegExp(r'^[A-Za-z0-9-]{4,20}$');
final _cardRe = RegExp(r'^\d{8,16}$');

Validator pattern(RegExp re, String message) => (v) {
  final text = _trimmed(v) ?? '';
  return text.isEmpty || re.hasMatch(text) ? null : message;
};

Validator email() => pattern(_emailRe, 'Неверный формат почты');
Validator phone() => pattern(_phoneRe, 'Неверный формат телефона');
Validator sku() =>
    pattern(_skuRe, 'Артикул: 4–20 латинских букв, цифр и дефисов');
Validator cardNumber() => pattern(_cardRe, 'Номер карты: от 8 до 16 цифр');

Validator combine(List<Validator> validators) => (v) {
  for (final validate in validators) {
    final error = validate(v);
    if (error != null) return error;
  }
  return null;
};

