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
  });
}
