import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:empathiq/main.dart';
import 'package:empathiq/core/localization/app_locale.dart';
import 'package:empathiq/features/home/screens/home_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('EmpathIQ LandingScreen displays hero branding and guest button', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await AppLocale.instance.init();
    await AppLocale.instance.setLanguage('en');
    await tester.pumpWidget(const EmpathIQApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('EmpathIQ'), findsOneWidget);
    expect(find.text('AI-Powered Social EQ & Subtext Intelligence'), findsOneWidget);
    final guestBtn = find.text('🚀 Explore Instantly (3 Free Scans/Day)');
    expect(guestBtn, findsOneWidget);

    // Scroll until visible and tap guest button to enter HomeScreen
    await tester.ensureVisible(guestBtn);
    await tester.tap(guestBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify HomeScreen is now visible
    expect(find.text('Subtext Decoder'), findsOneWidget);
    expect(find.text('Decode Subtext'), findsOneWidget);
  });

  testWidgets('Live language switch on LandingScreen immediately updates copy in place', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await AppLocale.instance.init();
    await AppLocale.instance.setLanguage('en');
    await tester.pumpWidget(const EmpathIQApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('AI-Powered Social EQ & Subtext Intelligence'), findsOneWidget);

    // Switch to Chinese in real time
    await AppLocale.instance.setLanguage('zh');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('AI-Powered Social EQ & Subtext Intelligence'), findsNothing);
    expect(find.text('新一代社交心理学与情商透视引擎'), findsOneWidget);
    expect(find.text('🚀 免登录即刻探索 (每日3次免费)'), findsOneWidget);

    // Switch to Japanese in real time
    await AppLocale.instance.setLanguage('ja');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('新一代社交心理学与情商透视引擎'), findsNothing);
    expect(find.text('次世代ソーシャル心理学＆本音解析エンジン'), findsOneWidget);
  });

  testWidgets('HomeScreen live language switch updates without restart', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await AppLocale.instance.init();
    await AppLocale.instance.setLanguage('en');
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial English
    expect(find.text('Subtext Decoder'), findsOneWidget);
    expect(find.text('Decode Subtext'), findsOneWidget);

    // Switch to Chinese in real time
    await AppLocale.instance.setLanguage('zh');
    await tester.pumpAndSettle();

    expect(find.text('Subtext Decoder'), findsNothing);
    expect(find.text('潜台词解码器'), findsOneWidget);
    expect(find.text('一键透视潜台词'), findsOneWidget);

    // Switch to Spanish in real time
    await AppLocale.instance.setLanguage('es');
    await tester.pumpAndSettle();

    expect(find.text('潜台词解码器'), findsNothing);
    expect(find.text('Decodificador de Subtexto'), findsOneWidget);
    expect(find.text('Decodificar Subtexto'), findsOneWidget);
  });
}
