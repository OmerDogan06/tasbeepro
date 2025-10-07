import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../widgets/islamic_snackbar.dart';

class CustomReminderTimesScreen extends StatefulWidget {
  const CustomReminderTimesScreen({super.key});

  @override
  State<CustomReminderTimesScreen> createState() => _CustomReminderTimesScreenState();
}

class _CustomReminderTimesScreenState extends State<CustomReminderTimesScreen> {
  static const emeraldGreen = Color(0xFF2D5016);
  static const goldColor = Color(0xFFD4AF37);
  static const lightGold = Color(0xFFF5E6A8);
  static const darkGreen = Color(0xFF1A3409);

  final NotificationService _notificationService = Get.find<NotificationService>();
  final StorageService _storage = Get.find<StorageService>();
  
  List<Map<String, dynamic>> _customTimes = [];

  @override
  void initState() {
    super.initState();
    _loadCustomTimes();
  }

  void _loadCustomTimes() {
    setState(() {
      _customTimes = _storage.getCustomReminderTimes();
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
            'Hatırlatma Saatleri',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: emeraldGreen,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: emeraldGreen),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFFDF7),
                  Color(0xFFF8F6F0),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _addCustomTime,
          backgroundColor: emeraldGreen,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('Saat Ekle'),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
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
                        Icons.schedule,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Özel saatlerde günlük zikir hatırlatıcıları alın. Eklediğiniz saatler her gün tekrarlanır.',
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
              
              // Times List
              Expanded(
                child: _customTimes.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _customTimes.length,
                        itemBuilder: (context, index) {
                          final timeData = _customTimes[index];
                          return _buildTimeCard(timeData, index);
                        },
                      ),
              ),
            ],
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const RadialGradient(
                colors: [lightGold, goldColor],
                center: Alignment(-0.2, -0.2),
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: darkGreen.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.schedule,
              color: emeraldGreen,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Henüz özel saat eklenmemiş',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: emeraldGreen,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Günlük hatırlatıcılar için özel saatler ekleyebilirsiniz',
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

  Widget _buildTimeCard(Map<String, dynamic> timeData, int index) {
    final hour = timeData['hour'] as int;
    final minute = timeData['minute'] as int;
    final isActive = timeData['isActive'] ?? true;
    final timeString = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFDF7),
            isActive ? Color(0xFFF5F3E8) : Color(0xFFF0F0F0),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isActive ? goldColor.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: isActive 
                  ? [lightGold, goldColor]
                  : [Colors.grey.shade300, Colors.grey.shade400],
              center: const Alignment(-0.2, -0.2),
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: darkGreen.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.access_time,
            color: isActive ? emeraldGreen : Colors.grey.shade600,
            size: 22,
          ),
        ),
        title: Text(
          timeString,
          style: TextStyle(
            color: isActive ? emeraldGreen : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          isActive ? 'Günlük hatırlatıcı aktif' : 'Devre dışı',
          style: TextStyle(
            color: isActive ? emeraldGreen.withOpacity(0.7) : Colors.grey.shade500,
            fontSize: 12,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Switch
            Switch(
              value: isActive,
              onChanged: (value) => _toggleTime(index, value),
              thumbColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.selected)) {
                    return goldColor;
                  }
                  return emeraldGreen;
                },
              ),
              trackOutlineColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  return goldColor;
                },
              ),
              trackColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  return Colors.transparent;
                },
              ),
            ),
            // Delete Button
            IconButton(
              onPressed: () => _deleteTime(index),
              icon: const Icon(Icons.delete_outline),
              color: Colors.red.shade400,
              style: IconButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addCustomTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: emeraldGreen,
              onPrimary: Colors.white,
              surface: Color(0xFFF8F6F0),
              onSurface: emeraldGreen,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      // Aynı saatin eklenip eklenmediğini kontrol et
      final existingTime = _customTimes.any((t) => 
          t['hour'] == time.hour && t['minute'] == time.minute);
      
      if (existingTime) {
        IslamicSnackbar.showWarning(
          'Zaten Mevcut',
          'Bu saat zaten eklenmiş',
        );
        return;
      }

      setState(() {
        _customTimes.add({
          'hour': time.hour,
          'minute': time.minute,
          'isActive': true,
        });
      });

      await _saveCustomTimes();
      await _scheduleTimeNotifications();

      IslamicSnackbar.showSuccess(
        'Saat Eklendi 🕐',
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} saatinde günlük hatırlatıcı aktif',
      );
    }
  }

  Future<void> _toggleTime(int index, bool isActive) async {
    setState(() {
      _customTimes[index]['isActive'] = isActive;
    });

    await _saveCustomTimes();
    await _scheduleTimeNotifications();

    IslamicSnackbar.showInfo(
      isActive ? 'Aktif Edildi' : 'Devre Dışı',
      isActive ? 'Hatırlatıcı aktif' : 'Hatırlatıcı devre dışı',
    );
  }

  Future<void> _deleteTime(int index) async {
    final timeData = _customTimes[index];
    final timeString = '${timeData['hour'].toString().padLeft(2, '0')}:${timeData['minute'].toString().padLeft(2, '0')}';

    // Onay dialog'u
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: const Color(0xFFF8F6F0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Saati Sil?',
          style: TextStyle(color: emeraldGreen, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '$timeString saatindeki hatırlatıcıyı silmek istediğinizden emin misiniz?',
          style: const TextStyle(color: emeraldGreen),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _customTimes.removeAt(index);
      });

      await _saveCustomTimes();
      await _scheduleTimeNotifications();

      IslamicSnackbar.showSuccess(
        'Silindi 🗑️',
        '$timeString saati başarıyla silindi',
      );
    }
  }

  Future<void> _saveCustomTimes() async {
    await _storage.saveCustomReminderTimes(_customTimes);
  }

  Future<void> _scheduleTimeNotifications() async {
    // Tüm özel saat bildirimlerini iptal et ve yeniden planla
    await _notificationService.cancelCustomTimeNotifications();
    
    for (final timeData in _customTimes) {
      if (timeData['isActive'] == true) {
        await _notificationService.scheduleCustomTimeReminder(
          hour: timeData['hour'],
          minute: timeData['minute'],
        );
      }
    }
  }
}