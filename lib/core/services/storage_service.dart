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

  // --- Daily Quota Management ---
  int getRemainingDailyQuota() {
    final today = _getTodayString();
    final savedDate = _prefs?.getString(_keyDailyDate);
    if (savedDate != today) {
      // New day, reset quota
      _prefs?.setString(_keyDailyDate, today);
      _prefs?.setInt(_keyDailyUsed, 0);
      return maxFreeDailyQuota;
    }
    final used = _prefs?.getInt(_keyDailyUsed) ?? 0;
    final remaining = maxFreeDailyQuota - used;
    return remaining < 0 ? 0 : remaining;
  }

  Future<bool> consumeDailyQuota() async {
    final remaining = getRemainingDailyQuota();
    if (remaining <= 0) return false;
    final used = _prefs?.getInt(_keyDailyUsed) ?? 0;
    await _prefs?.setInt(_keyDailyUsed, used + 1);
    return true;
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

  Future<void> saveSettings(AppSettings settings) async {
    final jsonStr = jsonEncode(settings.toMap());
    await _prefs?.setString(_keySettings, jsonStr);
  }
}
