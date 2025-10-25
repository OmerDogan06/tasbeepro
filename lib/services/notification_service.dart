import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'storage_service.dart';
import '../l10n/app_localizations.dart';

@pragma('vm:entry-point')
class NotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  StorageService? _storage;

  // Default constructor
  NotificationService();
  
  // Background/callback context için constructor
  NotificationService._createForCallback();

  // Init method for GetX async initialization
  Future<NotificationService> init() async {
    _storage = Get.find<StorageService>();
    await _initializeAlarmManager();
    await _initializeNotifications();
    await _requestPermissions();
    return this;
  }
  
  @override
  Future<void> onInit() async {
    super.onInit();
    _storage ??= Get.find<StorageService>();
    await _initializeAlarmManager();
    await _initializeNotifications();
    await _requestPermissions();
  }

  Future<void> _initializeAlarmManager() async {
    await AndroidAlarmManager.initialize();
  }

  Future<void> _requestPermissions() async {
    // Android 13+ için notification permission iste
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    // Exact alarm permission (Android 12+)
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }

    // Battery optimization'ı kapat
    if (await Permission.ignoreBatteryOptimizations.isDenied) {
      await Permission.ignoreBatteryOptimizations.request();
    }
  }

  Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Android notification channel oluştur
    await _createNotificationChannel();
  }

  Future<void> _createNotificationChannel() async {
    final context = Get.context;
    
    final AndroidNotificationChannel channel = AndroidNotificationChannel(
      'zikr_reminders',
      context != null 
          ? (AppLocalizations.of(context)?.notificationChannelTitle ?? 'Zikir Hatırlatıcıları')
          : 'Zikir Hatırlatıcıları',
      description: context != null 
          ? (AppLocalizations.of(context)?.notificationChannelDescription ?? 'Zikir yapmayı hatırlatır')
          : 'Zikir yapmayı hatırlatır',
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
      enableLights: true,
      ledColor: const Color.fromARGB(255, 255, 0, 0),
      showBadge: true,
    );

    final AndroidNotificationChannel dailyChannel = AndroidNotificationChannel(
      'daily_reminders',
      context != null 
          ? (AppLocalizations.of(context)?.notificationDailyChannelTitle ?? 'Günlük Hatırlatıcılar')
          : 'Günlük Hatırlatıcılar',
      description: context != null 
          ? (AppLocalizations.of(context)?.notificationDailyChannelDescription ?? 'Belirlenen saatlerde günlük zikir hatırlatıcıları')
          : 'Belirlenen saatlerde günlük zikir hatırlatıcıları',
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
      enableLights: true,
      ledColor: const Color.fromARGB(255, 255, 0, 0),
      showBadge: true,
    );

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(channel);
    await androidPlugin?.createNotificationChannel(dailyChannel);
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Notification'a tıklandığında ana ekrana yönlendir
  }

  // Static method for alarm callback - Bu method AndroidAlarmManager tarafından çağrılacak
  @pragma('vm:entry-point')
  static Future<void> alarmCallback(int id, Map<String, dynamic> params) async {
    try {
      // Background context'te notification service oluştur
      final notificationService = NotificationService._createForCallback();
      await notificationService._initializeNotifications();
      
      await notificationService._showNotification(
        id: params['id'] ?? id,
        title: params['title'] ?? 'Zikir Zamanı 🕌',
        body: params['body'] ?? 'Zikir yapma zamanı geldi!',
        channelId: params['channelId'] ?? 'zikr_reminders',
      );
    } catch (e) {
      debugPrint('Alarm callback error: $e');
    }
  }

  // Static method for daily reminders callback
  @pragma('vm:entry-point')
  static Future<void> dailyAlarmCallback(int id, Map<String, dynamic> params) async {
    try {
      // Background context'te notification service oluştur
      final notificationService = NotificationService._createForCallback();
      await notificationService._initializeNotifications();
      
      await notificationService._showNotification(
        id: id,
        title: params['title'] ?? 'Zikir Zamanı 🕌',
        body: params['body'] ?? 'Günlük zikir yapma zamanı geldi!',
        channelId: 'daily_reminders',
      );

      // Ertesi gün için tekrar planla
      final hour = params['hour'] as int? ?? 9;
      final minute = params['minute'] as int? ?? 0;
      
      await AndroidAlarmManager.oneShotAt(
        DateTime.now().add(const Duration(days: 1)).copyWith(hour: hour, minute: minute, second: 0, millisecond: 0),
        id,
        dailyAlarmCallback,
        exact: true,
        wakeup: true,
        params: params,
      );
    } catch (e) {
      debugPrint('Daily alarm callback error: $e');
    }
  }


  // Bildirim gösterme method'u
  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    required String channelId,
  }) async {
    await _notifications.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId == 'zikr_reminders' ? 'Zikir Hatırlatıcıları' : 'Günlük Hatırlatıcılar',
          channelDescription: channelId == 'zikr_reminders' 
              ? 'Zikir yapmayı hatırlatır' 
              : 'Belirlenen saatlerde günlük zikir hatırlatıcıları',
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/launcher_icon',
          enableVibration: true,
          playSound: true,
          autoCancel: true,
          ongoing: false,
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
          showWhen: true,
          enableLights: true,
          ledColor: const Color.fromARGB(255, 255, 0, 0),
          ledOnMs: 1000,
          ledOffMs: 500,
          ticker: title,
          styleInformation: BigTextStyleInformation(
            body,
            htmlFormatBigText: false,
            contentTitle: title,
            htmlFormatContentTitle: false,
            summaryText: 'SkyForge Studios',
            htmlFormatSummaryText: false,
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          badgeNumber: 1,
          interruptionLevel: InterruptionLevel.critical,
        ),
      ),
    );
  }

  // Zikir hatırlatıcısı planla (AndroidAlarmManager ile)
  Future<void> scheduleZikrReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final context = Get.context;
    
    // Permission kontrolü
    if (!await _hasNotificationPermission()) {
      throw Exception(context != null 
          ? (context.mounted ? AppLocalizations.of(context)?.notificationPermissionRequired : 'Bildirim izni gerekli')
          : 'Bildirim izni gerekli');
    }

    // Geçmiş tarih kontrolü
    if (scheduledTime.isBefore(DateTime.now())) {
      throw Exception('Geçmiş bir tarihe hatırlatıcı ayarlanamaz');
    }

    // Alarm parametreleri
    final params = {
      'id': id,
      'title': title,
      'body': body,
      'channelId': 'zikr_reminders',
    };

    // AndroidAlarmManager ile alarm ayarla
    await AndroidAlarmManager.oneShotAt(
      scheduledTime,
      id,
      alarmCallback,
      exact: true,
      wakeup: true,
      params: params,
    );
  }

  // Kullanıcının belirlediği tarih ve saatte hatırlatıcı ayarla
  Future<void> scheduleCustomReminder({
    required DateTime scheduledDateTime,
    required String title,
    required String message,
  }) async {
    final id = _generateUniqueId(scheduledDateTime);

    await scheduleZikrReminder(
      id: id,
      title: title,
      body: message,
      scheduledTime: scheduledDateTime,
    );

    // Hatırlatıcıyı storage'a kaydet
    await _saveReminderToStorage(id, scheduledDateTime, title, message);
  }

  // Unique ID generate et
  int _generateUniqueId(DateTime dateTime) {
    return dateTime.millisecondsSinceEpoch ~/ 1000;
  }

  // Storage'a hatırlatıcı kaydet
  Future<void> _saveReminderToStorage(
    int id,
    DateTime dateTime,
    String title,
    String message,
  ) async {
    if (_storage == null) return;
    
    final reminders = _storage!.getReminders();

    reminders.add({
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'title': title,
      'message': message,
      'isActive': true,
    });

    await _storage!.saveReminders(reminders);
  }



  // Tüm bildirimleri iptal et
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    
    if (_storage == null) return;
    
    // Tüm storage'daki alarmları iptal et
    final reminders = _storage!.getReminders();
    for (final reminder in reminders) {
      final id = reminder['id'] as int?;
      if (id != null) {
        await AndroidAlarmManager.cancel(id);
      }
    }
  }

  // Belirli bir bildirimi iptal et
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    await AndroidAlarmManager.cancel(id);
  }

  // Hatırlatıcıları listele
  List<Map<String, dynamic>> getActiveReminders() {
    if (_storage == null) return [];
    
    final reminders = _storage!.getReminders();
    final now = DateTime.now();

    // Geçmiş tarihleri filtrele ve sadece aktif olanları döndür
    return reminders.where((reminder) {
      final dateTime = DateTime.parse(reminder['dateTime']);
      final isActive = reminder['isActive'] ?? true;
      return dateTime.isAfter(now) && isActive;
    }).toList();
  }

  // Hatırlatıcıyı sil
  Future<void> deleteReminder(int id) async {
    await cancelNotification(id);

    if (_storage == null) return;

    final reminders = _storage!.getReminders();
    reminders.removeWhere((reminder) => reminder['id'] == id);
    await _storage!.saveReminders(reminders);
  }

  // Tüm geçmiş hatırlatıcıları temizle
  Future<void> cleanupOldReminders() async {
    if (_storage == null) return;
    
    final reminders = _storage!.getReminders();
    final now = DateTime.now();

    final activeReminders = reminders.where((reminder) {
      final dateTime = DateTime.parse(reminder['dateTime']);
      return dateTime.isAfter(now);
    }).toList();

    await _storage!.saveReminders(activeReminders);
  }

  // Permission durumunu kontrol et
  Future<bool> checkNotificationPermission() async {
    return await Permission.notification.isGranted;
  }

  Future<bool> _hasNotificationPermission() async {
    return await Permission.notification.isGranted;
  }

  // Ayarlar sayfasına yönlendir (permission reddedilirse)
  Future<void> openNotificationSettings() async {
    await openAppSettings();
  }

  // Özel saatler için günlük hatırlatıcı planla (AndroidAlarmManager ile)
  Future<void> scheduleCustomTimeReminder({
    required int hour,
    required int minute,
  }) async {
    final context = Get.context;
    final id = hour * 100 + minute; // Unique ID for time-based reminders

    // Her gün aynı saatte tekrarlanacak alarm planla
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);

    // Eğer bugün için saat geçmişse, yarın için planla
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final params = {
      'hour': hour,
      'minute': minute,
      'title': context != null 
          ? (AppLocalizations.of(context)?.notificationZikirTime ?? 'Zikir Zamanı 🕌')
          : 'Zikir Zamanı 🕌',
      'body': context != null 
          ? (AppLocalizations.of(context)?.notificationDailyZikirMessage ?? 'Günlük zikir yapma zamanı geldi!')
          : 'Günlük zikir yapma zamanı geldi!',
    };

    // AndroidAlarmManager ile günlük tekrarlanan alarm ayarla
    await AndroidAlarmManager.oneShotAt(
      scheduledDate,
      id,
      dailyAlarmCallback,
      exact: true,
      wakeup: true,
      params: params,
    );
  }

  // Özel saat bildirimlerini iptal et
  Future<void> cancelCustomTimeNotifications() async {
    // Custom time notification ID'leri 0-2359 arasında (hour*100 + minute)
    for (int hour = 0; hour < 24; hour++) {
      for (int minute = 0; minute < 60; minute++) {
        final id = hour * 100 + minute;
        await AndroidAlarmManager.cancel(id);
      }
    }
  }
}
