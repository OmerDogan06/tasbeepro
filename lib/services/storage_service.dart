import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/counter_data.dart';

class StorageService extends GetxService {
  late SharedPreferences _prefs;
  
  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }
  
  // Counter data
  Future<void> saveCounterData(CounterData data) async {
    final key = 'counter_${data.zikrId}';
    await _prefs.setString(key, jsonEncode(data.toJson()));
  }
  
  CounterData? getCounterData(String zikrId) {
    final key = 'counter_$zikrId';
    final jsonString = _prefs.getString(key);
    if (jsonString != null) {
      return CounterData.fromJson(jsonDecode(jsonString));
    }
    return null;
  }
  
  // Theme
  Future<void> saveThemeMode(String mode) async {
    await _prefs.setString('theme_mode', mode);
  }
  
  String getThemeMode() {
    return _prefs.getString('theme_mode') ?? 'system';
  }
  
  // Sound settings
  Future<void> saveSoundEnabled(bool enabled) async {
    await _prefs.setBool('sound_enabled', enabled);
  }
  
  bool getSoundEnabled() {
    return _prefs.getBool('sound_enabled') ?? true;
  }
  
  // Vibration settings
  Future<void> saveVibrationLevel(int level) async {
    await _prefs.setInt('vibration_level', level);
  }
  
  int getVibrationLevel() {
    return _prefs.getInt('vibration_level') ?? 1; // 0: off, 1: light, 2: medium
  }
  
  // Daily stats
  Future<void> saveDailyCount(int count) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    await _prefs.setInt('daily_count_$today', count);
  }
  
  int getDailyCount() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return _prefs.getInt('daily_count_$today') ?? 0;
  }
  
  // Tüm zikirlerden bugünkü toplam sayı hesapla
  int getTotalDailyCount() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    int total = 0;
    
    // Tüm zikir ID'leri için bugünkü sayıları topla
    final zikrIds = ['subhanallah', 'alhamdulillah', 'allahu_akbar', 'la_ilahe_illallah', 'estaghfirullah'];
    for (String zikrId in zikrIds) {
      final dailyKey = 'daily_${zikrId}_$today';
      total += _prefs.getInt(dailyKey) ?? 0;
    }
    
    return total;
  }
  
  // Zikir bazında günlük sayım kaydet
  Future<void> saveDailyZikrCount(String zikrId, int count) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    await _prefs.setInt('daily_${zikrId}_$today', count);
  }
  
  // Zikir bazında günlük sayım al
  int getDailyZikrCount(String zikrId) {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return _prefs.getInt('daily_${zikrId}_$today') ?? 0;
  }
  
  // Current selected zikr
  Future<void> saveCurrentZikr(String zikrId) async {
    await _prefs.setString('current_zikr', zikrId);
  }
  
  String getCurrentZikr() {
    return _prefs.getString('current_zikr') ?? 'subhanallah';
  }
  
  // Custom zikrs (Pro özelliği)
  Future<void> saveCustomZikrs(List<Map<String, dynamic>> customZikrs) async {
    final jsonString = jsonEncode(customZikrs);
    await _prefs.setString('custom_zikrs', jsonString);
  }
  
  List<Map<String, dynamic>> getCustomZikrs() {
    final jsonString = _prefs.getString('custom_zikrs');
    if (jsonString != null) {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }
  
  // Reminders (Pro özelliği)
  Future<void> saveReminders(List<Map<String, dynamic>> reminders) async {
    final jsonString = jsonEncode(reminders);
    await _prefs.setString('reminders', jsonString);
  }
  
  List<Map<String, dynamic>> getReminders() {
    final jsonString = _prefs.getString('reminders');
    if (jsonString != null) {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }
  
  // Statistics settings (Pro özelliği)
  Future<void> saveStatisticsSettings(Map<String, dynamic> settings) async {
    final jsonString = jsonEncode(settings);
    await _prefs.setString('statistics_settings', jsonString);
  }
  
  Map<String, dynamic> getStatisticsSettings() {
    final jsonString = _prefs.getString('statistics_settings');
    if (jsonString != null) {
      return Map<String, dynamic>.from(jsonDecode(jsonString));
    }
    return {
      'showGraphs': true,
      'showWeeklyStats': true,
      'showMonthlyStats': true,
      'exportFormat': 'pdf',
    };
  }
  
  // Custom reminder times
  Future<void> saveCustomReminderTimes(List<Map<String, dynamic>> times) async {
    final jsonString = jsonEncode(times);
    await _prefs.setString('custom_reminder_times', jsonString);
  }
  
  List<Map<String, dynamic>> getCustomReminderTimes() {
    final jsonString = _prefs.getString('custom_reminder_times');
    if (jsonString != null) {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }
}