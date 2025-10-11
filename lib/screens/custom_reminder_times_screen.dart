import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../widgets/islamic_snackbar.dart';
import '../widgets/custom_bottom_picker.dart';
import '../l10n/app_localizations.dart';

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
  RxBool isLoading = false.obs;
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
          statusBarColor: Colors.white,
         statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFF2D5016),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F6F0),
        appBar:PreferredSize(preferredSize: Size.fromHeight(56), child:  SafeArea(
          child: AppBar(
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
                    color: darkGreen.withAlpha(38),
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
            title: Text(
              AppLocalizations.of(context)?.customTimesTitle ?? 'Hatırlatma Saatleri',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: emeraldGreen,
                fontSize: 18,
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
        )),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _addCustomTime,
          backgroundColor: emeraldGreen,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          elevation: 6,
          label: Text(
            AppLocalizations.of(context)?.customTimesAddButton ?? 'Saat Ekle',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
        body: Obx(() => 
         LoadingOverlay(
            isLoading: isLoading.value,
            color: Colors.black.withAlpha(50),
            progressIndicator: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(emeraldGreen),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [lightGold, Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: goldColor, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: goldColor.withAlpha(51),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 35,
                          height: 35,
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: goldColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Icon(
                            Icons.schedule,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)?.customTimesDescription ?? 'Özel saatlerde günlük zikir hatırlatıcıları alın. Eklediğiniz saatler her gün tekrarlanır.',
                            style: const TextStyle(
                              fontSize: 13,
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
                            padding: const EdgeInsets.symmetric(horizontal: 8),
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
                  color: darkGreen.withAlpha(38),
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
          Text(
            AppLocalizations.of(context)?.customTimesEmptyTitle ?? 'Henüz özel saat eklenmemiş',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: emeraldGreen,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)?.customTimesEmptyMessage ?? 'Günlük hatırlatıcılar için özel saatler ekleyebilirsiniz',
            style: const TextStyle(
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
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFDF7),
            isActive ? Color(0xFFF5F3E8) : Color(0xFFF0F0F0),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive ? goldColor.withAlpha(77) : Colors.grey.withAlpha(77),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        leading: Container(
          padding: const EdgeInsets.all(8),
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
                color: darkGreen.withAlpha(38),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.access_time,
            color: isActive ? emeraldGreen : Colors.grey.shade600,
            size: 20,
          ),
        ),
        title: Text(
          timeString,
          style: TextStyle(
            color: isActive ? emeraldGreen : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        subtitle: Text(
          isActive 
              ? (AppLocalizations.of(context)?.customTimesActiveStatus ?? 'Günlük hatırlatıcı aktif')
              : (AppLocalizations.of(context)?.customTimesInactiveStatus ?? 'Devre dışı'),
          style: TextStyle(
            color: isActive ? emeraldGreen.withAlpha(179) : Colors.grey.shade500,
            fontSize: 11,
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
    CustomBottomPicker.time(
      backgroundColor: Colors.white,
      buttonSingleColor: emeraldGreen,
      onSubmit: (time) async{
        isLoading.value = true;
        final hour = time.hour;
        final minute = time.minute;
        
        // Aynı saatin eklenip eklenmediğini kontrol et
        final existingTime = _customTimes.any((t) => 
            t['hour'] == hour && t['minute'] == minute);
        
        if (existingTime) {
          IslamicSnackbar.showWarning(
            AppLocalizations.of(context)?.customTimesAlreadyExists ?? 'Zaten Mevcut',
            AppLocalizations.of(context)?.customTimesAlreadyExistsMessage ?? 'Bu saat zaten eklenmiş',
          );
          isLoading.value = false;
          return;
        }

        setState(() {
          _customTimes.add({
            'hour': hour,
            'minute': minute,
            'isActive': true,
          });
        });

      await  _saveCustomTimes();
      await  _scheduleTimeNotifications();

      isLoading.value = false;

        final timeString = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        final successMessage = AppLocalizations.of(context)?.customTimesAddSuccessMessage(timeString) ?? '$timeString saatinde günlük hatırlatıcı aktif';
        IslamicSnackbar.showSuccess(
          AppLocalizations.of(context)?.customTimesAddSuccess ?? 'Saat Eklendi 🕐',
          successMessage,
        );
      },
      initialTime: CustomTime(
        hours: TimeOfDay.now().hour,
        minutes: TimeOfDay.now().minute,
      ),
      displaySubmitButton: true,
      use24hFormat: true,
       headerBuilder: (context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                AppLocalizations.of(context)?.customTimesPickerTitle ?? 'Saat Seçin',
                style: const TextStyle(
                  color:emeraldGreen ,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: emeraldGreen),
            ),
          ],
        ),
      ),
    ).show(context);
  }

  Future<void> _toggleTime(int index, bool isActive) async {
    // Store localized strings before async operations
    final activeTitle = AppLocalizations.of(context)?.customTimesToggleActive ?? 'Aktif Edildi';
    final inactiveTitle = AppLocalizations.of(context)?.customTimesToggleInactive ?? 'Devre Dışı';
    final activeMessage = AppLocalizations.of(context)?.customTimesToggleActiveMessage ?? 'Hatırlatıcı aktif';
    final inactiveMessage = AppLocalizations.of(context)?.customTimesToggleInactiveMessage ?? 'Hatırlatıcı devre dışı';

    setState(() {
      _customTimes[index]['isActive'] = isActive;
    });

    await _saveCustomTimes();
    await _scheduleTimeNotifications();

    IslamicSnackbar.showInfo(
      isActive ? activeTitle : inactiveTitle,
      isActive ? activeMessage : inactiveMessage,
    );
  }

  Future<void> _deleteTime(int index) async {
    final timeData = _customTimes[index];
    final timeString = '${timeData['hour'].toString().padLeft(2, '0')}:${timeData['minute'].toString().padLeft(2, '0')}';

    // Store localized strings
    final deleteTitle = AppLocalizations.of(context)?.customTimesDeleteTitle ?? 'Saati Sil?';
    final deleteMessageTemplate = AppLocalizations.of(context)?.customTimesDeleteMessage(timeString) ?? ' $timeString saatindeki hatırlatıcıyı silmek istediğinizden emin misiniz?';
    
    final cancelText = AppLocalizations.of(context)?.customTimesDeleteCancel ?? 'İptal';
    final confirmText = AppLocalizations.of(context)?.customTimesDeleteConfirm ?? 'Sil';
    final successTitle = AppLocalizations.of(context)?.customTimesDeleteSuccess ?? 'Silindi 🗑️';
    final successMessageTemplate = AppLocalizations.of(context)?.customTimesDeleteSuccessMessage(timeString) ?? '$timeString saati başarıyla silindi';

    // Onay dialog'u - settings_screen.dart tarzında minimal ve İslami
    final confirmed = await Get.dialog<bool>(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 300),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF8F6F0), Color(0xFFF0E9D2)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: goldColor.withAlpha(102),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: darkGreen.withAlpha(51),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const RadialGradient(
                          colors: [lightGold, goldColor],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: emeraldGreen,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        deleteTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: emeraldGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Divider
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      goldColor.withAlpha(77),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      deleteMessageTemplate,
                      style: const TextStyle(
                        fontSize: 14,
                        color: emeraldGreen,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    
                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Get.back(result: false),
                            style: TextButton.styleFrom(
                              backgroundColor: lightGold.withAlpha(77),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: goldColor.withAlpha(77),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Text(
                              cancelText,
                              style: const TextStyle(
                                color: emeraldGreen,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Get.back(result: true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade400,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 2,
                            ),
                            child: Text(
                              confirmText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
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
      ),
    );

    if (confirmed == true) {
      setState(() {
        _customTimes.removeAt(index);
      });

      await _saveCustomTimes();
      await _scheduleTimeNotifications();

     
      IslamicSnackbar.showSuccess(successTitle, successMessageTemplate);
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