import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../services/notification_service.dart';
import '../widgets/islamic_snackbar.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  static const emeraldGreen = Color(0xFF2D5016);
  static const goldColor = Color(0xFFD4AF37);
  static const lightGold = Color(0xFFF5E6A8);
  static const darkGreen = Color(0xFF1A3409);

  final NotificationService _notificationService = Get.find<NotificationService>();
  List<Map<String, dynamic>> _reminders = [];

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  void _loadReminders() {
    setState(() {
      _reminders = _notificationService.getActiveReminders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF2D5016),
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF2D5016),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F6F0),
        appBar: AppBar(
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const RadialGradient(
                colors: [lightGold, goldColor],
                center: Alignment(-0.2, -0.2),
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: darkGreen.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              style: ButtonStyle(
                padding: WidgetStateProperty.all(EdgeInsets.zero),
                overlayColor: WidgetStateProperty.all(Colors.transparent),
              ),
              icon: const Icon(Icons.arrow_back, color: emeraldGreen, size: 20),
              onPressed: () => Get.back(),
            ),
          ),
          title: const Text(
            'Zikir Hatırlatıcıları',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: emeraldGreen,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFFDF7), Color(0xFFF8F6F0)],
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Header Info
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [lightGold, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: goldColor, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: goldColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: goldColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.notifications_active,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Belirlediğiniz tarih ve saatte zikir yapmayı hatırlatan bildirimler alın',
                        style: TextStyle(
                          fontSize: 14,
                          color: emeraldGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Reminders List
              Expanded(
                child: _reminders.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _reminders.length,
                        itemBuilder: (context, index) {
                          final reminder = _reminders[index];
                          return _buildReminderCard(reminder);
                        },
                      ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showAddReminderDialog,
          backgroundColor: emeraldGreen,
          foregroundColor: Colors.white,
          elevation: 6,
          icon: const Icon(Icons.add_alarm),
          label: const Text(
            'Hatırlatıcı Ekle',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: lightGold.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.alarm_off,
              size: 48,
              color: emeraldGreen,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Henüz hatırlatıcı yok',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: emeraldGreen,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Zikir yapmayı unutmamak için hatırlatıcı ekleyin',
            style: TextStyle(
              fontSize: 14,
              color: emeraldGreen,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(Map<String, dynamic> reminder) {
    final dateTime = DateTime.parse(reminder['dateTime']);
    final title = reminder['title'] ?? 'Zikir Zamanı';
    final message = reminder['message'] ?? '';
    final id = reminder['id'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: goldColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: emeraldGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.alarm,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: emeraldGreen,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _deleteReminder(id),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.schedule, size: 16, color: emeraldGreen),
              const SizedBox(width: 8),
              Text(
                '${dateTime.day}/${dateTime.month}/${dateTime.year} - ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 14,
                  color: emeraldGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (message.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: emeraldGreen.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddReminderDialog() {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    DateTime selectedDateTime = DateTime.now().add(const Duration(hours: 1));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFFF8F6F0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text(
            'Yeni Hatırlatıcı',
            style: TextStyle(color: emeraldGreen, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Başlık',
                    hintText: 'Zikir Zamanı',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: emeraldGreen),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Message
                TextField(
                  controller: messageController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Mesaj (Opsiyonel)',
                    hintText: 'Zikir yapma zamanı geldi',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: emeraldGreen),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Date & Time
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: goldColor.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: emeraldGreen),
                          const SizedBox(width: 8),
                          const Text('Tarih ve Saat:', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${selectedDateTime.day}/${selectedDateTime.month}/${selectedDateTime.year} - ${selectedDateTime.hour.toString().padLeft(2, '0')}:${selectedDateTime.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 16, color: emeraldGreen),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDateTime,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (date != null) {
                                  setDialogState(() {
                                    selectedDateTime = DateTime(
                                      date.year,
                                      date.month,
                                      date.day,
                                      selectedDateTime.hour,
                                      selectedDateTime.minute,
                                    );
                                  });
                                }
                              },
                              icon: const Icon(Icons.calendar_today, size: 16),
                              label: const Text('Tarih'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: goldColor,
                                foregroundColor: emeraldGreen,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                                );
                                if (time != null) {
                                  setDialogState(() {
                                    selectedDateTime = DateTime(
                                      selectedDateTime.year,
                                      selectedDateTime.month,
                                      selectedDateTime.day,
                                      time.hour,
                                      time.minute,
                                    );
                                  });
                                }
                              },
                              icon: const Icon(Icons.access_time, size: 16),
                              label: const Text('Saat'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: goldColor,
                                foregroundColor: emeraldGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () => _addReminder(
                selectedDateTime,
                titleController.text.trim(),
                messageController.text.trim(),
              ),
              style: ElevatedButton.styleFrom(backgroundColor: emeraldGreen),
              child: const Text('Ekle', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _addReminder(DateTime dateTime, String title, String message) async {
    if (dateTime.isBefore(DateTime.now())) {
      IslamicSnackbar.showWarning(
        'Geçersiz Tarih',
        'Geçmiş bir tarih seçemezsiniz',
      );
      return;
    }

    // Permission kontrolü
    final hasPermission = await _notificationService.checkNotificationPermission();
    if (!hasPermission) {
      _showPermissionDialog();
      return;
    }

    final reminderTitle = title.isEmpty ? 'Zikir Zamanı 🕌' : title;
    final reminderMessage = message.isEmpty ? 'Zikir yapma zamanı geldi!' : message;

    await _notificationService.scheduleCustomReminder(
      scheduledDateTime: dateTime,
      title: reminderTitle,
      message: reminderMessage,
    );

    Navigator.pop(context);
    _loadReminders();

    IslamicSnackbar.showSuccess(
      'Hatırlatıcı Eklendi 🔔',
      'Belirlenen zamanda bildirim gelecek',
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF8F6F0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Bildirim İzni Gerekli',
          style: TextStyle(color: emeraldGreen, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Hatırlatıcıların çalışması için bildirim izni vermeniz gerekiyor.',
          style: TextStyle(color: emeraldGreen),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _notificationService.openNotificationSettings();
            },
            style: ElevatedButton.styleFrom(backgroundColor: emeraldGreen),
            child: const Text('Ayarlara Git', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteReminder(int id) async {
    await _notificationService.deleteReminder(id);
    _loadReminders();
    IslamicSnackbar.showSuccess(
      'Silindi 🗑️',
      'Hatırlatıcı başarıyla silindi',
    );
  }
}