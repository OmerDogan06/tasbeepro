import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/sound_service.dart';
import '../services/vibration_service.dart';
import '../services/language_service.dart';
import '../l10n/app_localizations.dart';
import '../widgets/islamic_snackbar.dart';
import 'reminder_screen.dart';
import 'custom_reminder_times_screen.dart';
import 'widget_stats_screen.dart';
import 'permissions_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ScrollController languageScrollController = ScrollController();
  String appVersion = '';

  @override
  void initState() {
    super.initState();
    _getAppVersion();
  }

  Future<void> _getAppVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        appVersion = "${packageInfo.version}+${packageInfo.buildNumber}";
      });
    } catch (e) {
      setState(() {
        appVersion = '1.0.0';
      });
    }
  }

  // İslami renk paleti
  static const emeraldGreen = Color(0xFF2D5016);
  static const goldColor = Color(0xFFD4AF37);
  static const lightGold = Color(0xFFF5E6A8);
  static const darkGreen = Color(0xFF1A3409);

  String _getSoundVolumeText(BuildContext context, int volume) {
    switch (volume) {
      case 0:
        return AppLocalizations.of(context)?.soundVolumeLow ?? 'Düşük';
      case 1:
        return AppLocalizations.of(context)?.soundVolumeMedium ?? 'Orta';
      case 2:
        return AppLocalizations.of(context)?.soundVolumeHigh ?? 'Yüksek';
      default:
        return AppLocalizations.of(context)?.soundVolumeHigh ?? 'Yüksek';
    }
  }

  @override
  Widget build(BuildContext context) {
    final soundService = Get.find<SoundService>();
    final vibrationService = Get.find<VibrationService>();
    TextDirection direction = Directionality.of(context);

    return PopScope(
      canPop: true,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Color(0xFF2D5016),
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: const Color(0xFFF8F6F0),
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(56),
            child: SafeArea(
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
                        color: darkGreen.withAlpha(39),
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
                    icon: const Icon(
                      Icons.arrow_back,
                      color: emeraldGreen,
                      size: 20,
                    ),
                    onPressed: () => Get.back(),
                  ),
                ),
                title: Text(
                  AppLocalizations.of(context)?.settingsTitle ?? 'Ayarlar',
                  style: const TextStyle(
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
                      colors: [Color(0xFFFFFDF7), Color(0xFFF8F6F0)],
                    ),
                  ),
                ),
              ),
            ),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(10),
              children: [
                // Ses ve Titreşim Ayarları
                _buildSectionHeader(
                  context,
                  AppLocalizations.of(context)?.settingsSoundVibration ??
                      'Ses ve Titreşim',
                ),
                _buildIslamicCard([
                  Obx(
                    () => _buildIslamicSwitchTile(
                      icon: Icons.volume_up,
                      title:
                          AppLocalizations.of(context)?.settingsSoundEffect ??
                          'Ses Efekti',
                      subtitle:
                          AppLocalizations.of(context)?.settingsSoundSubtitle ??
                          'Dokunma sesini aç/kapat',
                      value: soundService.isSoundEnabled,
                      onChanged: (value) => soundService.toggleSound(),
                    ),
                  ),
                  _buildDivider(),
                  Obx(
                    () => _buildIslamicListTile(
                      icon: Icons.volume_down,
                      title:
                          AppLocalizations.of(context)?.soundVolumeTitle ??
                          'Ses Seviyesi',
                      subtitle: _getSoundVolumeText(
                        context,
                        soundService.soundVolume,
                      ),
                      onTap: () =>
                          _showSoundVolumeDialog(context, soundService),
                          direction: direction
                    ),
                  ),
                  _buildDivider(),
                  Obx(
                    () => _buildIslamicListTile(
                      icon: Icons.vibration,
                      title:
                          AppLocalizations.of(context)?.settingsVibration ??
                          'Titreşim',
                      subtitle: vibrationService.vibrationLevelText,
                      onTap: () =>
                          _showVibrationDialog(context, vibrationService),
                          direction: direction
                    ),
                  ),
                ]),

                const SizedBox(height: 24),

                // İzinler
                _buildSectionHeader(
                  context,
                  AppLocalizations.of(context)?.settingsPermissions ??
                      'İzinler',
                ),
                _buildIslamicCard([
                  _buildIslamicListTile(
                    icon: Icons.security,
                    title:
                        AppLocalizations.of(
                          context,
                        )?.settingsPermissionsTitle ??
                        'Uygulama İzinleri',
                    subtitle:
                        AppLocalizations.of(
                          context,
                        )?.settingsPermissionsSubtitle ??
                        'Uygulama izinlerini görüntüle ve yönet',
                    onTap: () => Get.to(
                      () => const PermissionsScreen(),
                      transition: Transition.rightToLeft,
                      duration: const Duration(milliseconds: 300),
                    ),
                    direction: direction
                  ),
                ]),

                const SizedBox(height: 24),

                // Dil Ayarları
                _buildSectionHeader(
                  context,
                  AppLocalizations.of(context)?.settingsLanguage ?? 'Dil',
                ),
                _buildIslamicCard([
                  _buildIslamicListTile(
                    icon: Icons.language,
                    title:
                        AppLocalizations.of(context)?.settingsLanguage ?? 'Dil',
                    subtitle:
                        AppLocalizations.of(
                          context,
                        )?.settingsLanguageSubtitle ??
                        'Uygulama dilini değiştir',
                    onTap: () => _showLanguageDialog(context),
                    direction: direction
                  ),
                ]),

                const SizedBox(height: 24),

                // Hatırlatıcılar (Pro Özelliği)
                _buildSectionHeader(
                  context,
                  AppLocalizations.of(context)?.settingsReminders ??
                      'Hatırlatıcılar 💎',
                  trailing: Container(
                    decoration: BoxDecoration(
                      gradient: const RadialGradient(
                        colors: [lightGold, goldColor],
                        center: Alignment(-0.2, -0.2),
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: darkGreen.withAlpha(39),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: IconButton(
                      padding: const EdgeInsets.all(2),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      style: ButtonStyle(
                        overlayColor: WidgetStateProperty.all(
                          Colors.transparent,
                        ),
                      ),
                      icon: const Icon(
                        Icons.info_outline,
                        color: emeraldGreen,
                        size: 30,
                      ),
                      onPressed: () => _showNotificationSettingsDialog(context),
                    ),
                  ),
                ),

                // Bilgilendirme kartı - Android bildirim kısıtlamaları
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFF9E6), Color(0xFFFFF3D1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: goldColor.withAlpha(77),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: darkGreen.withAlpha(13),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.info_outline,
                          color: Colors.orange.shade700,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(
                                context,
                              )?.settingsReminderWarning ??
                              'Android güvenlik nedeniyle 5 dakikadan az aralıklı bildirimleri kısıtlar. Hatırlatıcılarınızı en az 5 dakika arayla ayarlayın.',
                          style: TextStyle(
                            color: emeraldGreen.withAlpha(204),
                            fontSize: 11,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _buildIslamicCard([
                  _buildIslamicListTile(
                    icon: Icons.notifications,
                    title:
                        AppLocalizations.of(context)?.settingsZikirReminder ??
                        'Zikir Hatırlatıcısı',
                    subtitle:
                        AppLocalizations.of(
                          context,
                        )?.settingsReminderSubtitle ??
                        'Hatırlatıcıları görüntüle ve yönet',
                    onTap: () => Get.to(
                      () => const ReminderScreen(),
                      transition: Transition.rightToLeft,
                      duration: const Duration(milliseconds: 300),
                    ),
                    direction: direction
                  ),
                  _buildDivider(),
                  _buildIslamicListTile(
                    icon: Icons.schedule,
                    title:
                        AppLocalizations.of(context)?.settingsReminderTimes ??
                        'Hatırlatma Saatleri',
                    subtitle:
                        AppLocalizations.of(
                          context,
                        )?.settingsReminderTimesSubtitle ??
                        'Günlük tekrarlanan bildirimler',
                    onTap: () => Get.to(
                      () => const CustomReminderTimesScreen(),
                      transition: Transition.rightToLeft,
                      duration: const Duration(milliseconds: 300),
                    ),
                    direction: direction
                  ),
                ]),

                const SizedBox(height: 24),

                // Widget
                _buildSectionHeader(
                  context,
                  AppLocalizations.of(context)?.settingsWidget ?? 'Widget 📱',
                ),
                _buildIslamicCard([
                  _buildIslamicListTile(
                    icon: Icons.widgets,
                    title:
                        AppLocalizations.of(context)?.settingsWidgetStats ??
                        'Widget İstatistikleri',
                    subtitle:
                        AppLocalizations.of(
                          context,
                        )?.settingsWidgetStatsSubtitle ??
                        'Widget\'tan yapılan tüm zikirlerinizi görün',
                    onTap: () => Get.to(
                      () => const WidgetStatsScreen(),
                      transition: Transition.rightToLeft,
                      duration: const Duration(milliseconds: 300),
                    ),
                    direction: direction
                  ),
                  _buildDivider(),
                  _buildIslamicListTile(
                    icon: Icons.info_outline,
                    title:
                        AppLocalizations.of(context)?.settingsWidgetInfo ??
                        'Widget Hakkında',
                    subtitle:
                        AppLocalizations.of(
                          context,
                        )?.settingsWidgetInfoSubtitle ??
                        'Widget nasıl kullanılır ve ana ekrana eklenir',
                    onTap: () => _showWidgetInfoDialog(context),
                    direction: direction
                  ),
                ]),

                const SizedBox(height: 24),

                // Hakkında
                _buildSectionHeader(
                  context,
                  AppLocalizations.of(context)?.settingsAbout ?? 'Hakkında',
                ),
                _buildIslamicCard([
                  _buildIslamicListTile(
                    icon: Icons.info,
                    title:
                        AppLocalizations.of(context)?.settingsAppInfo ??
                        'Uygulama Hakkında',
                    subtitle:
                        '${AppLocalizations.of(context)?.appInfoTitle ?? "Tasbee Pro"} v${appVersion.isNotEmpty ? appVersion : "1.0.0"}',
                    onTap: () => _showAboutDialog(context),
                    direction: direction
                  ),
                  _buildDivider(),
                  _buildIslamicListTile(
                    icon: Icons.star,
                    title:
                        AppLocalizations.of(context)?.settingsRateApp ??
                        'Uygulamayı Değerlendir',
                    subtitle:
                        AppLocalizations.of(context)?.settingsRateSubtitle ??
                        'Play Store\'da değerlendir',
                    onTap: () => _openGooglePlay(),
                    direction: direction
                  ),
                  _buildDivider(),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 0, bottom: 6),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [goldColor, lightGold]),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: emeraldGreen,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildIslamicCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFDF7), Color(0xFFF5F3E8)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: goldColor.withAlpha(77), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withAlpha(25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildIslamicListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required TextDirection direction,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: const RadialGradient(
            colors: [lightGold, goldColor],
            center: Alignment(-0.2, -0.2),
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: darkGreen.withAlpha(39),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: emeraldGreen, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: emeraldGreen,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: emeraldGreen.withAlpha(179), fontSize: 12),
      ),
      trailing: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: goldColor.withAlpha(51),
          borderRadius: BorderRadius.circular(8),
        ),
        child:direction == TextDirection.ltr
            ? const Icon(
                Icons.keyboard_arrow_right,
                color: emeraldGreen,
                size: 20,
              )
            :
         const Icon(
          Icons.keyboard_arrow_left,
          color: emeraldGreen,
          size: 20,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildIslamicSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      secondary: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: const RadialGradient(
            colors: [lightGold, goldColor],
            center: Alignment(-0.2, -0.2),
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: darkGreen.withAlpha(39),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: emeraldGreen, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: emeraldGreen,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: emeraldGreen.withAlpha(179), fontSize: 12),
      ),
      value: value,
      onChanged: onChanged,
      thumbColor: WidgetStateProperty.resolveWith<Color?>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return goldColor;
        }
        return emeraldGreen;
      }),
      tileColor: Colors.transparent,
      overlayColor: WidgetStateProperty.resolveWith<Color?>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.pressed)) {
          return goldColor.withAlpha(25);
        }
        return null;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return goldColor;
        }
        return goldColor;
      }),

      trackColor: WidgetStateProperty.resolveWith<Color?>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return Colors.transparent;
        }
        return Colors.transparent;
      }),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            goldColor.withAlpha(77),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final languageService = Get.find<LanguageService>();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 300, maxHeight: 400),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF8F6F0), Color(0xFFF0E9D2)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: goldColor.withAlpha(102), width: 1.5),
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
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const RadialGradient(
                          colors: [lightGold, goldColor],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.language,
                        color: emeraldGreen,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)?.languageSelectionTitle ??
                            'Dil Seçimi',
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

              // Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  AppLocalizations.of(context)?.languageSelectionSubtitle ??
                      'Uygulama dilini seçin',
                  style: TextStyle(
                    fontSize: 12,
                    color: emeraldGreen.withAlpha(179),
                  ),
                ),
              ),

              // Divider
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
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

              // Language options
              Expanded(
                child: ScrollbarTheme(
                  data: ScrollbarThemeData(
                    thumbColor: WidgetStateProperty.all(goldColor),

                    radius: const Radius.circular(10),
                    thickness: WidgetStateProperty.all(6),
                  ),
                  child: Scrollbar(
                    controller: languageScrollController,
                    thumbVisibility: true,
                    trackVisibility: true,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              controller: languageScrollController,
                              itemCount:
                                  languageService.supportedLanguages.length,
                              itemBuilder: (context, index) {
                                var language =
                                    languageService.supportedLanguages[index];
                                return _buildLanguageOption(
                                  languageService,
                                  language,
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Close button
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                backgroundColor: lightGold.withAlpha(77),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: goldColor.withAlpha(77),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Text(
                                AppLocalizations.of(context)?.close ?? 'Kapat',
                                style: const TextStyle(
                                  color: emeraldGreen,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    LanguageService service,
    Map<String, String> language,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: service.currentLanguage == language['code']
            ? goldColor.withAlpha(38)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: service.currentLanguage == language['code']
              ? goldColor.withAlpha(128)
              : goldColor.withAlpha(51),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          onTap: () async {
            await service.changeLanguage(language['code']!);
            if (!mounted) return; // ✅ widget hala yaşıyor mu kontrol et
            Navigator.of(context).pop();
            IslamicSnackbar.showSuccess(
              AppLocalizations.of(context)?.languageChanged ??
                  'Dil Değiştirildi',
              AppLocalizations.of(context)?.languageChangedMessage ??
                  'Uygulama dili başarıyla değiştirildi',
              duration: const Duration(seconds: 2),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Row(
              children: [
                Text(language['flag']!, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    language['name']!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: service.currentLanguage == language['code']
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: emeraldGreen,
                    ),
                  ),
                ),
                if (service.currentLanguage == language['code'])
                  Icon(Icons.check_circle, color: goldColor, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSoundVolumeDialog(BuildContext context, SoundService service) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 200),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF8F6F0), Color(0xFFF0E9D2)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: goldColor.withAlpha(102), width: 1.5),
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
              // Mini header
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: const RadialGradient(
                          colors: [lightGold, goldColor],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.volume_down,
                        color: emeraldGreen,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)?.soundVolumeTitle ??
                          'Ses Seviyesi',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: emeraldGreen,
                      ),
                    ),
                  ],
                ),
              ),

              // Mini divider
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 12),
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

              // Tiny options
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    _buildSoundVolumeOption(
                      service,
                      0,
                      AppLocalizations.of(context)?.soundVolumeLow ?? 'Düşük',
                    ),
                    _buildSoundVolumeOption(
                      service,
                      1,
                      AppLocalizations.of(context)?.soundVolumeMedium ?? 'Orta',
                    ),
                    _buildSoundVolumeOption(
                      service,
                      2,
                      AppLocalizations.of(context)?.soundVolumeHigh ?? 'Yüksek',
                    ),

                    const SizedBox(height: 8),

                    // Mini close button
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          backgroundColor: lightGold.withAlpha(77),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          overlayColor: Color(0xFFD4AF37).withAlpha(26),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: goldColor.withAlpha(77),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)?.vibrationOk ?? 'Tamam',
                          style: TextStyle(
                            color: emeraldGreen,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVibrationDialog(BuildContext context, VibrationService service) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 200),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF8F6F0), Color(0xFFF0E9D2)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: goldColor.withAlpha(102), width: 1.5),
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
              // Mini header
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: const RadialGradient(
                          colors: [lightGold, goldColor],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.vibration,
                        color: emeraldGreen,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)?.vibrationTitle ??
                          'Titreşim',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: emeraldGreen,
                      ),
                    ),
                  ],
                ),
              ),

              // Mini divider
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 12),
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

              // Tiny options
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    _buildVibrationOption(
                      service,
                      0,
                      AppLocalizations.of(context)?.vibrationOff ?? 'Kapalı',
                    ),
                    _buildVibrationOption(
                      service,
                      1,
                      AppLocalizations.of(context)?.vibrationLight ?? 'Hafif',
                    ),
                    _buildVibrationOption(
                      service,
                      2,
                      AppLocalizations.of(context)?.vibrationMedium ?? 'Orta',
                    ),
                    _buildVibrationOption(
                      service,
                      3,
                      AppLocalizations.of(context)?.vibrationHigh ?? 'Yüksek',
                    ),

                    const SizedBox(height: 8),

                    // Mini close button
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          backgroundColor: lightGold.withAlpha(77),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          overlayColor: Color(0xFFD4AF37).withAlpha(26),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: goldColor.withAlpha(77),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)?.vibrationOk ?? 'Tamam',
                          style: TextStyle(
                            color: emeraldGreen,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSoundVolumeOption(
    SoundService service,
    int level,
    String title,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: service.soundVolume == level
            ? goldColor.withAlpha(38)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: service.soundVolume == level
              ? goldColor.withAlpha(128)
              : goldColor.withAlpha(51),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          overlayColor: WidgetStateProperty.all(
            Color(0xFFD4AF37).withAlpha(26),
          ),
          borderRadius: BorderRadius.circular(8),
          onTap: () async {
            await service.setSoundVolume(level);
            // Test sesi çal
            await service.playClickSound();
            if (!mounted) return;
            Navigator.of(context).pop();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: service.soundVolume == level
                        ? goldColor
                        : emeraldGreen.withAlpha(102),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Obx(
                    () => Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: service.soundVolume == level
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: emeraldGreen,
                      ),
                    ),
                  ),
                ),
                if (service.soundVolume == level)
                  Icon(Icons.check_circle, color: goldColor, size: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVibrationOption(
    VibrationService service,
    int level,
    String title,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: service.vibrationLevel == level
            ? goldColor.withAlpha(38)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: service.vibrationLevel == level
              ? goldColor.withAlpha(128)
              : goldColor.withAlpha(51),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          overlayColor: WidgetStateProperty.all(
            Color(0xFFD4AF37).withAlpha(26),
          ),
          borderRadius: BorderRadius.circular(8),
          onTap: () => service.setVibrationLevel(level).then((_) {
            if (!mounted) return; // ✅ widget hala yaşıyor mu kontrol et
            Navigator.of(context).pop();
          }),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: service.vibrationLevel == level
                        ? goldColor
                        : emeraldGreen.withAlpha(102),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Obx(
                    () => Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: service.vibrationLevel == level
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: emeraldGreen,
                      ),
                    ),
                  ),
                ),
                if (service.vibrationLevel == level)
                  Icon(Icons.check_circle, color: goldColor, size: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showWidgetInfoDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF8F6F0), Color(0xFFF0E9D2)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: goldColor.withAlpha(102), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: darkGreen.withAlpha(51),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        gradient: const RadialGradient(
                          colors: [lightGold, goldColor],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.widgets,
                        color: emeraldGreen,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)?.widgetInfoTitle ??
                            'Tasbee Widget Hakkında 📱',
                        style: TextStyle(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Widget bilgileri
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: lightGold.withAlpha(51),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: goldColor.withAlpha(77),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)?.widgetFeatures ??
                                '✨ Widget Özellikleri:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: emeraldGreen,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildWidgetFeature(
                            '📱',
                            AppLocalizations.of(context)?.widgetFeature1 ??
                                'Ana ekranınızda kolayca zikir çekebilirsiniz',
                          ),
                          _buildWidgetFeature(
                            '💾',
                            AppLocalizations.of(context)?.widgetFeature2 ??
                                'Tüm zikirleriniz kalıcı olarak kaydedilir',
                          ),
                          _buildWidgetFeature(
                            '📊',
                            AppLocalizations.of(context)?.widgetFeature3 ??
                                'Widget istatistiklerini takip edebilirsiniz',
                          ),
                          _buildWidgetFeature(
                            '🎯',
                            AppLocalizations.of(context)?.widgetFeature4 ??
                                'Hedef sayısı belirleyebilirsiniz',
                          ),
                          _buildWidgetFeature(
                            '🔄',
                            AppLocalizations.of(context)?.widgetFeature5 ??
                                'Farklı zikir türleri seçebilirsiniz',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Widget ekleme butonu
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _addWidgetToHomeScreen();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: goldColor,
                          foregroundColor: emeraldGreen,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        icon: const Icon(Icons.add_to_home_screen, size: 20),
                        label: Text(
                          AppLocalizations.of(context)?.widgetAddTitle ??
                              'Widget Ekle',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Kapat butonu
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          backgroundColor: lightGold.withAlpha(77),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: goldColor.withAlpha(77),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)?.close ?? 'Kapat',
                          style: TextStyle(
                            color: emeraldGreen,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWidgetFeature(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                color: emeraldGreen.withAlpha(204),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addWidgetToHomeScreen() async {
    try {
      HapticFeedback.lightImpact();

      // Android widget picker'ını açmak için platform channel kullanıyoruz
      const platform = MethodChannel('com.skyforgestudios.tasbeepro/widget');
      await platform.invokeMethod('openWidgetPicker');
    } catch (e) {
      // Platform channel başarısız olursa manual talimatlar göster
      HapticFeedback.lightImpact();
      if (!mounted) return; // ✅ widget hala yaşıyor mu kontrol et
      IslamicSnackbar.showSuccess(
        AppLocalizations.of(context)?.widgetAddSuccess ?? 'Widget Ekleme',
        AppLocalizations.of(context)?.widgetAddSuccessMessage ??
            'Ana ekranınızda boş bir alana uzun basın ve "Widget\'lar" seçeneğini seçin. Ardından "Tasbee Pro" widget\'ını bulup ekleyin.',
        duration: const Duration(seconds: 5),
      );
    }
  }

  void _showAboutDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 200),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF8F6F0), Color(0xFFF0E9D2)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: goldColor.withAlpha(102), width: 1.5),
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
              // Mini header
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: const RadialGradient(
                          colors: [lightGold, goldColor],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.info,
                        color: emeraldGreen,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)?.appInfoTitle ??
                          'Tasbee Free',
                      style: TextStyle(
                        color: emeraldGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Mini divider
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 12),
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

              // Tiny content
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFFDF7), Color(0xFFF5F3E8)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: goldColor.withAlpha(51)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${AppLocalizations.of(context)?.appInfoVersionLabel ?? ''} ${appVersion.isNotEmpty ? appVersion : "1.0.0"}',
                            style: const TextStyle(
                              color: emeraldGreen,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppLocalizations.of(context)?.appInfoDescription ??
                                'Offline çalışan dijital tesbih uygulaması.',
                            style: TextStyle(color: emeraldGreen, fontSize: 10),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Mini close button
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          backgroundColor: lightGold.withAlpha(77),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          overlayColor: Color(0xFFD4AF37).withAlpha(26),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: goldColor.withAlpha(77),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)?.ok ?? 'Tamam',
                          style: TextStyle(
                            color: emeraldGreen,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationSettingsDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 400),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF8F6F0), Color(0xFFF0E9D2)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: goldColor.withAlpha(102), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: darkGreen.withAlpha(51),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        gradient: const RadialGradient(
                          colors: [lightGold, goldColor],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.settings_applications,
                        color: emeraldGreen,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(
                              context,
                            )?.notificationSettingsDialogTitle ??
                            'Bildirim Ayarları Yardımı 🔔',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: emeraldGreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Kapat butonu
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        color: emeraldGreen.withAlpha(153),
                        size: 20,
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
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      scrollbarTheme: ScrollbarThemeData(
                        thumbColor: WidgetStateProperty.all(
                          goldColor.withAlpha(153),
                        ),
                        trackColor: WidgetStateProperty.all(
                          goldColor.withAlpha(51),
                        ),
                        trackBorderColor: WidgetStateProperty.all(
                          Colors.transparent,
                        ),
                        radius: const Radius.circular(8),
                        thickness: WidgetStateProperty.all(6),
                      ),
                    ),
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Ana mesaj
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: lightGold.withAlpha(51),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: goldColor.withAlpha(77),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                AppLocalizations.of(
                                      context,
                                    )?.notificationSettingsDialogMessage ??
                                    'Tasbee Pro\'nun seni doğru zamanda hatırlatabilmesi için cihaz ayarlarında bazı izinlerin açık olması gerekir.\nLütfen aşağıdakileri kontrol et:',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: emeraldGreen,
                                  height: 1.4,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Ayar listesi
                            _buildNotificationSetting(
                              '🔔',
                              AppLocalizations.of(
                                    context,
                                  )?.notificationSettingsPermission ??
                                  'Bildirim izni: Uygulama bildirimlerine izin verildiğinden emin ol.',
                            ),
                            _buildNotificationSetting(
                              '🔋',
                              AppLocalizations.of(
                                    context,
                                  )?.notificationSettingsBattery ??
                                  'Pil ve arka plan ayarları: Tasbee Pro\'nun arka planda çalışmasına izin ver.',
                            ),
                            _buildNotificationSetting(
                              '🔕',
                              AppLocalizations.of(
                                    context,
                                  )?.notificationSettingsDoNotDisturb ??
                                  'Kesintilere izin ver (isteğe bağlı): Sessiz moddayken de hatırlatmaların görünmesi için bu seçeneği aktif edebilirsin.',
                            ),
                            _buildNotificationSetting(
                              '🔒',
                              AppLocalizations.of(
                                    context,
                                  )?.notificationSettingsLockScreen ??
                                  'Kilit ekranında göster: Bildirimlerin kilit ekranında görünmesine izin ver. (Bazı cihazlarda bildirimler gizli olabilir.)',
                            ),

                            const SizedBox(height: 12),

                            // İpucu
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFF9E6),
                                    Color(0xFFFFF3D1),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.orange.withAlpha(102),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Text(
                                    '💡',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      AppLocalizations.of(
                                            context,
                                          )?.notificationSettingsRestart ??
                                          'Cihaz yeniden başladıktan sonra uygulamayı bir kez açmak, bildirim sistemini yeniler.',
                                      style: TextStyle(
                                        color: emeraldGreen.withAlpha(204),
                                        fontSize: 11,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationSetting(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: emeraldGreen.withAlpha(204),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openGooglePlay() async {
    const String packageName =
        'com.skyforgestudios.tasbeepro'; // Uygulamanızın gerçek package name'ini kullanın
    final Uri playStoreUri = Uri.parse(
      'https://play.google.com/store/apps/details?id=$packageName',
    );
    final Uri marketUri = Uri.parse('market://details?id=$packageName');

    try {
      // Önce Google Play Store uygulaması ile açmayı deneyin
      if (await canLaunchUrl(marketUri)) {
        await launchUrl(marketUri, mode: LaunchMode.externalApplication);
      }
      // Google Play Store uygulaması yoksa web browser ile açın
      else if (await canLaunchUrl(playStoreUri)) {
        await launchUrl(playStoreUri, mode: LaunchMode.externalApplication);
      } else {
        // Her ikisi de başarısız olursa snackbar göster
        if (!mounted) return;
        IslamicSnackbar.showInfo(
          AppLocalizations.of(context)?.thanks ?? 'Teşekkürler',
          AppLocalizations.of(context)?.rateAppMessage ??
              'Google Play Store\'a erişilemiyor. Lütfen manuel olarak derecelendirin.',
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      // Hata durumunda snackbar göster
      if (!mounted) return;
      IslamicSnackbar.showInfo(
        AppLocalizations.of(context)?.thanks ?? 'Teşekkürler',
        AppLocalizations.of(context)?.rateAppMessage ??
            'Google Play Store açılamadı. Değerlendirmeniz bizim için çok önemli!',
        duration: const Duration(seconds: 3),
      );
    }
  }
}
