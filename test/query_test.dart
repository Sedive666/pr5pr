import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoe_store/core/auth_api.dart';
import 'package:shoe_store/main.dart';
import 'package:shoe_store/models/app_user.dart';
import 'package:shoe_store/router.dart';
import 'package:shoe_store/state/auth_notifier.dart';

import 'fake_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthNotifier auth;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    auth = AuthNotifier.signedIn(
      await SharedPreferences.getInstance(),
      AuthApi(),
      const AppUser(
        id: 2,
        login: 'manager',
        name: 'Менеджер',
        role: Role.manager,
      ),
    );
  });

  ShoeStoreApp app(String location) => ShoeStoreApp(
    auth: auth,
    dio: fakeDio(),
    router: createRouter(auth, initialLocation: location),
  );

  Future<void> open(WidgetTester tester, String location) async {
    tester.view.physicalSize = const Size(1400, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app(location));
    await tester.pumpAndSettle();
  }

  testWidgets('список восстанавливается из адреса', (tester) async {
    await open(tester, '/sneakers?search=ultraboost');
    expect(find.text('Adidas Ultraboost 22'), findsOneWidget);
    expect(find.text('Всего записей: 1'), findsOneWidget);
  });

  testWidgets('пустой результат', (tester) async {
    await open(tester, '/sneakers?search=zzz');
    expect(find.text('Ничего не найдено'), findsOneWidget);
  });

  testWidgets('состояние ошибки отличается от пустого', (tester) async {
    await open(tester, '/sneakers?fail=1');
    expect(find.text('Ошибка загрузки'), findsOneWidget);
    expect(find.text('Ничего не найдено'), findsNothing);
  });

  testWidgets('форма создания проверяет обязательные поля', (tester) async {
    await open(tester, '/sneakers/new');
    await tester.tap(find.text('Создать'));
    await tester.pumpAndSettle();
    expect(find.text('Поле обязательно для заполнения'), findsWidgets);
    expect(find.text('Выберите бренд'), findsOneWidget);
    expect(find.text('Выберите хотя бы одну категорию'), findsOneWidget);
  });

  testWidgets('форма редактирования заполнена данными записи', (tester) async {
    await open(tester, '/sneakers/1/edit');
    expect(find.text('Nike Air Max 90'), findsWidgets);
    expect(find.text('CN8490-002'), findsWidgets);
  });

  testWidgets('уход с изменённой формы требует подтверждения', (tester) async {
    await open(tester, '/brands/new');
    await tester.enterText(find.byType(TextFormField).first, 'Puma');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();
    expect(find.text('Несохранённые изменения'), findsOneWidget);
  });

  testWidgets('узкое окно показывает карточки', (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app('/categories'));
    await tester.pumpAndSettle();
    expect(find.byType(Card), findsWidgets);
    expect(find.byType(DataTable), findsNothing);
  });
}
