import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:empathiq/main.dart';
import 'package:empathiq/core/localization/app_locale.dart';
import 'package:empathiq/core/models/decode_result.dart';
import 'package:empathiq/core/services/storage_service.dart';
import 'package:empathiq/features/decoder/widgets/strategy_card.dart';
import 'package:empathiq/features/decoder/screens/decoder_result_screen.dart';
import 'package:empathiq/features/home/screens/home_screen.dart';
import 'package:empathiq/features/legal/widgets/legal_policy_dialog.dart';
import 'package:empathiq/features/subscription/widgets/pro_paywall_modal.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('EmpathIQ LandingScreen displays hero branding and guest button', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await AppLocale.instance.init();
    await AppLocale.instance.setLanguage('en');
    await tester.pumpWidget(const EmpathIQApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2000));

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

  testWidgets('Fluid dynamic opening animation and replay trigger function smoothly', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await AppLocale.instance.init();
    await AppLocale.instance.setLanguage('en');
    await tester.pumpWidget(const EmpathIQApp());
    await tester.pump();

    // Advance animation past 1800ms to settle intro overlay
    await tester.pump(const Duration(milliseconds: 2000));

    final replayBtn = find.text('🌊 Replay Fluid Reveal Animation');
    expect(replayBtn, findsOneWidget);

    // Scroll until visible and tap replay
    await tester.ensureVisible(replayBtn);
    await tester.tap(replayBtn);
    await tester.pump();

    // Now overlay is playing again
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Tap anywhere to skip'), findsOneWidget);

    // Fast-forward past completion
    await tester.pump(const Duration(milliseconds: 1500));
    expect(find.text('Tap anywhere to skip'), findsNothing);

    // Switch to Chinese and check replay label
    await AppLocale.instance.setLanguage('zh');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('🌊 重新播放流体开场动效'), findsOneWidget);
  });

  testWidgets('Pro Paywall modal and StrategyCard frosted lock gating function correctly', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await AppLocale.instance.init();
    await AppLocale.instance.setLanguage('en');

    final testStrategyA = DecodeStrategy(
      type: 'empathy',
      title: 'Safe Empathy',
      actionText: 'I understand your perspective.',
      mechanism: 'Validates emotions safely.',
    );
    final testStrategyB = DecodeStrategy(
      type: 'humor',
      title: 'Disarming Humor',
      actionText: 'Did we secretly agree on that?',
      mechanism: 'Dissolves tension with light wit.',
    );

    // Render StrategyCard index 0 (Free) and index 1 (Locked)
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                StrategyCard(strategy: testStrategyA, index: 0),
                StrategyCard(strategy: testStrategyB, index: 1),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Strategy A is unlocked
    expect(find.text('I understand your perspective.'), findsOneWidget);

    // Strategy B is locked with Pro badge
    expect(find.text('🔒 Pro Tactical Play'), findsOneWidget);
    expect(find.text('✨ Unlock (3-Day Free Trial)'), findsOneWidget);

    // Tap unlock button to open ProPaywallModal
    await tester.tap(find.text('✨ Unlock (3-Day Free Trial)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Verify Paywall modal is open with pricing options
    expect(find.text('EmpathIQ Pro'), findsOneWidget);
    expect(find.text('Yearly Pass'), findsOneWidget);
    expect(find.text('Weekly Access'), findsOneWidget);

    final instantBtn = find.text('【Test】Instant Sandbox Checkout');
    expect(instantBtn, findsOneWidget);

    // Scroll until visible and tap
    await tester.ensureVisible(instantBtn);
    await tester.tap(instantBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1000));

    // Storage is now Pro
    final storage = await StorageService.getInstance();
    expect(storage.isUserPro(), isTrue);
    expect(StorageService.proStatusNotifier.value, isTrue);

    // Modal dismissed, verify Strategy B unblurs and reveals its text reactively!
    await tester.pumpAndSettle();
    expect(find.text('Did we secretly agree on that?'), findsOneWidget);

    // Tap copy button on Strategy A and verify feedback toast
    final copyBtn = find.text('Copy').first;
    await tester.tap(copyBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Tactical response copied! Go ahead and send it.'), findsOneWidget);

    // Let the 2-second copy checkmark timer expire cleanly
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('Chat screenshot OCR button renders and adapts across languages', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await AppLocale.instance.init();
    await AppLocale.instance.setLanguage('en');
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify upload screenshot button is visible in English
    expect(find.text('Upload Chat Screenshot'), findsOneWidget);
    expect(find.byIcon(Icons.add_photo_alternate_rounded), findsOneWidget);

    // Switch to Chinese and verify instant copy update
    await AppLocale.instance.setLanguage('zh');
    await tester.pumpAndSettle();

    expect(find.text('📷 上传聊天长截图'), findsOneWidget);
    expect(find.text('Upload Chat Screenshot'), findsNothing);
  });

  testWidgets('LegalPolicyDialog displays privacy policy, switches tabs to disclaimer, and shows crisis hotlines', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await AppLocale.instance.init();
    await AppLocale.instance.setLanguage('en');

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LegalPolicyDialog(initialTab: 'privacy'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Legal & Compliance title and Privacy content
    expect(find.text('Legal & Compliance'), findsOneWidget);
    expect(find.textContaining('No Cloud Storage Guarantee'), findsOneWidget);

    // Switch to Disclaimer tab
    final disclaimerTab = find.text('Disclaimer');
    expect(disclaimerTab, findsOneWidget);
    await tester.tap(disclaimerTab);
    await tester.pumpAndSettle();

    // Verify disclaimer content & crisis emergency numbers
    expect(find.textContaining('Crisis Hotline & Emergency Interventions'), findsOneWidget);
    expect(find.textContaining('988'), findsAtLeastNWidgets(1));

    // Switch to Terms tab
    final termsTab = find.text('Terms');
    expect(termsTab, findsOneWidget);
    await tester.tap(termsTab);
    await tester.pumpAndSettle();

    expect(find.textContaining('End User License Agreement'), findsOneWidget);
  });

  testWidgets('ProPaywallModal includes standard EULA/Privacy links and auto-renewable footnote', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await AppLocale.instance.init();
    await AppLocale.instance.setLanguage('en');

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProPaywallModal(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify auto-renewal footnote
    expect(find.textContaining('Recurring billing'), findsOneWidget);

    // Verify compliance links
    expect(find.text('Terms of Use (EULA)'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Psychological & Legal Disclaimer'), findsOneWidget);
  });

  testWidgets('DecoderResultScreen renders dynamic simulation engine badge vs live AI badge', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await AppLocale.instance.init();
    await AppLocale.instance.setLanguage('en');

    final mockResult = DecodeResult(
      id: 'mock-test-1',
      createdAt: DateTime.now(),
      inputText: 'Test input',
      relationship: 'Friend',
      temperature: 75,
      temperatureLevel: '易燃红',
      defensePercent: 60,
      surfaceMeaning: 'Surface meaning',
      realSubtext: 'Real subtext',
      corePainPoint: 'Need validation',
      strategies: const [],
      initialNpcThought: 'Inner thought',
      initialNpcSpeech: 'Speech',
      isMock: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: DecoderResultScreen(result: mockResult),
      ),
    );
    await tester.pumpAndSettle();

    // For isMock: true, badge shows Simulation Engine
    expect(find.text('Simulation Engine'), findsOneWidget);
    expect(find.text('Live Cognitive AI'), findsNothing);

    // For isMock: false, badge shows Live Cognitive AI
    final liveResult = DecodeResult(
      id: 'live-test-1',
      createdAt: DateTime.now(),
      inputText: 'Test input 2',
      relationship: 'Workplace',
      temperature: 40,
      temperatureLevel: '焦躁黄',
      defensePercent: 30,
      surfaceMeaning: 'Surface 2',
      realSubtext: 'Real 2',
      corePainPoint: 'Clarity',
      strategies: const [],
      initialNpcThought: 'Inner thought 2',
      initialNpcSpeech: 'Speech 2',
      isMock: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: DecoderResultScreen(result: liveResult),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Live Cognitive AI'), findsOneWidget);
  });
}

