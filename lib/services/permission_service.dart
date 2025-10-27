import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/islamic_snackbar.dart';
import '../l10n/app_localizations.dart';

class PermissionService extends GetxService {
  // İzin durumlarını takip etmek için reactive map
  final RxMap<Permission, PermissionStatus> _permissionStatuses = 
      <Permission, PermissionStatus>{}.obs;

  // Uygulama için gerekli izinler
  final List<Permission> _requiredPermissions = [
    Permission.notification,
    Permission.scheduleExactAlarm,
    Permission.ignoreBatteryOptimizations,
  ];

  // Getter'lar
  Map<Permission, PermissionStatus> get permissionStatuses => _permissionStatuses;
  List<Permission> get requiredPermissions => _requiredPermissions;

  @override
  Future<void> onInit() async {
    super.onInit();
    await checkAllPermissions();
  }

  /// Tüm izinlerin durumunu kontrol et
  Future<void> checkAllPermissions() async {
    for (Permission permission in _requiredPermissions) {
      final status = await permission.status;
      _permissionStatuses[permission] = status;
    }
  }

  /// Belirli bir izin durumunu kontrol et
  Future<PermissionStatus> checkPermission(Permission permission) async {
    final status = await permission.status;
    _permissionStatuses[permission] = status;
    return status;
  }

  /// Tek bir izin iste
  Future<PermissionStatus> requestPermission(Permission permission) async {
    try {
      final status = await permission.request();
      _permissionStatuses[permission] = status;
      
      _showPermissionResult(permission, status);
      return status;
    } catch (e) {
      _showPermissionError();
      return PermissionStatus.denied;
    }
  }

  /// Tüm izinleri iste
  Future<Map<Permission, PermissionStatus>> requestAllPermissions() async {
    try {
      final Map<Permission, PermissionStatus> statuses = 
          await _requiredPermissions.request();
      
      // Sonuçları güncelle
      for (final entry in statuses.entries) {
        _permissionStatuses[entry.key] = entry.value;
      }

      _showAllPermissionsResult(statuses);
      return statuses;
    } catch (e) {
      _showPermissionError();
      return {};
    }
  }

  /// Belirli bir iznin verilip verilmediğini kontrol et
  Future<bool> isPermissionGranted(Permission permission) async {
    final status = await checkPermission(permission);
    return status == PermissionStatus.granted;
  }

  /// Tüm gerekli izinlerin verilip verilmediğini kontrol et
  Future<bool> areAllPermissionsGranted() async {
    await checkAllPermissions();
    return _permissionStatuses.values.every(
      (status) => status == PermissionStatus.granted,
    );
  }

  /// Bildirim izni kontrol et (backward compatibility için)
  Future<bool> checkNotificationPermission() async {
    return await isPermissionGranted(Permission.notification);
  }

  /// Uygulama ayarlarını aç
  Future<void> openSettings() async {
    await openAppSettings();
  }

  /// İzin sonucunu göster
  void _showPermissionResult(Permission permission, PermissionStatus status) {
    final context = Get.context;
    if (context == null) return;

    String title;
    String message;

    switch (status) {
      case PermissionStatus.granted:
        title = AppLocalizations.of(context)?.permissionGranted ?? 'İzin Verildi';
        message = AppLocalizations.of(context)?.permissionGrantedMessage ?? 
                 'İzin başarıyla verildi!';
        IslamicSnackbar.showSuccess(title, message, duration: const Duration(seconds: 2));
        break;
        
      case PermissionStatus.permanentlyDenied:
        title = AppLocalizations.of(context)?.permissionDenied ?? 'İzin Reddedildi';
        message = AppLocalizations.of(context)?.permissionPermanentlyDeniedMessage ?? 
                 'İzin kalıcı olarak reddedildi. Ayarlardan manuel olarak açabilirsiniz.';
        IslamicSnackbar.showWarning(title, message, duration: const Duration(seconds: 3));
        break;
        
      default:
        title = AppLocalizations.of(context)?.permissionDenied ?? 'İzin Reddedildi';
        message = AppLocalizations.of(context)?.permissionDeniedMessage ?? 
                 'İzin reddedildi. Tekrar deneyebilirsiniz.';
        IslamicSnackbar.showError(title, message, duration: const Duration(seconds: 2));
    }
  }

  /// Tüm izinler sonucunu göster
  void _showAllPermissionsResult(Map<Permission, PermissionStatus> statuses) {
    final context = Get.context;
    if (context == null) return;

    final grantedCount = statuses.values.where(
      (status) => status == PermissionStatus.granted,
    ).length;
    final totalCount = statuses.length;

    if (grantedCount == totalCount) {
      IslamicSnackbar.showSuccess(
        AppLocalizations.of(context)?.permissionsAllGranted ?? 'Tüm İzinler Verildi',
        AppLocalizations.of(context)?.permissionsAllGrantedMessage ?? 
        'Tüm gerekli izinler başarıyla verildi!',
        duration: const Duration(seconds: 3),
      );
    } else {
      IslamicSnackbar.showWarning(
        AppLocalizations.of(context)?.permissionsSomeGranted ?? 'Bazı İzinler Verildi',
        AppLocalizations.of(context)?.permissionsSomeGrantedMessage ?? 
        'Bazı izinler verildi. Eksik izinleri manuel olarak verebilirsiniz.',
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// İzin hatası göster
  void _showPermissionError() {
    final context = Get.context;
    if (context == null) return;

    IslamicSnackbar.showError(
      AppLocalizations.of(context)?.error ?? 'Hata',
      AppLocalizations.of(context)?.permissionRequestError ?? 
      'İzin istenirken bir hata oluştu.',
      duration: const Duration(seconds: 2),
    );
  }

  /// İzin adını al
  String getPermissionName(Permission permission) {
    final context = Get.context;
    if (context == null) return 'Unknown Permission';

    switch (permission) {
      case Permission.notification:
        return AppLocalizations.of(context)?.permissionNotificationTitle ?? 'Bildirim İzni';
      case Permission.scheduleExactAlarm:
        return AppLocalizations.of(context)?.permissionAlarmTitle ?? 'Alarm İzni';
      case Permission.ignoreBatteryOptimizations:
        return AppLocalizations.of(context)?.permissionBatteryTitle ?? 'Batarya Optimizasyonu';
      default:
        return AppLocalizations.of(context)?.permissionUnknownTitle ?? 'Bilinmeyen İzin';
    }
  }

  /// İzin açıklamasını al
  String getPermissionDescription(Permission permission) {
    final context = Get.context;
    if (context == null) return 'No information available';

    switch (permission) {
      case Permission.notification:
        return AppLocalizations.of(context)?.permissionNotificationDescription ?? 
               'Zikir hatırlatıcıları ve bildirimler için gerekli';
      case Permission.scheduleExactAlarm:
        return AppLocalizations.of(context)?.permissionAlarmDescription ?? 
               'Zamanında hatırlatıcılar için gerekli (Android 12+)';
      case Permission.ignoreBatteryOptimizations:
        return AppLocalizations.of(context)?.permissionBatteryDescription ?? 
               'Arka planda güvenilir bildirimler için gerekli';
      default:
        return AppLocalizations.of(context)?.permissionUnknownDescription ?? 
               'Bu izin hakkında bilgi mevcut değil';
    }
  }

  /// İzin durumu tekstini al
  String getPermissionStatusText(PermissionStatus status) {
    final context = Get.context;
    if (context == null) return 'Unknown';

    switch (status) {
      case PermissionStatus.granted:
        return AppLocalizations.of(context)?.permissionGranted ?? 'Verildi';
      case PermissionStatus.denied:
        return AppLocalizations.of(context)?.permissionDenied ?? 'Reddedildi';
      case PermissionStatus.permanentlyDenied:
        return AppLocalizations.of(context)?.permissionPermanentlyDeniedShort ?? 'Kalıcı Red';
      case PermissionStatus.restricted:
        return AppLocalizations.of(context)?.permissionRestricted ?? 'Kısıtlı';
      default:
        return AppLocalizations.of(context)?.permissionUnknown ?? 'Bilinmiyor';
    }
  }

  /// İzin durumuna göre uygun mesajı al
  String getPermissionAlreadyGrantedMessage() {
    final context = Get.context;
    if (context == null) return 'Bu izin zaten verilmiş durumda.';
    
    return AppLocalizations.of(context)?.permissionAlreadyGrantedMessage ?? 
           'Bu izin zaten verilmiş durumda.';
  }
}