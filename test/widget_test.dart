import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:empathiq/main.dart';
import 'package:empathiq/core/localization/app_locale.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('EmpathIQ app basic smoke test with default English', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await AppLocale.instance.init();
    await tester.pumpWidget(const EmpathIQApp());
    await tester.pumpAndSettle();

    expect(find.text('EmpathIQ'), findsOneWidget);
    expect(find.text('Subtext Decoder'), findsOneWidget);
    expect(find.text('Decode Subtext'), findsOneWidget);
    expect(find.text("Partner's Silent Code: 'Whatever, Suit Yourself'"), findsOneWidget);
  });

  testWidgets('EmpathIQ dynamic language switch to Chinese', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await AppLocale.instance.init();
    await AppLocale.instance.setLanguage('zh');
    await tester.pumpWidget(const EmpathIQApp());
    await tester.pumpAndSettle();

    expect(find.text('EmpathIQ'), findsOneWidget);
    expect(find.text('潜台词解码器'), findsOneWidget);
    expect(find.text('一键透视潜台词'), findsOneWidget);
    expect(find.text('伴侣的冷战暗号：【随你便吧】'), findsOneWidget);
  });

  testWidgets('Live language switch while app is mounted immediately re-renders UI without refresh', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await AppLocale.instance.init();
    await AppLocale.instance.setLanguage('en');
    await tester.pumpWidget(const EmpathIQApp());
    await tester.pumpAndSettle();

    // Verify initial English
    expect(find.text('Subtext Decoder'), findsOneWidget);
    expect(find.text('Decode Subtext'), findsOneWidget);
    expect(find.text("Partner's Silent Code: 'Whatever, Suit Yourself'"), findsOneWidget);

    // Switch to Chinese in real time WITHOUT remounting app
    await AppLocale.instance.setLanguage('zh');
    await tester.pumpAndSettle();

    // Verify immediate re-render to Chinese
    expect(find.text('Subtext Decoder'), findsNothing);
    expect(find.text('潜台词解码器'), findsOneWidget);
    expect(find.text('一键透视潜台词'), findsOneWidget);
    expect(find.text('伴侣的冷战暗号：【随你便吧】'), findsOneWidget);

    // Switch to Japanese in real time
    await AppLocale.instance.setLanguage('ja');
    await tester.pumpAndSettle();

    expect(find.text('潜台词解码器'), findsNothing);
    expect(find.text('本音デコーダー'), findsOneWidget);
    expect(find.text('本音を読み解く'), findsOneWidget);

    // Switch to Spanish in real time
    await AppLocale.instance.setLanguage('es');
    await tester.pumpAndSettle();

    expect(find.text('本音デコーダー'), findsNothing);
    expect(find.text('Decodificador de Subtexto'), findsOneWidget);
    expect(find.text('Decodificar Subtexto'), findsOneWidget);
  });

  testWidgets('Tapping LanguageSelectorButton opens sheet and switches language instantly in place', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await AppLocale.instance.init();
    await AppLocale.instance.setLanguage('en');
    await tester.pumpWidget(const EmpathIQApp());
    await tester.pumpAndSettle();

    expect(find.text('Subtext Decoder'), findsOneWidget);

    // Tap language selector dropdown button (showing 'English')
    final langButton = find.text('English');
    expect(langButton, findsOneWidget);
    await tester.tap(langButton);
    await tester.pumpAndSettle();

    // The bottom sheet should now be visible with all languages
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('简体中文'), findsOneWidget);

    // Tap '简体中文'
    await tester.tap(find.text('简体中文'));
    await tester.pumpAndSettle();

    // Verify sheet closed and HomeScreen immediately displays Chinese
    expect(find.text('Subtext Decoder'), findsNothing);
    expect(find.text('潜台词解码器'), findsOneWidget);
    expect(find.text('一键透视潜台词'), findsOneWidget);
  });
}
