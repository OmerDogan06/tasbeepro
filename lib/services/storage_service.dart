import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/counter_data.dart';
import '../models/subscription_plan.dart';
import '../models/zikr.dart';

class StorageService extends GetxService {
  static StorageService get to => Get.find();
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
  
  // Sound volume settings (0=Düşük, 1=Orta, 2=Yüksek)
  Future<void> saveSoundVolume(int volume) async {
    await _prefs.setInt('sound_volume', volume);
  }
  
  int getSoundVolume() {
    return _prefs.getInt('sound_volume') ?? 1; // Varsayılan: Orta
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
  
  // Tüm mevcut zikir ID'lerini al (varsayılan + özel)
  List<String> _getAllZikrIds() {
    // Varsayılan zikir ID'leri
    final defaultZikrIds = Zikr.defaultZikrs.map((zikr) => zikr.id).toList();
    
    // Özel zikir ID'leri
    final customZikrs = getCustomZikrs();
    final customZikrIds = customZikrs
        .map((customZikr) => customZikr['id'] as String?)
        .where((id) => id != null)
        .cast<String>()
        .toList();
    
    return [...defaultZikrIds, ...customZikrIds];
  }

  // Tüm zikirlerden bugünkü toplam sayı hesapla
  int getTotalDailyCount() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    int total = 0;
    
    // Tüm zikir ID'leri için bugünkü sayıları topla
    final allZikrIds = _getAllZikrIds();
    
    for (String zikrId in allZikrIds) {
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

  // Tarihe göre zikir sayısı al
  int getZikrCountForDate(String zikrId, DateTime date) {
    final dateKey = date.toIso8601String().split('T')[0];
    return _prefs.getInt('daily_${zikrId}_$dateKey') ?? 0;
  }

  // Belirli bir tarih aralığındaki zikir sayısını al
  int getZikrCountForDateRange(String zikrId, DateTime startDate, DateTime endDate) {
    int total = 0;
    DateTime current = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    
    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      total += getZikrCountForDate(zikrId, current);
      current = current.add(const Duration(days: 1));
    }
    
    return total;
  }

  // Günlük istatistik (bugün)
  int getTodayZikrCount(String zikrId) {
    final today = DateTime.now();
    return getZikrCountForDate(zikrId, today);
  }

  // Haftalık istatistik (bu hafta - Pazartesi'den başlayarak)
  int getWeeklyZikrCount(String zikrId) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek = DateTime(monday.year, monday.month, monday.day);
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return getZikrCountForDateRange(zikrId, startOfWeek, endOfWeek);
  }

  // Aylık istatistik (bu ay)
  int getMonthlyZikrCount(String zikrId) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    return getZikrCountForDateRange(zikrId, startOfMonth, endOfMonth);
  }

  // Yıllık istatistik (bu yıl)
  int getYearlyZikrCount(String zikrId) {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31);
    
    return getZikrCountForDateRange(zikrId, startOfYear, endOfYear);
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

  // Custom targets
  Future<void> saveCustomTargets(List<int> targets) async {
    final customTargets = targets.where((target) => target > 1000).toList();
    await _prefs.setStringList('custom_targets', customTargets.map((e) => e.toString()).toList());
  }
  
  List<int> getCustomTargets() {
    final stringList = _prefs.getStringList('custom_targets') ?? [];
    return stringList.map((e) => int.tryParse(e) ?? 0).where((e) => e > 0).toList();
  }

  // Completed targets count for ads
  Future<void> saveCompletedTargetsCount(int count) async {
    await _prefs.setInt('completed_targets_count', count);
  }
  
  int getCompletedTargetsCount() {
    return _prefs.getInt('completed_targets_count') ?? 0;
  }

  // Subscription status
  Future<void> saveSubscriptionStatus(SubscriptionStatus status) async {
    await _prefs.setString('subscription_status', jsonEncode(status.toJson()));
  }
  
  Future<SubscriptionStatus?> getSubscriptionStatus() async {
    final jsonString = _prefs.getString('subscription_status');
    if (jsonString != null) {
      try {
        return SubscriptionStatus.fromJson(jsonDecode(jsonString));
      } catch (e) {
        print('Error parsing subscription status: $e');
        return null;
      }
    }
    return null;
  }

  // Simple premium status for background service
  Future<void> savePremiumStatus(bool isPremium) async {
    await _prefs.setBool('is_premium', isPremium);
  }
  
  bool getPremiumStatus() {
    return _prefs.getBool('is_premium') ?? false;
  }

  // First app launch check for trial
  Future<void> setFirstLaunchCompleted() async {
    await _prefs.setBool('first_launch_completed', true);
  }
  
  bool isFirstLaunch() {
    return !(_prefs.getBool('first_launch_completed') ?? false);
  }
}