import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../l10n/app_localizations.dart';
import '../widgets/islamic_snackbar.dart';
import '../services/permission_service.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  // İslami renk paleti
  static const emeraldGreen = Color(0xFF2D5016);
  static const goldColor = Color(0xFFD4AF37);
  static const lightGold = Color(0xFFF5E6A8);
  static const darkGreen = Color(0xFF1A3409);

  final PermissionService _permissionService = Get.find<PermissionService>();

  @override
  void initState() {
    super.initState();
    _checkAllPermissions();
  }

  Future<void> _checkAllPermissions() async {
    await _permissionService.checkAllPermissions();
  }

  @override
  Widget build(BuildContext context) {
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
                  AppLocalizations.of(context)?.permissionsTitle ?? 'İzinler',
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
            child: RefreshIndicator(
              onRefresh: _checkAllPermissions,
              color: goldColor,
              backgroundColor: Colors.white,
              child: ListView(
                padding: const EdgeInsets.all(8),
                children: [
                  // Açıklama metni
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFFFDF7), Color(0xFFF5F3E8)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: goldColor.withAlpha(77), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: darkGreen.withAlpha(25),
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
                                gradient: const RadialGradient(
                                  colors: [lightGold, goldColor],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.info_outline,
                                color: emeraldGreen,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)?.permissionsInfoTitle ?? 'İzin Bilgileri',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: emeraldGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppLocalizations.of(context)?.permissionsInfoDescription ?? 
                          'Bu sayfada uygulamanın düzgün çalışması için gerekli izinleri görüntüleyebilir ve yönetebilirsiniz. İzinleri vermek için ilgili izin kartına dokunun.',
                          style: TextStyle(
                            fontSize: 14,
                            color: emeraldGreen.withAlpha(204),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // İzinler bölümü başlığı
                  _buildSectionHeader(
                    context,
                    AppLocalizations.of(context)?.permissionsRequired ?? 'Gerekli İzinler',
                  ),

                  // İzin kartları
                  Obx(() => Column(
                    children: _permissionService.requiredPermissions.map((permission) => 
                      _buildPermissionCard(permission)).toList(),
                  )),

                  const SizedBox(height: 24),

                  // Tüm izinleri kontrol et butonu
                  _buildCheckAllPermissionsButton(),

                  const SizedBox(height: 16),

                  // Ayarları aç butonu
                  _buildOpenSettingsButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Container(
      margin: const EdgeInsets.only(left: 0, bottom: 12),
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

  Widget _buildPermissionCard(Permission permission) {
    final status = _permissionService.permissionStatuses[permission] ?? PermissionStatus.denied;
    final isGranted = status == PermissionStatus.granted;
    final isPermanentlyDenied = status == PermissionStatus.permanentlyDenied;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isGranted 
              ? [Color(0xFFF0F9F0), Color(0xFFE8F5E8)]
              : [Color(0xFFFFFDF7), Color(0xFFF5F3E8)],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isGranted 
              ? Colors.green.withAlpha(128)
              : goldColor.withAlpha(77), 
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _handlePermissionTap(permission),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: isGranted 
                              ? [Colors.green.shade100, Colors.green.shade200]
                              : [lightGold, goldColor],
                          center: Alignment(-0.2, -0.2),
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: darkGreen.withAlpha(39),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        _getPermissionIcon(permission),
                        color: isGranted ? Colors.green.shade700 : emeraldGreen,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Text(
                          _permissionService.getPermissionName(permission),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: emeraldGreen,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _permissionService.getPermissionDescription(permission),
                          style: TextStyle(
                            fontSize: 12,
                            color: emeraldGreen.withAlpha(179),
                            height: 1.3,
                          ),
                        ),
                        ],
                      ),
                    ),
                    _buildPermissionStatusChip(status),
                  ],
                ),
                
                if (isPermanentlyDenied) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber, color: Colors.orange.shade600, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)?.permissionPermanentlyDenied ?? 
                            'İzin kalıcı olarak reddedildi. Ayarlardan manuel olarak açmanız gerekiyor.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.orange.shade800,
                            ),
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
      ),
    );
  }

  Widget _buildPermissionStatusChip(PermissionStatus status) {
    Color backgroundColor;
    Color textColor;
    String text;
    IconData icon;

    switch (status) {
      case PermissionStatus.granted:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade700;
        text = _permissionService.getPermissionStatusText(status);
        icon = Icons.check_circle;
        break;
      case PermissionStatus.denied:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade700;
        text = _permissionService.getPermissionStatusText(status);
        icon = Icons.cancel;
        break;
      case PermissionStatus.permanentlyDenied:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade700;
        text = _permissionService.getPermissionStatusText(status);
        icon = Icons.block;
        break;
      case PermissionStatus.restricted:
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
        text = _permissionService.getPermissionStatusText(status);
        icon = Icons.remove_circle;
        break;
      default:
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
        text = _permissionService.getPermissionStatusText(status);
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckAllPermissionsButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _requestAllPermissions,
        style: ElevatedButton.styleFrom(
          backgroundColor: emeraldGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: darkGreen.withAlpha(77),
        ),
        icon: const Icon(Icons.security, size: 20),
        label: Text(
          AppLocalizations.of(context)?.permissionsRequestAll ?? 'Tüm İzinleri İste',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildOpenSettingsButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _permissionService.openSettings(),
        style: OutlinedButton.styleFrom(
          foregroundColor: emeraldGreen,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: goldColor, width: 1.5),
        ),
        icon: const Icon(Icons.settings, size: 20),
        label: Text(
          AppLocalizations.of(context)?.permissionsOpenSettings ?? 'Uygulama Ayarlarını Aç',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  IconData _getPermissionIcon(Permission permission) {
    switch (permission) {
      case Permission.notification:
        return Icons.notifications;
      case Permission.scheduleExactAlarm:
        return Icons.schedule;
      case Permission.ignoreBatteryOptimizations:
        return Icons.battery_saver;
      default:
        return Icons.security;
    }
  }



  Future<void> _handlePermissionTap(Permission permission) async {
    HapticFeedback.lightImpact();
    
    final currentStatus = _permissionService.permissionStatuses[permission] ?? PermissionStatus.denied;
    
    if (currentStatus == PermissionStatus.permanentlyDenied) {
      _showPermanentlyDeniedDialog(permission);
      return;
    }

    if (currentStatus == PermissionStatus.granted) {
      IslamicSnackbar.showInfo(
        AppLocalizations.of(context)?.permissionAlreadyGranted ?? 'İzin Zaten Verildi',
        _permissionService.getPermissionAlreadyGrantedMessage(),
        duration: const Duration(seconds: 2),
      );
      return;
    }

    await _permissionService.requestPermission(permission);
  }

  Future<void> _requestAllPermissions() async {
    HapticFeedback.lightImpact();
    await _permissionService.requestAllPermissions();
  }

  void _showPermanentlyDeniedDialog(Permission permission) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320),
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
                        Icons.settings,
                        color: emeraldGreen,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)?.permissionManualTitle ?? 'Manuel İzin Gerekli',
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
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)?.permissionManualMessage ?? 
                      'Bu izin kalıcı olarak reddedildi. Ayarlar sayfasından manuel olarak açmanız gerekiyor.',
                      style: TextStyle(
                        color: emeraldGreen.withAlpha(204),
                        fontSize: 14,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              fixedSize: const Size.fromHeight(44),
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
                              AppLocalizations.of(context)?.cancel ?? 'İptal',
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
                            onPressed: () {
                              Navigator.pop(context);
                              _permissionService.openSettings();
                            },
                            style: ElevatedButton.styleFrom(
                              
                              fixedSize: const Size.fromHeight(44),
                              backgroundColor: emeraldGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 2,
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                AppLocalizations.of(context)?.permissionsOpenSettings ?? 'Ayarlara Git',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
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
  }
}