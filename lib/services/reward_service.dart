import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:tasbeepro/services/subscription_service.dart';
import '../widgets/islamic_snackbar.dart';
import '../l10n/app_localizations.dart';
import 'storage_service.dart';
import 'ad_service.dart';
import 'language_service.dart';
import 'package:http/http.dart' as http;

// Reward feature status model
class RewardFeatureStatus {
  final RewardFeatureType featureType;
  final int adsWatched;
  final DateTime? unlockedAt;
  
  const RewardFeatureStatus({
    required this.featureType,
    required this.adsWatched,
    this.unlockedAt,
  });
  
  bool get isUnlocked {
    if (unlockedAt == null) return false;
    return DateTime.now().difference(unlockedAt!).inHours < 24;
  }
  
  String getProgressText() {
    if (isUnlocked) {
      final hoursLeft = 24 - DateTime.now().difference(unlockedAt!).inHours;
      try {
        final languageService = Get.find<LanguageService>();
        final locale = languageService.currentLocale;
        final localizations = lookupAppLocalizations(locale);
        return localizations.rewardHoursLeft(hoursLeft);
      } catch (e) {
        return '$hoursLeft saat kaldı';
      }
    }
    try {
      final languageService = Get.find<LanguageService>();
      final locale = languageService.currentLocale;
      final localizations = lookupAppLocalizations(locale);
      return localizations.rewardAdsProgress(adsWatched);
    } catch (e) {
      return '$adsWatched/3 reklam';
    }
  }
}

class RewardService extends GetxService {
  // Helper method to get current localized strings dynamically
  AppLocalizations? get _localizations {
    try {
      final languageService = Get.find<LanguageService>();
      final locale = languageService.currentLocale;
      return lookupAppLocalizations(locale);
    } catch (e) {
      return null;
    }
  }

  // Google'dan gerçek zamanı al
  Future<DateTime> _getNetworkTime() async {
    try {
      final response = await http.head(
        Uri.parse('https://www.google.com'),
        headers: {'User-Agent': 'Mozilla/5.0 (compatible; TasbeePro/1.0)'},
      ).timeout(const Duration(seconds: 10));
      
      final dateHeader = response.headers['date'];
      if (dateHeader != null) {
        if (kDebugMode) {
          debugPrint('📅 Date header from Google: $dateHeader');
        }
        
        final networkTimeUtc = HttpDate.parse(dateHeader);
        final networkTimeLocal = networkTimeUtc.toLocal();
        
        if (kDebugMode) {
          debugPrint('🌐 Network time from Google (UTC): $networkTimeUtc');
          debugPrint('🌐 Network time from Google (Local): $networkTimeLocal');
          debugPrint('📱 Local time: ${DateTime.now()}');
          debugPrint('⏰ Time difference: ${DateTime.now().difference(networkTimeLocal).inSeconds} seconds');
        }
        
        return networkTimeLocal;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error fetching network time from Google: $e');
        debugPrint('⚠️ Falling back to system time');
      }
    }
    
    // Hata durumunda sistem saatini kullan
    return DateTime.now();
  }

  // Feature status reactive variables
  final _dhikrWidgetStatus = Rx<RewardFeatureStatus>(
    RewardFeatureStatus(featureType: RewardFeatureType.dhikrWidget, adsWatched: 0)
  );
  final _quranWidgetStatus = Rx<RewardFeatureStatus>(
    RewardFeatureStatus(featureType: RewardFeatureType.quranWidget, adsWatched: 0)
  );
  final _remindersStatus = Rx<RewardFeatureStatus>(
    RewardFeatureStatus(featureType: RewardFeatureType.reminders, adsWatched: 0)
  );
  final _reminderTimesStatus = Rx<RewardFeatureStatus>(
    RewardFeatureStatus(featureType: RewardFeatureType.reminderTimes, adsWatched: 0)
  );
  
  // Getters
  bool get isDhikrWidgetUnlocked => _dhikrWidgetStatus.value.isUnlocked;
  bool get isQuranWidgetUnlocked => _quranWidgetStatus.value.isUnlocked;
  bool get isRemindersUnlocked => _remindersStatus.value.isUnlocked;
  bool get isReminderTimesUnlocked => _reminderTimesStatus.value.isUnlocked;
  
  RewardFeatureStatus get dhikrWidgetStatus => _dhikrWidgetStatus.value;
  RewardFeatureStatus get quranWidgetStatus => _quranWidgetStatus.value;
  RewardFeatureStatus get remindersStatus => _remindersStatus.value;
  RewardFeatureStatus get reminderTimesStatus => _reminderTimesStatus.value;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _loadAllFeatureStatuses();
    _scheduleCleanupExpiredRewards();
    _setupLanguageListener();
  }

  // Dil değişikliklerini dinle
  void _setupLanguageListener() {
    try {
      final languageService = Get.find<LanguageService>();
      // Dil değiştiğinde UI'ı güncelle
      languageService.currentLanguageRx.listen((_) {
        // Observable değerleri refresh et ki UI güncellensin
        _dhikrWidgetStatus.refresh();
        _quranWidgetStatus.refresh();
        _remindersStatus.refresh();
        _reminderTimesStatus.refresh();
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error setting up language listener: $e');
      }
    }
  }

  // Storage'dan tüm feature durumlarını yükle
  Future<void> _loadAllFeatureStatuses() async {
    try {
      final storageService = Get.find<StorageService>();
      
      _dhikrWidgetStatus.value = _loadFeatureStatus(RewardFeatureType.dhikrWidget, storageService);
      _quranWidgetStatus.value = _loadFeatureStatus(RewardFeatureType.quranWidget, storageService);
      _remindersStatus.value = _loadFeatureStatus(RewardFeatureType.reminders, storageService);
      _reminderTimesStatus.value = _loadFeatureStatus(RewardFeatureType.reminderTimes, storageService);
      
      if (kDebugMode) {
        debugPrint('📱 Reward statuses loaded:');
        debugPrint('  DhikrWidget: ${_dhikrWidgetStatus.value.adsWatched}/3, unlocked: $isDhikrWidgetUnlocked');
        debugPrint('  QuranWidget: ${_quranWidgetStatus.value.adsWatched}/3, unlocked: $isQuranWidgetUnlocked');
        debugPrint('  Reminders: ${_remindersStatus.value.adsWatched}/3, unlocked: $isRemindersUnlocked');
        debugPrint('  ReminderTimes: ${_reminderTimesStatus.value.adsWatched}/3, unlocked: $isReminderTimesUnlocked');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error loading reward statuses: $e');
      }
    }
  }

  RewardFeatureStatus _loadFeatureStatus(RewardFeatureType featureType, StorageService storageService) {
    final adsWatched = storageService.getRewardAdsWatched(featureType);
    final unlockedAt = storageService.getRewardUnlockedAt(featureType);
    
    // Süresi dolmuşsa temizle (sistem saati ile kontrol - UI için)
    if (unlockedAt != null && DateTime.now().difference(unlockedAt).inHours >= 24) {
      _clearFeatureStatus(featureType, storageService);
      return RewardFeatureStatus(featureType: featureType, adsWatched: 0);
    }
    
    return RewardFeatureStatus(
      featureType: featureType,
      adsWatched: adsWatched,
      unlockedAt: unlockedAt,
    );
  }

  void _clearFeatureStatus(RewardFeatureType featureType, StorageService storageService) {
    storageService.clearRewardStatus(featureType);
  }

  // Rewarded Ad gösterme - AdService kullanarak
  Future<bool> showRewardedAd(RewardFeatureType featureType) async {
    try {
      final adService = Get.find<AdService>();
      
      if (kDebugMode) {
        debugPrint('🎬 Attempting to show rewarded ad for: $featureType');
        debugPrint('🎬 AdService ready status: ${adService.isRewardedAdReady}');
      }
      
      // AdService'den reklam göster
      final success = await adService.showRewardedAd((amount, type) {
        // Ödül kazanıldığında bu callback çağrılır
        _handleRewardEarned(featureType);
      });
      
      if (kDebugMode) {
        debugPrint('🎬 Rewarded ad show result: $success');
      }
      
      if (!success) {
        if (kDebugMode) {
          debugPrint('❌ Rewarded ad failed to show - showing error message to user');
        }
        
        IslamicSnackbar.showError(
          _localizations?.rewardAdPreparing ?? 'Reklam Hazırlanıyor',
          _localizations?.rewardAdNotReadyMessage ?? 'Reklam henüz hazır değil. Lütfen birkaç saniye bekleyip tekrar deneyin.',
        );
      }
      
      return success;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error showing rewarded ad: $e');
        debugPrint('❌ Error type: ${e.runtimeType}');
      }
      
      IslamicSnackbar.showError(
        _localizations?.rewardAdError ?? 'Reklam Hatası',
        _localizations?.rewardAdWatchError ?? 'Reklam izlenirken bir hata oluştu. Lütfen tekrar deneyin.',
      );
      
      return false;
    }
  }

  // Ödül kazanıldığında çağrılır
  Future<void> _handleRewardEarned(RewardFeatureType featureType) async {
    try {
      final storageService = Get.find<StorageService>();
      final currentStatus = getFeatureStatus(featureType);
      
      int newAdsWatched = currentStatus.adsWatched + 1;
      DateTime? newUnlockedAt;
      
      if (newAdsWatched >= 3) {
        // 3. reklam izlendi - özelliği aç
        newUnlockedAt = await _getNetworkTime();
        newAdsWatched = 0; // Sayacı sıfırla
        
        if (kDebugMode) {
          debugPrint('🎉 Feature unlocked: ${_getFeatureName(featureType)} for 24 hours');
          debugPrint('🕐 Unlocked at network time: $newUnlockedAt');
        }
      }
      
      // Storage'a kaydet
      await storageService.saveRewardAdsWatched(featureType, newAdsWatched);
      
      if (newUnlockedAt != null) {
        await storageService.saveRewardUnlockedAt(featureType, newUnlockedAt);
      }
      
      // Status'u güncelle
      final newStatus = RewardFeatureStatus(
        featureType: featureType,
        adsWatched: newAdsWatched,
        unlockedAt: newUnlockedAt,
      );
      
      _updateFeatureStatus(featureType, newStatus);
      
      // Widget'ları güncelle
      try {
        final subscriptionService = Get.find<SubscriptionService>();
        await subscriptionService.updateAllWidgets();
        
        // UI güncellemesini tetikle - Observable değerleri güncelle
        _dhikrWidgetStatus.refresh();
        _quranWidgetStatus.refresh();
        _remindersStatus.refresh();
        _reminderTimesStatus.refresh();
        
        // Android widget'larının güncellenmesi için ek bir bekleme süresi
        await Future.delayed(const Duration(milliseconds: 500));
        
        // İkinci bir widget güncelleme sinyali gönder (güçlü güncelleme)
        await subscriptionService.updateAllWidgets();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Error updating widgets after reward: $e');
        }
      }
      
      // Başarı mesajı göster
      IslamicSnackbar.showSuccess(
        _localizations?.rewardEarned ?? 'Ödül Kazanıldı!',
        newUnlockedAt != null 
          ? (_localizations?.rewardFeatureUnlocked(_getFeatureName(featureType)) ?? '${_getFeatureName(featureType)} 24 saat boyunca açıldı!')
          : (_localizations?.rewardAdsRemaining(3 - newAdsWatched) ?? '${3 - newAdsWatched} reklam daha izleyerek bu özelliği açabilirsiniz.'),
      );
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error handling reward: $e');
      }
    }
  }

  String _getFeatureName(RewardFeatureType featureType) {
    switch (featureType) {
      case RewardFeatureType.dhikrWidget:
        return _localizations?.rewardDhikrWidget ?? 'Zikir Widget\'ı';
      case RewardFeatureType.quranWidget:
        return _localizations?.rewardQuranWidget ?? 'Kuran Widget\'ı';
      case RewardFeatureType.reminders:
        return _localizations?.rewardReminders ?? 'Hatırlatıcılar';
      case RewardFeatureType.reminderTimes:
        return _localizations?.rewardReminderTimes ?? 'Hatırlatma Saatleri';
    }
  }

  void _updateFeatureStatus(RewardFeatureType featureType, RewardFeatureStatus status) {
    switch (featureType) {
      case RewardFeatureType.dhikrWidget:
        _dhikrWidgetStatus.value = status;
        break;
      case RewardFeatureType.quranWidget:
        _quranWidgetStatus.value = status;
        break;
      case RewardFeatureType.reminders:
        _remindersStatus.value = status;
        break;
      case RewardFeatureType.reminderTimes:
        _reminderTimesStatus.value = status;
        break;
    }
  }

  RewardFeatureStatus getFeatureStatus(RewardFeatureType featureType) {
    switch (featureType) {
      case RewardFeatureType.dhikrWidget:
        return dhikrWidgetStatus;
      case RewardFeatureType.quranWidget:
        return quranWidgetStatus;
      case RewardFeatureType.reminders:
        return remindersStatus;
      case RewardFeatureType.reminderTimes:
        return reminderTimesStatus;
    }
  }

  // Süresi dolmuş reward'ları temizle
  Future<void> cleanExpiredRewards() async {
    try {
      final storageService = Get.find<StorageService>();
      bool hasChanges = false;
      
      // Her feature için kontrol et
      for (final featureType in RewardFeatureType.values) {
        final status = getFeatureStatus(featureType);
        if (status.unlockedAt != null && 
            DateTime.now().difference(status.unlockedAt!).inHours >= 24) {
          
          _clearFeatureStatus(featureType, storageService);
          _updateFeatureStatus(featureType, RewardFeatureStatus(
            featureType: featureType,
            adsWatched: 0,
          ));
          hasChanges = true;
          
          if (kDebugMode) {
            debugPrint('🧹 Cleaned expired reward: ${_getFeatureName(featureType)}');
          }
        }
      }
      
      // Widget'ları güncelle
      if (hasChanges) {
        try {
          final subscriptionService = Get.find<SubscriptionService>();
          await subscriptionService.updateAllWidgets();
        } catch (e) {
          if (kDebugMode) {
            debugPrint('❌ Error updating widgets after cleanup: $e');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error cleaning expired rewards: $e');
      }
    }
  }

  // Periyodik temizlik programla
  void _scheduleCleanupExpiredRewards() {
    // Her 30 dakikada bir kontrol et
    Future.delayed(const Duration(minutes: 30), () {
      cleanExpiredRewards();
      _scheduleCleanupExpiredRewards();
    });
  }
}