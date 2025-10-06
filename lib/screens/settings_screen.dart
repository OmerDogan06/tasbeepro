import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../services/sound_service.dart';
import '../services/vibration_service.dart';
import '../services/notification_service.dart';
import '../widgets/islamic_snackbar.dart';
import 'reminder_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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

  @override
  Widget build(BuildContext context) {
    final soundService = Get.find<SoundService>();
    final vibrationService = Get.find<VibrationService>();
    final notificationService = Get.find<NotificationService>();

    return PopScope(
      canPop: true,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
             statusBarColor: Color(0xFF2D5016),
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF2D5016),
      systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F6F0),
        appBar: AppBar(
          leading:  Container(
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
            'Ayarlar',
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
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(10),
            children: [
              // Ses ve Titreşim Ayarları
              _buildSectionHeader(context, 'Ses ve Titreşim'),
              _buildIslamicCard([
                Obx(() => _buildIslamicSwitchTile(
                  icon: Icons.volume_up,
                  title: 'Ses Efekti',
                  subtitle: 'Dokunma sesini aç/kapat',
                  value: soundService.isSoundEnabled,
                  onChanged: (value) => soundService.toggleSound(),
                )),
                _buildDivider(),
                Obx(() => _buildIslamicListTile(
                  icon: Icons.vibration,
                  title: 'Titreşim',
                  subtitle: vibrationService.vibrationLevelText,
                  onTap: () => _showVibrationDialog(context, vibrationService),
                )),
              ]),
              
              const SizedBox(height: 24),
              
              // Hatırlatıcılar (Pro Özelliği)
              _buildSectionHeader(context, 'Hatırlatıcılar 💎'),
              _buildIslamicCard([
                _buildIslamicListTile(
                  icon: Icons.notifications,
                  title: 'Zikir Hatırlatıcısı',
                  subtitle: 'Günlük zikir hatırlatması ayarla',
                  onTap: () => Get.to(() => const ReminderScreen(),
                    transition: Transition.rightToLeft,
                    duration: const Duration(milliseconds: 300)),
                ),
                _buildDivider(),
                _buildIslamicListTile(
                  icon: Icons.schedule,
                  title: 'Hatırlatma Saatleri',
                  subtitle: 'Özel saatler belirle',
                  onTap: () => _showCustomReminderTimes(context),
                ),
              ]),
              
              const SizedBox(height: 24),
              
              // Hakkında
              _buildSectionHeader(context, 'Hakkında'),
              _buildIslamicCard([
                _buildIslamicListTile(
                  icon: Icons.info,
                  title: 'Uygulama Hakkında',
                  subtitle: 'Tasbee Pro v${appVersion.isNotEmpty ? appVersion : "1.0.0"}',
                  onTap: () => _showAboutDialog(context),
                ),
                _buildDivider(),
                _buildIslamicListTile(
                  icon: Icons.star,
                  title: 'Uygulamayı Değerlendir',
                  subtitle: 'Play Store\'da değerlendir',
                  onTap: () {
                    IslamicSnackbar.showInfo(
                      'Teşekkürler',
                      'Değerlendirmeniz bizim için çok önemli!',
                      duration: const Duration(seconds: 2),
                    );
                  },
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
  
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Container(
      margin: const EdgeInsets.only(left: 0, bottom: 6),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [goldColor, lightGold],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              color: emeraldGreen,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
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
          colors: [
            Color(0xFFFFFDF7),
            Color(0xFFF5F3E8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: goldColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.1),
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
              color: darkGreen.withOpacity(0.15),
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
        style: TextStyle(
          color: emeraldGreen.withOpacity(0.7),
          fontSize: 12,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: goldColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.keyboard_arrow_right,
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
              color: darkGreen.withOpacity(0.15),
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
        style: TextStyle(
          color: emeraldGreen.withOpacity(0.7),
          fontSize: 12,
        ),
      ),
      value: value,
      onChanged: onChanged,
      thumbColor: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return goldColor;
          }
          return emeraldGreen;
        },
      ),
      tileColor: Colors.transparent,
      overlayColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.pressed)) {
            return goldColor.withOpacity(0.1);
          }
          return null;
        },
      ),
      trackOutlineColor: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return  goldColor;
          }
          return goldColor;
        },
      ),
      
      trackColor: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.transparent;
          }
          return Colors.transparent;
        },
      
    ));
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            goldColor.withOpacity(0.3),
            Colors.transparent,
          ],
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
            border: Border.all(
              color: goldColor.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: darkGreen.withOpacity(0.2),
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
                    const Text(
                      'Titreşim',
                      style: TextStyle(
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
                      goldColor.withOpacity(0.3),
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
                    _buildVibrationOption(service, 0, 'Kapalı'),
                    _buildVibrationOption(service, 1, 'Hafif'),
                    _buildVibrationOption(service, 2, 'Orta'),
                    
                    const SizedBox(height: 8),
                    
                    // Mini close button
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          backgroundColor: lightGold.withOpacity(0.3),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          overlayColor: Color(0xFFD4AF37).withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: goldColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Tamam',
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
  
  Widget _buildVibrationOption(VibrationService service, int level, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: service.vibrationLevel == level 
            ? goldColor.withOpacity(0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: service.vibrationLevel == level 
              ? goldColor.withOpacity(0.5)
              : goldColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          overlayColor: WidgetStateProperty.all(Color(0xFFD4AF37).withOpacity(0.1)),
          borderRadius: BorderRadius.circular(8),
          onTap: () => service.setVibrationLevel(level).then((_) => Navigator.of(context).pop()),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 6,
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: service.vibrationLevel == level ? goldColor : emeraldGreen.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Obx(() => Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: service.vibrationLevel == level ? FontWeight.bold : FontWeight.w500,
                      color: emeraldGreen,
                    ),
                  )),
                ),
                if (service.vibrationLevel == level)
                 Icon(
                    Icons.check_circle,
                    color: goldColor,
                    size: 12,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
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
            border: Border.all(
              color: goldColor.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: darkGreen.withOpacity(0.2),
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
                      child: const Icon(Icons.info, color: emeraldGreen, size: 14),
                    ),
                    const SizedBox(width: 8),
                    const Text(
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
                      goldColor.withOpacity(0.3),
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
                          colors: [
                            Color(0xFFFFFDF7),
                            Color(0xFFF5F3E8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: goldColor.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Versiyon: ${appVersion.isNotEmpty ? appVersion : "1.0.0"}',
                            style: const TextStyle(
                              color: emeraldGreen,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Offline çalışan dijital tesbih uygulaması.',
                            style: TextStyle(
                              color: emeraldGreen,
                              fontSize: 10,
                            ),
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
                          backgroundColor: lightGold.withOpacity(0.3),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          overlayColor: Color(0xFFD4AF37).withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: goldColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Tamam',
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
  

  void _showCustomReminderTimes(BuildContext context) {
    IslamicSnackbar.showInfo(
      'Özel Hatırlatmalar 🕐',
      'Özel zaman dilimlerinde hatırlatıcı kurabilirsiniz',
    );
  }
}