import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'storage_service.dart';
import '../l10n/app_localizations.dart';

class NotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final StorageService _storage = Get.find<StorageService>();

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeNotifications();
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // Android 13+ için notification permission iste
    if (await Permission.notification.isDenied) {
      final status = await Permission.notification.request();
      if (status.isDenied) {
        // Kullanıcıya açıklama göster
        print('Notification permission denied');
      }
    }

    // Exact alarm permission (Android 12+)
    if (await Permission.scheduleExactAlarm.isDenied) {
      final status = await Permission.scheduleExactAlarm.request();
      if (status.isDenied) {
        print('Exact alarm permission denied');
      }
    }
    
    // Battery optimization için izin iste (opsiyonel)
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
    
    // High priority channel for critical reminders
    final AndroidNotificationChannel channel = AndroidNotificationChannel(
      'zikr_reminders',
      context != null 
          ? (AppLocalizations.of(context)?.notificationChannelTitle ?? 'Zikir Hatırlatıcıları')
          : 'Zikir Hatırlatıcıları',
      description: context != null 
          ? (AppLocalizations.of(context)?.notificationChannelDescription ?? 'Zikir yapmayı hatırlatır')
          : 'Zikir yapmayı hatırlatır',
      importance: Importance.high, // High instead of max to avoid being too intrusive
      enableVibration: true,
      playSound: true,
      enableLights: true,
      ledColor: const Color.fromARGB(255, 0, 255, 0),
      showBadge: true,
    );

    // Daily reminders channel
    final AndroidNotificationChannel dailyChannel = AndroidNotificationChannel(
      'daily_reminders',
      context != null 
          ? (AppLocalizations.of(context)?.notificationDailyChannelTitle ?? 'Günlük Hatırlatıcılar')
          : 'Günlük Hatırlatıcılar',
      description: context != null 
          ? (AppLocalizations.of(context)?.notificationDailyChannelDescription ?? 'Belirlenen saatlerde günlük zikir hatırlatıcıları')
          : 'Belirlenen saatlerde günlük zikir hatırlatıcıları',
      importance: Importance.high, // High instead of max
      enableVibration: true,
      playSound: true,
      enableLights: true,
      ledColor: const Color.fromARGB(255, 0, 255, 0),
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
    // Notification'a tıklandığında yapılacak işlemler
    // Ana ekrana yönlendir
  }

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

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'zikr_reminders',
          context != null 
              ? (context.mounted ? AppLocalizations.of(context)?.notificationChannelTitle : 'Zikir Hatırlatıcıları')!
              : 'Zikir Hatırlatıcıları',
          channelDescription: context != null 
              ? (context.mounted ? AppLocalizations.of(context)?.notificationChannelDescription : 'Zikir yapmayı hatırlatır')
              : 'Zikir yapmayı hatırlatır',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
          largeIcon: const DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
          enableVibration: true,
          playSound: true,
          autoCancel: true,
          ongoing: false,
          category: AndroidNotificationCategory.reminder,
          visibility: NotificationVisibility.public,
          showWhen: true,
          enableLights: true,
          ledColor: const Color.fromARGB(255, 0, 255, 0),
          ledOnMs: 1000,
          ledOffMs: 500,
          ticker: context != null 
              ? (context.mounted ? AppLocalizations.of(context)?.notificationZikirReminder : 'Zikir Hatırlatıcısı')
              : 'Zikir Hatırlatıcısı',
          
          styleInformation: BigTextStyleInformation(
            body,
            htmlFormatBigText: false,
            contentTitle: title,
            htmlFormatContentTitle: false,
            summaryText: 'Tasbee Pro',
            htmlFormatSummaryText: false,
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          badgeNumber: 1,
          interruptionLevel: InterruptionLevel.active,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // Kullanıcının belirlediği tarih ve saatte hatırlatıcı ayarla
  Future<void> scheduleCustomReminder({
    required DateTime scheduledDateTime,
    required String title,
    required String message,
  }) async {
    final id = scheduledDateTime.millisecondsSinceEpoch ~/ 1000; // Unique ID

    await scheduleZikrReminder(
      id: id,
      title: title,
      body: message,
      scheduledTime: scheduledDateTime,
    );

    // Hatırlatıcıyı storage'a kaydet
    await _saveReminderToStorage(id, scheduledDateTime, title, message);
  }

  // Storage'a hatırlatıcı kaydet
  Future<void> _saveReminderToStorage(
    int id,
    DateTime dateTime,
    String title,
    String message,
  ) async {
    final reminders = _storage.getReminders();

    reminders.add({
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'title': title,
      'message': message,
      'isActive': true,
    });

    await _storage.saveReminders(reminders);
  }

  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required String message,
  }) async {
    final context = Get.context;
    
    await scheduleZikrReminder(
      id: 1,
      title: context != null 
          ? (AppLocalizations.of(context)?.notificationZikirTime ?? 'Zikir Zamanı 🕌')
          : 'Zikir Zamanı 🕌',
      body: message,
      scheduledTime: DateTime.now().copyWith(
        hour: hour,
        minute: minute,
        second: 0,
        millisecond: 0,
      ),
    );
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Hatırlatıcıları listele
  List<Map<String, dynamic>> getActiveReminders() {
    final reminders = _storage.getReminders();
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

    final reminders = _storage.getReminders();
    reminders.removeWhere((reminder) => reminder['id'] == id);
    await _storage.saveReminders(reminders);
  }

  // Tüm geçmiş hatırlatıcıları temizle
  Future<void> cleanupOldReminders() async {
    final reminders = _storage.getReminders();
    final now = DateTime.now();

    final activeReminders = reminders.where((reminder) {
      final dateTime = DateTime.parse(reminder['dateTime']);
      return dateTime.isAfter(now);
    }).toList();

    await _storage.saveReminders(activeReminders);
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

  // Özel saatler için günlük hatırlatıcı planla
  Future<void> scheduleCustomTimeReminder({
    required int hour,
    required int minute,
  }) async {
    final context = Get.context;
    final id = hour * 100 + minute; // Unique ID for time-based reminders

    // Her gün aynı saatte tekrarlanacak notification planla
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);

    // Eğer bugün için saat geçmişse, yarın için planla
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      id,
      context != null 
          ? (AppLocalizations.of(context)?.notificationZikirTime ?? 'Zikir Zamanı 🕌')
          : 'Zikir Zamanı 🕌',
      context != null 
          ? (AppLocalizations.of(context)?.notificationDailyZikirMessage ?? 'Günlük zikir yapma zamanı geldi!')
          : 'Günlük zikir yapma zamanı geldi!',
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminders',
          context != null 
              ? (AppLocalizations.of(context)?.notificationDailyChannelTitle ?? 'Günlük Hatırlatıcılar')
              : 'Günlük Hatırlatıcılar',
          channelDescription: context != null 
              ? (AppLocalizations.of(context)?.notificationDailyChannelDescription ?? 'Belirlenen saatlerde günlük zikir hatırlatıcıları')
              : 'Belirlenen saatlerde günlük zikir hatırlatıcıları',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
          largeIcon: const DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
          enableVibration: true,
          playSound: true,
          autoCancel: true,
          ongoing: false,
          category: AndroidNotificationCategory.reminder,
          channelShowBadge: true,
          visibility: NotificationVisibility.public,
          enableLights: true,
          ledColor: const Color.fromARGB(255, 0, 255, 0),
          ledOnMs: 1000,
          ledOffMs: 500,
          ticker: context != null 
              ? (AppLocalizations.of(context)?.notificationZikirTime ?? 'Zikir Zamanı!')
              : 'Zikir Zamanı!',
          when: null,
          usesChronometer: false,
          
          styleInformation: BigTextStyleInformation(
            context != null 
                ? (AppLocalizations.of(context)?.notificationDetailedMessage ?? 'Günlük zikir yapma zamanı geldi! SubhanAllah, Alhamdulillah, Allahu Akbar')
                : 'Günlük zikir yapma zamanı geldi! SubhanAllah, Alhamdulillah, Allahu Akbar',
            htmlFormatBigText: false,
            contentTitle: context != null 
                ? (AppLocalizations.of(context)?.notificationZikirTime ?? 'Zikir Zamanı 🕌')
                : 'Zikir Zamanı 🕌',
            htmlFormatContentTitle: false,
            summaryText: 'Tasbee Pro',
            htmlFormatSummaryText: false,
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          categoryIdentifier: 'daily_reminder',
          interruptionLevel: InterruptionLevel.active,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Özel saat bildirimlerini iptal et
  Future<void> cancelCustomTimeNotifications() async {
    // Custom time notification ID'leri 0-2359 arasında (hour*100 + minute)
    for (int hour = 0; hour < 24; hour++) {
      for (int minute = 0; minute < 60; minute++) {
        final id = hour * 100 + minute;
        await _notifications.cancel(id);
      }
    }
  }
}
