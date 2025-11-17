import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tasbeepro/screens/premium_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/sound_service.dart';
import '../services/vibration_service.dart';
import '../services/language_service.dart';
import '../services/subscription_service.dart';
import '../services/storage_service.dart'; // RewardFeatureType enum için
import '../services/reward_service.dart'; // RewardService için
import '../l10n/app_localizations.dart';
import '../widgets/islamic_snackbar.dart';
import '../widgets/banner_ad_widget.dart';
import 'reminder_screen.dart';
import 'custom_reminder_times_screen.dart';
import 'widget_stats_screen.dart';
import 'permissions_screen.dart';
import 'quran_reading_screen.dart';

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
            child: CustomScrollView(
              slivers: [
                // Sticky Banner Ad
                 const SliverToBoxAdapter(
                child: BannerAdWidget(),
              ),
                // Scrollable content
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      
                      // Ödüllü Reklam Sistemi (Ücretsiz Kullanıcılar için)
                      GetX<SubscriptionService>(
                        builder: (subscriptionService) {
                          final isPremium = subscriptionService.isPremium.value;
                          
                          // Premium kullanıcılar için bu bölümü gösterme
                          if (isPremium) {
                            return const SizedBox.shrink();
                          }
                          
                          return Column(
                            children: [
                              _buildSectionHeader(
                                context,
                                AppLocalizations.of(context)?.rewardSystemTitle ?? '🎁 Ödüllü Reklamlarla Özellikler',
                              ),
                              _buildRewardSystemCard(),
                              const SizedBox(height: 24),
                            ],
                          );
                        },
                      ),
                      
                      // Premium Status
                      _buildPremiumSection(context),
                      
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

                // Kur'an Okuma
                _buildSectionHeader(
                  context,
                  AppLocalizations.of(context)?.settingsQuranReading ?? 'Kur\'an Okuma 📖',
                ),
                _buildIslamicCard([
                  _buildIslamicListTile(
                    icon: Icons.menu_book,
                    title: AppLocalizations.of(context)?.settingsQuranReading.replaceAll('📖', '') ?? 'Kur\'an Okuma',
                    subtitle: AppLocalizations.of(context)?.settingsQuranReadingSubtitle ?? 'Kur\'an-ı Kerim\'i okuyun ve sureler arasında gezinin',
                    onTap: () => Get.to(
                      () => const QuranReadingScreen(),
                      transition: Transition.rightToLeft,
                      duration: const Duration(milliseconds: 300),
                    ),
                    direction: direction
                  ),
                  _buildDivider(),
                  _buildIslamicListTile(
                    icon: Icons.widgets,
                    title: AppLocalizations.of(context)?.settingsQuranWidget ?? 'Kur\'an Widget Ekle',
                    subtitle: AppLocalizations.of(context)?.settingsQuranWidgetSubtitle ?? 'Ana ekrana Kur\'an okuma widget\'ı ekleyin',
                    onTap: () => _addQuranWidgetToHomeScreen(),
                    direction: direction,
                    isPremiumFeature: true,
                    rewardFeatureType: RewardFeatureType.quranWidget,
                  ),
                ]),

                // Android 12+ Widget Uyarısı - Kur'an Widget için
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFFF8E1), Color(0xFFFFE0B2)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.withAlpha(128),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withAlpha(77),
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
                          color: Colors.orange.withAlpha(51),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.warning_amber,
                          color: Colors.orange.shade700,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)?.widgetAndroid12WarningTitle ?? 'Android Sürüm Uyarısı',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade800,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppLocalizations.of(context)?.widgetAndroid12Warning ?? 'Ana ekran widget\'larının sorunsuz çalışması için en az Android 12 (API 31) gereklidir.',
                              style: TextStyle(
                                color: Colors.orange.shade700,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

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
                    direction: direction,
                    isPremiumFeature: true,
                    rewardFeatureType: RewardFeatureType.reminders,
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
                    direction: direction,
                    isPremiumFeature: true,
                    rewardFeatureType: RewardFeatureType.reminderTimes
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
                    direction: direction,
                    isPremiumFeature: true,
                    rewardFeatureType: RewardFeatureType.dhikrWidget,
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
                    direction: direction,
                    isPremiumFeature: true,
                    rewardFeatureType: RewardFeatureType.dhikrWidget
                  ),
                ]),

                // Android 12+ Widget Uyarısı - Dhikr Widget için
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFFF8E1), Color(0xFFFFE0B2)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.withAlpha(128),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withAlpha(77),
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
                          color: Colors.orange.withAlpha(51),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.warning_amber,
                          color: Colors.orange.shade700,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)?.widgetAndroid12WarningTitle ?? 'Android Sürüm Uyarısı',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade800,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppLocalizations.of(context)?.widgetAndroid12Warning ?? 'Ana ekran widget\'larının sorunsuz çalışması için en az Android 12 (API 31) gereklidir.',
                              style: TextStyle(
                                color: Colors.orange.shade700,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

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
                    ]),
                  ),
                ),
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
    bool isPremiumFeature = false,
    RewardFeatureType? rewardFeatureType,
  }) {
    return GetX<SubscriptionService>(
      builder: (subscriptionService) {
        final isPremium = subscriptionService.isPremium.value;
        
        // Reward feature kontrolü
        bool isRewardFeatureEnabled = true;
        if (rewardFeatureType != null) {
          debugPrint("DEBUG: rewardFeatureType = $rewardFeatureType");
          switch (rewardFeatureType) {
            case RewardFeatureType.dhikrWidget:
              isRewardFeatureEnabled = subscriptionService.isDhikrWidgetEnabled;
              debugPrint("DEBUG: isDhikrWidgetEnabled = $isRewardFeatureEnabled");
              break;
            case RewardFeatureType.quranWidget:
              isRewardFeatureEnabled = subscriptionService.isQuranWidgetEnabled;
              debugPrint("DEBUG: isQuranWidgetEnabled = $isRewardFeatureEnabled");
              break;
            case RewardFeatureType.reminders:
              isRewardFeatureEnabled = subscriptionService.areRemindersEnabled;
              debugPrint("DEBUG: areRemindersEnabled = $isRewardFeatureEnabled");
              break;
            case RewardFeatureType.reminderTimes:
              isRewardFeatureEnabled = subscriptionService.areReminderTimesEnabled;
              debugPrint("DEBUG: areReminderTimesEnabled = $isRewardFeatureEnabled");
              break;
          }
        } else {
          debugPrint("DEBUG: rewardFeatureType is NULL");
        }
        
        // Feature kilitli mi? (Premium değil VE reward feature da aktif değil)
        final isLocked = isPremiumFeature && !isPremium && !isRewardFeatureEnabled;
        
        return Opacity(
          opacity: isLocked ? 0.6 : 1.0,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            leading: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: isLocked 
                        ? LinearGradient(
                            colors: [
                              Colors.grey.shade300,
                              Colors.grey.shade400,
                            ],
                          )
                        : const RadialGradient(
                            colors: [lightGold, goldColor],
                            center: Alignment(-0.2, -0.2),
                          ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: isLocked 
                            ? Colors.grey.withAlpha(39)
                            : darkGreen.withAlpha(39),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon, 
                    color: isLocked ? Colors.grey.shade600 : emeraldGreen, 
                    size: 22
                  ),
                ),
                if (isLocked)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
              ],
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isLocked 
                          ? Colors.grey.shade600 
                          : emeraldGreen,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (isPremiumFeature)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: isLocked 
                          ? LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade500])
                          : const LinearGradient(colors: [goldColor, lightGold]),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                     AppLocalizations.of(context)?.proLabel ?? 'PRO',
                      style: TextStyle(
                        color: isLocked ? Colors.white : emeraldGreen,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Text(
              isLocked ? (rewardFeatureType != null 
                  ? (AppLocalizations.of(context)?.rewardFeatureUnlockMessage ?? 'Reklam izleyerek veya premium olarak bu özelliği açabilirsiniz')
                  : (AppLocalizations.of(context)?.premiumFeatureLocked ?? 'Premium özellik - Kilidi açmak için premium olun')) 
                : subtitle,
              style: TextStyle(
                color: isLocked 
                    ? Colors.red.shade600 
                    : emeraldGreen.withAlpha(179), 
                fontSize: 12
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isLocked 
                    ? Colors.grey.withAlpha(51)
                    : goldColor.withAlpha(51),
                borderRadius: BorderRadius.circular(8),
              ),
              child: isLocked 
                  ? const Icon(
                      Icons.lock,
                      color: Colors.red,
                      size: 20,
                    )
                  : (direction == TextDirection.ltr
                      ? const Icon(
                          Icons.keyboard_arrow_right,
                          color: emeraldGreen,
                          size: 20,
                        )
                      : const Icon(
                          Icons.keyboard_arrow_left,
                          color: emeraldGreen,
                          size: 20,
                        )),
            ),
            onTap: isLocked 
                ? () {
                    HapticFeedback.lightImpact();
                    Get.defaultDialog(
                      title: AppLocalizations.of(context)?.premiumFeatureDialogTitle ?? 'Premium Özellik 💎',
                      titleStyle: const TextStyle(
                        color: emeraldGreen,
                        fontWeight: FontWeight.bold,
                      ),
                      middleText: AppLocalizations.of(context)?.premiumFeatureDialogMessage ?? 'Bu özellik premium abonelik gerektirir.\nTüm özel özelliklerin kilidini açmak için premium\'a geçin.',
                      middleTextStyle: TextStyle(
                        color: emeraldGreen.withAlpha(204),
                        fontSize: 14,
                      ),
                      backgroundColor: const Color(0xFFFFF9E6),
                      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                      contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      confirm: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [goldColor, lightGold],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back();
                            Get.to(() => const PremiumScreen(), transition: Transition.rightToLeft);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: emeraldGreen,
                          ),
                          child: Text(
                            AppLocalizations.of(context)?.upgradeConfirm ?? 'Premium\'a Geç',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      cancel: TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          AppLocalizations.of(context)?.cancel ?? 'İptal',
                          style: TextStyle(color: emeraldGreen.withAlpha(179)),
                        ),
                      ),
                    );
                  }
                : onTap,
          ),
        );
      },
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
    final subscriptionService = Get.find<SubscriptionService>();
    final isPremium = subscriptionService.isPremium.value;
    final isDhikrWidgetEnabled = subscriptionService.isDhikrWidgetEnabled;
    final canUseWidget = isPremium || isDhikrWidgetEnabled;
    
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            gradient: canUseWidget 
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFF9E6), Color(0xFFF5E6A8)],
                  )
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF8F6F0), Color(0xFFF0E9D2)],
                  ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: canUseWidget ? goldColor : goldColor.withAlpha(102), 
              width: canUseWidget ? 2 : 1.5
            ),
            boxShadow: [
              BoxShadow(
                color: canUseWidget 
                    ? goldColor.withAlpha(77)
                    : darkGreen.withAlpha(51),
                blurRadius: 15,
                offset: const Offset(0, 8),
                spreadRadius: canUseWidget ? 2 : 0,
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
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            gradient: canUseWidget 
                                ? const RadialGradient(
                                    colors: [goldColor, lightGold],
                                  )
                                : RadialGradient(
                                    colors: [lightGold, goldColor],
                                  ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: canUseWidget ? [
                              BoxShadow(
                                color: goldColor.withAlpha(102),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ] : null,
                          ),
                          child: const Icon(
                            Icons.widgets,
                            color: emeraldGreen,
                            size: 20,
                          ),
                        ),
                        if (!canUseWidget)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [goldColor, lightGold],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.diamond,
                                color: emeraldGreen,
                                size: 8,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        canUseWidget
                            ? (AppLocalizations.of(context)?.widgetInfoTitlePremium ?? 'Tasbee Widget Hakkında 📱')
                            : (AppLocalizations.of(context)?.widgetInfoTitleFree ?? 'Tasbee Widget Hakkında 🔒'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: emeraldGreen,
                          shadows: canUseWidget ? [
                            Shadow(
                              color: goldColor.withAlpha(77),
                              blurRadius: 2,
                              offset: const Offset(1, 1),
                            ),
                          ] : null,
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
                    GetX<SubscriptionService>(
                      builder: (subscriptionService) {
                        final isPremium = subscriptionService.isPremium.value;
                        final isDhikrWidgetEnabled = subscriptionService.isDhikrWidgetEnabled;
                        final canUseWidget = isPremium || isDhikrWidgetEnabled;
                        
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: canUseWidget 
                                ? () {
                                    Navigator.of(context).pop();
                                    _addWidgetToHomeScreen();
                                  }
                                : () {
                                    HapticFeedback.lightImpact();
                                    Get.defaultDialog(
                                      title: AppLocalizations.of(context)?.widgetPremiumDialogTitle ?? 'Premium Özellik 💎',
                                      titleStyle: const TextStyle(
                                        color: emeraldGreen,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      middleText: AppLocalizations.of(context)?.widgetPremiumDialogMessage ?? 'Ana ekran widget\'ı premium bir özelliktir.\nWidget\'ı kullanmak için premium\'a geçin veya reklam izleyerek açabilirsiniz.',
                                      middleTextStyle: TextStyle(
                                        color: emeraldGreen.withAlpha(204),
                                        fontSize: 14,
                                      ),
                                      backgroundColor: const Color(0xFFFFF9E6),
                                      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                                      contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                                      confirm: Container(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [goldColor, lightGold],
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Get.back();
                                            Get.back(); // Close widget info dialog too
                                            Get.to(() => const PremiumScreen(), transition: Transition.rightToLeft);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            foregroundColor: emeraldGreen,
                                          ),
                                          child: Text(
                                            AppLocalizations.of(context)?.upgradeConfirm ?? 'Premium\'a Geç',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      cancel: TextButton(
                                        onPressed: () => Get.back(),
                                        child: Text(
                                          AppLocalizations.of(context)?.cancel ?? 'İptal',
                                          style: TextStyle(color: emeraldGreen.withAlpha(179)),
                                        ),
                                      ),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: canUseWidget ? goldColor : Colors.grey.shade400,
                              foregroundColor: canUseWidget ? emeraldGreen : Colors.grey.shade600,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: canUseWidget ? 4 : 1,
                            ),
                            icon: Icon(
                              canUseWidget ? Icons.add_to_home_screen : Icons.lock,
                              size: 20,
                            ),
                            label: Text(
                              canUseWidget 
                                  ? (AppLocalizations.of(context)?.widgetAddTitle ?? 'Widget Ekle')
                                  : (AppLocalizations.of(context)?.widgetPremiumRequired ?? 'Premium Gerekli'),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      },
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
      debugPrint("DEBUG: Tasbih widget ekleme başladı");

      // Eski çalışan yaklaşım - parametre yok
      const platform = MethodChannel('com.skyforgestudios.tasbeepro/widget');
      debugPrint("DEBUG: Platform channel oluşturuldu");
      
      final result = await platform.invokeMethod('openWidgetPicker');
      debugPrint("DEBUG: Platform channel sonucu: $result");
      
     
    } catch (e) {
      debugPrint("DEBUG: Platform channel hatası: $e");
      
      // Platform channel başarısız olursa manual talimatlar göster
      HapticFeedback.lightImpact();
      if (!mounted) return;
      IslamicSnackbar.showSuccess(
        AppLocalizations.of(context)?.widgetAddSuccess ?? 'Widget Ekleme',
        AppLocalizations.of(context)?.widgetAddSuccessMessage ??
            'Ana ekranınızda boş bir alana uzun basın ve "Widget\'lar" seçeneğini seçin. Ardından "Tasbee Pro" widget\'ını bulup ekleyin.',
        duration: const Duration(seconds: 5),
      );
    }
  }

  void _addQuranWidgetToHomeScreen() async {
    try {
      HapticFeedback.lightImpact();
      debugPrint("DEBUG: Kur'an widget ekleme başladı");

      // Kur'an widget için ayrı method
      const platform = MethodChannel('com.skyforgestudios.tasbeepro/widget');
      debugPrint("DEBUG: Platform channel oluşturuldu");
      
      final result = await platform.invokeMethod('openQuranWidgetPicker');
      debugPrint("DEBUG: Platform channel sonucu: $result");
      
     
    } catch (e) {
      debugPrint("DEBUG: Platform channel hatası: $e");
      
      // Platform channel başarısız olursa manual talimatlar göster
      HapticFeedback.lightImpact();
      if (!mounted) return;
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

  // Premium section builder
  Widget _buildPremiumSection(BuildContext context) {
    return GetX<SubscriptionService>(
      builder: (subscriptionService) {
        final isPremium = subscriptionService.isPremium.value;
        
        return Column(
          children: [
            _buildSectionHeader(
              context,
              isPremium ? (AppLocalizations.of(context)?.premiumActiveTitle ?? '✨ Premium Aktif ✨') : (AppLocalizations.of(context)?.premiumTitle ?? '💎 Premium'),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: isPremium 
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFFF9E6), // Light gold
                          Color(0xFFF5E6A8), // Lighter gold
                          Color(0xFFD4AF37), // Gold
                          Color(0xFFF5E6A8), // Lighter gold
                        ],
                        stops: [0.0, 0.3, 0.7, 1.0],
                      )
                    : const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFFFDF7), Color(0xFFF5F3E8)],
                      ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isPremium ? goldColor : goldColor.withAlpha(77), 
                  width: isPremium ? 2 : 1.5
                ),
                boxShadow: [
                  BoxShadow(
                    color: isPremium 
                        ? goldColor.withAlpha(102)
                        : darkGreen.withAlpha(25),
                    blurRadius: isPremium ? 20 : 12,
                    offset: const Offset(0, 4),
                    spreadRadius: isPremium ? 5 : 0,
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    // Premium crown icon and title
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: isPremium 
                                ? const RadialGradient(
                                    colors: [emeraldGreen, darkGreen],
                                    center: Alignment.topLeft,
                                  )
                                : RadialGradient(
                                    colors: [lightGold, goldColor],
                                    center: Alignment.topLeft,
                                  ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: isPremium 
                                    ? emeraldGreen.withAlpha(102)
                                    : goldColor.withAlpha(102),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            isPremium ? Icons.diamond : Icons.diamond_outlined,
                            color: isPremium ? goldColor : emeraldGreen,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isPremium ? (AppLocalizations.of(context)?.premiumActiveStatus ?? '🌟 Premium Üye 🌟') : (AppLocalizations.of(context)?.premiumUpgradeTitle ?? '💎 Premium\'a Geçin'),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isPremium ? emeraldGreen : emeraldGreen,
                                  shadows: isPremium ? [
                                    Shadow(
                                      color: goldColor.withAlpha(77),
                                      blurRadius: 2,
                                      offset: const Offset(1, 1),
                                    ),
                                  ] : null,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isPremium 
                                    ? (AppLocalizations.of(context)?.premiumActiveDescription ?? 'Tam dijital tesbih deneyimi')
                                    : (AppLocalizations.of(context)?.premiumUpgradeDescription ?? 'Reklamsız ve özel özellikler'),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isPremium 
                                      ? emeraldGreen.withAlpha(204)
                                      : emeraldGreen.withAlpha(179),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2, 
                                  vertical: 6
                                ),
                                decoration: BoxDecoration(
                                  gradient: isPremium
                                      ? LinearGradient(
                                          colors: [
                                            emeraldGreen.withAlpha(51),
                                            emeraldGreen.withAlpha(26),
                                          ],
                                        )
                                      : LinearGradient(
                                          colors: [
                                            goldColor.withAlpha(77),
                                            lightGold.withAlpha(102),
                                          ],
                                        ),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isPremium 
                                        ? emeraldGreen.withAlpha(102)
                                        : goldColor.withAlpha(153),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isPremium 
                                          ? emeraldGreen.withAlpha(51)
                                          : goldColor.withAlpha(77),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isPremium ? Icons.verified : Icons.diamond,
                                      color: isPremium ? emeraldGreen : goldColor,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        isPremium 
                                            ? (AppLocalizations.of(context)?.premiumMembershipActive ?? 'Premium Üyelik Aktif')
                                            : (AppLocalizations.of(context)?.premiumUpgradeDiscountText ?? 'Premium\'a Geçin - %60 Tasarruf'),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isPremium ? emeraldGreen : emeraldGreen,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 10),
                    
                    // Premium features
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isPremium 
                            ? emeraldGreen.withAlpha(26)
                            : lightGold.withAlpha(77),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isPremium 
                              ? emeraldGreen.withAlpha(77)
                              : goldColor.withAlpha(128),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildPremiumFeature(
                            isPremium,
                            Icons.block,
                            AppLocalizations.of(context)?.premiumFeatureAdFreeTitle ?? 'Reklamsız Deneyim',
                            AppLocalizations.of(context)?.premiumFeatureAdFreeDesc ?? 'Kesintisiz zikir ve dua',
                          ),
                          _buildPremiumFeature(
                            isPremium,
                            Icons.notifications_active,
                            AppLocalizations.of(context)?.premiumFeatureRemindersTitle ?? 'Akıllı Hatırlatıcılar',
                            AppLocalizations.of(context)?.premiumFeatureRemindersDesc ?? 'Özelleştirilebilir bildirimler',
                          ),
                          _buildPremiumFeature(
                            isPremium,
                            Icons.widgets,
                            AppLocalizations.of(context)?.premiumFeatureWidgetTitle ?? 'Ana Ekran Widget\'ı',
                            AppLocalizations.of(context)?.premiumFeatureWidgetDesc ?? 'Hızlı erişim ve sayaç',
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                    
                    if (!isPremium) ...[
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [goldColor, lightGold, goldColor],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: goldColor.withAlpha(102),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => Get.to(
                            () => const PremiumScreen(), 
                            transition: Transition.rightToLeft
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.diamond,
                                color: emeraldGreen,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context)?.premiumUpgradeButton ?? 'Premium\'a Geçin',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: emeraldGreen,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: emeraldGreen,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [emeraldGreen, darkGreen],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: emeraldGreen.withAlpha(77),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle, color: goldColor, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)?.premiumMembershipActiveStatus ?? 'Premium Üyeliğiniz Aktif',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: goldColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPremiumFeature(bool isPremium, IconData icon, String title, String description, {bool isLast = false}) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: isPremium 
                    ? const RadialGradient(
                        colors: [goldColor, lightGold],
                        center: Alignment.topLeft,
                      )
                    : RadialGradient(
                        colors: [emeraldGreen.withAlpha(179), emeraldGreen],
                        center: Alignment.topLeft,
                      ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isPremium ? emeraldGreen : Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isPremium ? emeraldGreen : emeraldGreen.withAlpha(204),
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isPremium 
                          ? emeraldGreen.withAlpha(179)
                          : emeraldGreen.withAlpha(153),
                    ),
                  ),
                ],
              ),
            ),
            if (isPremium)
              const Icon(
                Icons.check_circle,
                color: emeraldGreen,
                size: 16,
              ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 12),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  isPremium 
                      ? emeraldGreen.withAlpha(77)
                      : goldColor.withAlpha(77),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  // Reward system card builder
  Widget _buildRewardSystemCard() {
    try {
      return _buildIslamicCard([
        // Zikir Widget'ı
        _buildRewardFeatureTile(
          icon: Icons.auto_awesome,
          title: AppLocalizations.of(context)?.rewardDhikrWidget ?? 'Zikir Widget\'ı',
          featureType: RewardFeatureType.dhikrWidget,
          onWatchAd: () => _watchAdForFeature(RewardFeatureType.dhikrWidget),
        ),
        
        _buildDivider(),
        
        // Kuran Widget'ı
        _buildRewardFeatureTile(
          icon: Icons.menu_book,
          title: AppLocalizations.of(context)?.rewardQuranWidget ?? 'Kuran Widget\'ı',
          featureType: RewardFeatureType.quranWidget,
          onWatchAd: () => _watchAdForFeature(RewardFeatureType.quranWidget),
        ),
        
        _buildDivider(),
        
        // Hatırlatıcılar
        _buildRewardFeatureTile(
          icon: Icons.notifications_active,
          title: AppLocalizations.of(context)?.rewardReminders ?? 'Hatırlatıcılar',
          featureType: RewardFeatureType.reminders,
          onWatchAd: () => _watchAdForFeature(RewardFeatureType.reminders),
        ),
        
        _buildDivider(),
        
        // Hatırlatma Saatleri
        _buildRewardFeatureTile(
          icon: Icons.schedule,
          title: AppLocalizations.of(context)?.rewardReminderTimes ?? 'Hatırlatma Saatleri',
          featureType: RewardFeatureType.reminderTimes,
          onWatchAd: () => _watchAdForFeature(RewardFeatureType.reminderTimes),
        ),
        
        // Bilgilendirme
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withAlpha(26),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withAlpha(77)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)?.rewardSystemInfo ?? 'Her özellik için 3 reklam izleyerek 24 saat süreyle o özelliği kullanabilirsiniz.',
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ]);
    } catch (e) {
      return _buildIslamicCard([
        Container(
          padding: const EdgeInsets.all(16),
          child: Text(
            AppLocalizations.of(context)?.rewardSystemLoading ?? 'Reward sistemi yükleniyor...',
            style: TextStyle(color: emeraldGreen.withAlpha(179)),
            textAlign: TextAlign.center,
          ),
        ),
      ]);
    }
  }
  
  Widget _buildRewardFeatureTile({
    required IconData icon,
    required String title,
    required RewardFeatureType featureType,
    required VoidCallback onWatchAd,
  }) {
    // RewardService'ten dinamik olarak status alınacak
    bool isUnlocked = false;
    int adsWatched = 0;
    String progressText = AppLocalizations.of(context)?.loading ?? 'Yükleniyor...';
    double progress = 0.0;
    
    try {
      // RewardService'i güvenli şekilde bul
      if (Get.isRegistered<RewardService>()) {
        final rewardService = Get.find<RewardService>();
        
        // Feature type'a göre status'u belirle
        RewardFeatureStatus status;
        switch (featureType) {
          case RewardFeatureType.dhikrWidget:
            status = rewardService.dhikrWidgetStatus;
            break;
          case RewardFeatureType.quranWidget:
            status = rewardService.quranWidgetStatus;
            break;
          case RewardFeatureType.reminders:
            status = rewardService.remindersStatus;
            break;
          case RewardFeatureType.reminderTimes:
            status = rewardService.reminderTimesStatus;
            break;
        }
        
        isUnlocked = status.isUnlocked;
        adsWatched = status.adsWatched;
        progress = adsWatched / 3.0;
        progressText = isUnlocked 
          ? status.getProgressText()
          : (AppLocalizations.of(context)?.rewardAdsProgress(adsWatched) ?? '$adsWatched/3 reklam');
      }
    } catch (e) {
      // Service henüz hazır değil, default değerleri kullan
      if (kDebugMode) {
        debugPrint('RewardService not ready yet: $e');
      }
    }
    
    final int remainingAds = 3 - adsWatched;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Özellik ikonu
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: isUnlocked 
                  ? const LinearGradient(colors: [Colors.green, Colors.lightGreen])
                  : const RadialGradient(colors: [lightGold, goldColor], center: Alignment(-0.2, -0.2)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isUnlocked ? Icons.check_circle : icon,
              color: isUnlocked ? Colors.white : emeraldGreen,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Özellik bilgisi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: emeraldGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  progressText,
                  style: TextStyle(
                    color: emeraldGreen.withAlpha(179),
                    fontSize: 11,
                  ),
                ),
                // Progress bar
                if (!isUnlocked)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      widthFactor: progress,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          color: goldColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Reklam izle butonu
          if (!isUnlocked)
            ElevatedButton.icon(
              onPressed: onWatchAd,
              icon: const Icon(Icons.play_circle_filled, size: 16),
              label: Text(
                AppLocalizations.of(context)?.rewardWatchAdButton(remainingAds) ?? '$remainingAds Reklam',
                style: const TextStyle(fontSize: 11),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: const Size(0, 28),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(51),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check, color: Colors.green, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    AppLocalizations.of(context)?.rewardFeatureActive ?? 'Aktif',
                    style: TextStyle(
                      color: Colors.green[800],
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  Future<void> _watchAdForFeature(RewardFeatureType featureType) async {
    try {
      // RewardService'i doğru tip ile bul
      if (!Get.isRegistered<RewardService>()) {
        IslamicSnackbar.showError(
          AppLocalizations.of(context)?.rewardServiceError ?? 'Servis Hatası',
          AppLocalizations.of(context)?.rewardServiceNotReady ?? 'Reward servisi henüz hazır değil. Lütfen uygulamayı yeniden başlatın.',
        );
        return;
      }
      
      final rewardService = Get.find<RewardService>();
      final success = await rewardService.showRewardedAd(featureType);
      
      if (!success) {
        IslamicSnackbar.showError(
          AppLocalizations.of(context.mounted ? context : Get.context!)?.rewardAdError ?? 'Reklam Hatası',
          AppLocalizations.of(context.mounted ? context : Get.context!)?.rewardAdNotReady ?? 'Reklam şu anda hazırlanmıyor. Lütfen birkaç saniye sonra tekrar deneyin.',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error watching ad for feature: $e');
      }
      IslamicSnackbar.showError(
        AppLocalizations.of(context.mounted ? context : Get.context!)?.rewardError ?? 'Hata',
        AppLocalizations.of(context.mounted ? context : Get.context!)?.rewardAdWatchError ?? 'Reklam izlenirken bir hata oluştu. Lütfen tekrar deneyin.',
      );
    }
  }
}


