import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'translations.dart';

class SupportedLanguage {
  final String code;
  final String name;
  final String flag;
  final bool isRtl;

  const SupportedLanguage({
    required this.code,
    required this.name,
    required this.flag,
    this.isRtl = false,
  });
}

class AppLocale extends ChangeNotifier {
  static final AppLocale instance = AppLocale._();
  AppLocale._();

  static const String _keyLang = 'empathiq_language_code';

  static const List<SupportedLanguage> supportedLanguages = [
    SupportedLanguage(code: 'en', name: 'English', flag: '🇺🇸'),
    SupportedLanguage(code: 'zh', name: '简体中文', flag: '🇨🇳'),
    SupportedLanguage(code: 'ja', name: '日本語', flag: '🇯🇵'),
    SupportedLanguage(code: 'ko', name: '한국어', flag: '🇰🇷'),
    SupportedLanguage(code: 'es', name: 'Español', flag: '🇪🇸'),
    SupportedLanguage(code: 'ar', name: 'العربية', flag: '🇸🇦', isRtl: true),
  ];

  String _currentCode = 'en'; // Default primary is English!

  String get currentCode => _currentCode;

  SupportedLanguage get currentLanguage {
    return supportedLanguages.firstWhere(
      (l) => l.code == _currentCode,
      orElse: () => supportedLanguages[0],
    );
  }

  bool get isRTL => currentLanguage.isRtl;

  TextDirection get textDirection =>
      isRTL ? TextDirection.rtl : TextDirection.ltr;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_keyLang);
    if (saved != null &&
        supportedLanguages.any((element) => element.code == saved)) {
      _currentCode = saved;
    } else {
      _currentCode = 'en'; // Default primary: English
    }
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    if (_currentCode == code) return;
    if (!supportedLanguages.any((element) => element.code == code)) return;
    _currentCode = code;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLang, code);
  }

  String t(String key, [List<String>? args]) {
    final langMap = Translations.values[_currentCode] ?? Translations.values['en']!;
    var str = langMap[key] ?? Translations.values['en']?[key] ?? key;
    if (args != null) {
      for (int i = 0; i < args.length; i++) {
        str = str.replaceAll('{$i}', args[i]);
      }
    }
    return str;
  }
}

// Global convenience accessor
String tr(String key, [List<String>? args]) => AppLocale.instance.t(key, args);
