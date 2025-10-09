import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../services/notification_service.dart';
import '../widgets/islamic_snackbar.dart';
import '../widgets/custom_bottom_picker.dart';
import '../l10n/app_localizations.dart';

class AddReminderScreen extends StatefulWidget {
  const AddReminderScreen({super.key});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  static const emeraldGreen = Color(0xFF2D5016);
  static const goldColor = Color(0xFFD4AF37);
  static const lightGold = Color(0xFFF5E6A8);
  static const darkGreen = Color(0xFF1A3409);

  final NotificationService _notificationService = Get.find<NotificationService>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  
  DateTime _selectedDateTime = DateTime.now().add(const Duration(hours: 1));
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        
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
            AppLocalizations.of(context)?.addReminderTitle ?? 'Yeni Hatırlatıcı',
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
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Card
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 24),
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
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: goldColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Icon(
                          Icons.notifications_active,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)?.addReminderDescription ?? 'Belirlediğiniz tarih ve saatte zikir yapmayı hatırlatan bildirim alın',
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
                
                // Form
                _buildSectionHeader(AppLocalizations.of(context)?.addReminderTitleLabel ?? 'Başlık'),
                _buildInputCard(
                  child: TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)?.addReminderTitleHint ?? 'Zikir Zamanı',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(8),
                    ),
                    style: const TextStyle(
                      color: emeraldGreen,
                      fontSize: 14,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Message Input
                _buildSectionHeader(AppLocalizations.of(context)?.addReminderMessageLabel ?? 'Mesaj (Opsiyonel)'),
                _buildInputCard(
                  child: TextField(
                    controller: _messageController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)?.addReminderMessageHint ?? 'Zikir yapma zamanı geldi!',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(8),
                    ),
                    style: const TextStyle(
                      color: emeraldGreen,
                      fontSize: 14,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Date & Time Selection
                _buildSectionHeader(AppLocalizations.of(context)?.addReminderDateTimeLabel ?? 'Tarih ve Saat'),
                _buildInputCard(
                  child: Column(
                    children: [
                      // Selected DateTime Display
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: lightGold.withAlpha(77),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: goldColor.withAlpha(77)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.event,
                              color: emeraldGreen,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${_selectedDateTime.day.toString().padLeft(2, '0')}/${_selectedDateTime.month.toString().padLeft(2, '0')}/${_selectedDateTime.year} - ${_selectedDateTime.hour.toString().padLeft(2, '0')}:${_selectedDateTime.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  color: emeraldGreen,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Date & Time Buttons
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateTimeButton(
                              icon: Icons.calendar_today,
                              label: AppLocalizations.of(context)?.addReminderSelectDate ?? 'Tarih Seç',
                              onPressed: _selectDate,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildDateTimeButton(
                              icon: Icons.access_time,
                              label: AppLocalizations.of(context)?.addReminderSelectTime ?? 'Saat Seç',
                              onPressed: _selectTime,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Add Button
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 10),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _addReminder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: emeraldGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)?.addReminderSubmitButton ?? 'Hatırlatıcı Ekle',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      margin: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          color: emeraldGreen,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInputCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFDF7),
            Color(0xFFF5F3E8),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: goldColor.withAlpha(77),
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
      child: child,
    );
  }

  Widget _buildDateTimeButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: emeraldGreen),
      label: Text(label, style: const TextStyle(color: emeraldGreen, fontSize: 14, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: goldColor,
        foregroundColor: emeraldGreen,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    CustomBottomPicker.date(
      backgroundColor: Colors.white,
      buttonSingleColor: emeraldGreen,
      onSubmit: (date) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            _selectedDateTime.hour,
            _selectedDateTime.minute,
          );
        });
      },
      initialDateTime: _selectedDateTime,
      minDateTime: DateTime.now(),
      maxDateTime: DateTime.now().add(const Duration(days: 365)),
      displaySubmitButton: true,
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
                AppLocalizations.of(context)?.addReminderDatePickerTitle ?? 'Tarih Seçin',
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

  Future<void> _selectTime() async {
    CustomBottomPicker.time(
      backgroundColor: Colors.white,
      buttonSingleColor: emeraldGreen,
      
      onSubmit: (time) {
        setState(() {
          _selectedDateTime = DateTime(
            _selectedDateTime.year,
            _selectedDateTime.month,
            _selectedDateTime.day,
            time.hour,
            time.minute,
          );
        });
      },
      initialTime: CustomTime(
        hours: _selectedDateTime.hour,
        minutes: _selectedDateTime.minute,
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
                AppLocalizations.of(context)?.addReminderTimePickerTitle ?? 'Saat Seçin',
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

  Future<void> _addReminder() async {
    if (_selectedDateTime.isBefore(DateTime.now())) {
      IslamicSnackbar.showWarning(
        AppLocalizations.of(context)?.addReminderInvalidDate ?? 'Geçersiz Tarih',
        AppLocalizations.of(context)?.addReminderInvalidDateMessage ?? 'Geçmiş bir tarih seçemezsiniz',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Store localized strings before async operations
    final titleHint = AppLocalizations.of(context)?.addReminderTitleHint ?? 'Zikir Zamanı 🕌';
    final defaultMessage = AppLocalizations.of(context)?.addReminderDefaultMessage ?? 'Zikir yapma zamanı geldi!';
    final successTitle = AppLocalizations.of(context)?.addReminderSuccess ?? 'Hatırlatıcı Eklendi 🔔';
    final successMessage = AppLocalizations.of(context)?.addReminderSuccessMessage ?? 'Belirlenen zamanda bildirim gelecek';
    final errorTitle = AppLocalizations.of(context)?.addReminderError ?? 'Hata';
    final errorMessage = AppLocalizations.of(context)?.addReminderErrorMessage ?? 'Hatırlatıcı eklenirken bir hata oluştu';

    try {
      // Permission kontrolü
      final hasPermission = await _notificationService.checkNotificationPermission();
      if (!hasPermission) {
        _showPermissionDialog();
        return;
      }

      final reminderTitle = _titleController.text.trim().isEmpty 
          ? titleHint
          : _titleController.text.trim();
      final reminderMessage = _messageController.text.trim().isEmpty 
          ? defaultMessage
          : _messageController.text.trim();

      await _notificationService.scheduleCustomReminder(
        scheduledDateTime: _selectedDateTime,
        title: reminderTitle,
        message: reminderMessage,
      );

      IslamicSnackbar.showSuccess(successTitle, successMessage);

      Get.back(); // Geri dön
    } catch (e) {
      IslamicSnackbar.showError(errorTitle, errorMessage);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showPermissionDialog() {
    final context = this.context;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF8F6F0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          AppLocalizations.of(context)?.addReminderPermissionTitle ?? 'Bildirim İzni Gerekli',
          style: const TextStyle(color: emeraldGreen, fontWeight: FontWeight.bold),
        ),
        content: Text(
          AppLocalizations.of(context)?.addReminderPermissionMessage ?? 'Hatırlatıcıların çalışması için bildirim izni vermeniz gerekiyor.',
          style: const TextStyle(color: emeraldGreen),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)?.addReminderPermissionCancel ?? 'İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _notificationService.openNotificationSettings();
            },
            style: ElevatedButton.styleFrom(backgroundColor: emeraldGreen),
            child: Text(
              AppLocalizations.of(context)?.addReminderPermissionSettings ?? 'Ayarlara Git', 
              style: const TextStyle(color: Colors.white)
            ),
          ),
        ],
      ),
    );
  }
}