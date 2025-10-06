import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'storage_service.dart';

class NotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
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
      await Permission.notification.request();
    }
    
    // Exact alarm permission (Android 12+)
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
  }
  
  Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
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
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'zikr_reminders',
      'Zikir Hatırlatıcıları',
      description: 'Zikir yapmayı hatırlatır',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
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
    // Permission kontrolü
    if (!await _hasNotificationPermission()) {
      throw Exception('Bildirim izni gerekli');
    }
    
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'zikr_reminders',
          'Zikir Hatırlatıcıları',
          channelDescription: 'Zikir yapmayı hatırlatır',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          enableVibration: true,
          playSound: true,
          autoCancel: true,
          ongoing: false,
          category: AndroidNotificationCategory.reminder,
          visibility: NotificationVisibility.public,
          showWhen: true,
          fullScreenIntent: false,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          badgeNumber: 1,
        ),
      ),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
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
  Future<void> _saveReminderToStorage(int id, DateTime dateTime, String title, String message) async {
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
    await scheduleZikrReminder(
      id: 1,
      title: 'Zikir Zamanı 🕌',
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
}