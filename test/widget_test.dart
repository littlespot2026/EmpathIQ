import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:empathiq/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('EmpathIQ app basic smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const EmpathIQApp());
    await tester.pumpAndSettle();

    expect(find.text('EmpathIQ'), findsOneWidget);
    expect(find.text('潜台词解码器'), findsOneWidget);
    expect(find.text('一键透视潜台词'), findsOneWidget);
  });
}
