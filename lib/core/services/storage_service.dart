import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../models/decode_result.dart';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _instance = StorageService._();
      _prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  static const String _keyHistory = 'empathiq_history';
  static const String _keyDailyDate = 'empathiq_daily_date';
  static const String _keyDailyUsed = 'empathiq_daily_used';
  static const String _keyCheckinDate = 'empathiq_checkin_date';
  static const String _keySettings = 'empathiq_settings';
  static const int maxFreeDailyQuota = 3;

  String _getTodayString() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  static const String _keyUserIsPro = 'empathiq_user_is_pro';
  static const String _keyProPlan = 'empathiq_pro_plan';
  static const String _keyEmergencyScans = 'empathiq_emergency_scans';

  // --- Pro Subscription & Purchases ---
  bool isUserPro() {
    return _prefs?.getBool(_keyUserIsPro) ?? false;
  }

  String? getProPlan() {
    return _prefs?.getString(_keyProPlan);
  }

  int getEmergencyScans() {
    return _prefs?.getInt(_keyEmergencyScans) ?? 0;
  }

  Future<void> setUserPro(bool isPro, {String? plan}) async {
    await _prefs?.setBool(_keyUserIsPro, isPro);
    if (plan != null) {
      await _prefs?.setString(_keyProPlan, plan);
    } else if (!isPro) {
      await _prefs?.remove(_keyProPlan);
    }
  }

  Future<void> addEmergencyScans(int count) async {
    final current = getEmergencyScans();
    await _prefs?.setInt(_keyEmergencyScans, current + count);
  }

  // --- Daily Quota Management ---
  int getRemainingDailyQuota() {
    if (isUserPro()) {
      return 999;
    }
    final today = _getTodayString();
    final savedDate = _prefs?.getString(_keyDailyDate);
    if (savedDate != today) {
      // New day, reset quota
      _prefs?.setString(_keyDailyDate, today);
      _prefs?.setInt(_keyDailyUsed, 0);
      return maxFreeDailyQuota + getEmergencyScans();
    }
    final used = _prefs?.getInt(_keyDailyUsed) ?? 0;
    final remaining = maxFreeDailyQuota - used;
    final freeRemaining = remaining < 0 ? 0 : remaining;
    return freeRemaining + getEmergencyScans();
  }

  Future<bool> consumeDailyQuota() async {
    if (isUserPro()) {
      return true;
    }
    final used = _prefs?.getInt(_keyDailyUsed) ?? 0;
    if (used < maxFreeDailyQuota) {
      await _prefs?.setInt(_keyDailyUsed, used + 1);
      return true;
    }
    final emergency = getEmergencyScans();
    if (emergency > 0) {
      await _prefs?.setInt(_keyEmergencyScans, emergency - 1);
      return true;
    }
    return false;
  }

  Future<void> resetDailyQuota() async {
    final today = _getTodayString();
    await _prefs?.setString(_keyDailyDate, today);
    await _prefs?.setInt(_keyDailyUsed, 0);
  }

  // --- Daily Check-in ---
  bool hasCheckedInToday() {
    final today = _getTodayString();
    return _prefs?.getString(_keyCheckinDate) == today;
  }

  Future<void> checkInToday() async {
    final today = _getTodayString();
    await _prefs?.setString(_keyCheckinDate, today);
  }

  // --- History Management (Max 10 records) ---
  List<DecodeResult> getHistory() {
    final rawList = _prefs?.getStringList(_keyHistory) ?? [];
    final List<DecodeResult> results = [];
    for (final jsonStr in rawList) {
      try {
        results.add(DecodeResult.fromJson(jsonStr));
      } catch (e) {
        // Skip corrupted entries
      }
    }
    // Return sorted newest first
    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return results;
  }

  Future<void> saveDecodeResult(DecodeResult result) async {
    final currentHistory = getHistory();
    // Prepend new item
    currentHistory.removeWhere((item) => item.id == result.id);
    currentHistory.insert(0, result);

    // Keep only latest 10
    final limited = currentHistory.take(10).toList();
    final rawList = limited.map((item) => item.toJson()).toList();
    await _prefs?.setStringList(_keyHistory, rawList);
  }

  Future<void> deleteHistoryItem(String id) async {
    final currentHistory = getHistory();
    currentHistory.removeWhere((item) => item.id == id);
    final rawList = currentHistory.map((item) => item.toJson()).toList();
    await _prefs?.setStringList(_keyHistory, rawList);
  }

  // --- Settings Management ---
  AppSettings getSettings() {
    final jsonStr = _prefs?.getString(_keySettings);
    if (jsonStr == null || jsonStr.isEmpty) {
      return const AppSettings();
    }
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return AppSettings.fromMap(map);
    } catch (_) {
      return const AppSettings();
    }
  }

  static const String _keyUserLoggedIn = 'empathiq_user_logged_in';
  static const String _keyUserEmail = 'empathiq_user_email';

  Future<void> saveSettings(AppSettings settings) async {
    final jsonStr = jsonEncode(settings.toMap());
    await _prefs?.setString(_keySettings, jsonStr);
  }

  // --- User Account & Auth Session ---
  bool isUserLoggedIn() {
    return _prefs?.getBool(_keyUserLoggedIn) ?? false;
  }

  String? getUserEmail() {
    return _prefs?.getString(_keyUserEmail);
  }

  Future<void> setUserLoggedIn(String email) async {
    await _prefs?.setBool(_keyUserLoggedIn, true);
    await _prefs?.setString(_keyUserEmail, email);
  }

  Future<void> setUserLoggedOut() async {
    await _prefs?.setBool(_keyUserLoggedIn, false);
    await _prefs?.remove(_keyUserEmail);
  }
}
