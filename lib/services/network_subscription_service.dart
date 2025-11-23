import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'subscription_service.dart';
import 'ad_service.dart';

/// NetworkSubscriptionService
/// 
/// Bu servisin amacı:
/// - Kullanıcı uygulamayı internetsiz açtı
/// - Uygulama açılırken SubscriptionService çalıştı ama internet olmadığı için premium kontrolü yapamadı
/// - Sonrasında kullanıcının internetine bağlandığında otomatik olarak premium durumunu kontrol etmek
/// 
/// Çalışma mantığı:
/// - Sadece offline -> online geçişlerinde çalışır
/// - İlk açılışta internet varsa hiçbir şey yapmaz (SubscriptionService zaten kontrol eder)
/// - İnternet yoktan var olduğunda Google Play'den premium durumunu kontrol eder
class NetworkSubscriptionService extends GetxService {
  static NetworkSubscriptionService get to => Get.find();
  
  final Connectivity _connectivity = Connectivity();
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  
  bool _wasDisconnected = false;
  bool _isCheckingPurchases = false;
  
  // Product IDs - SubscriptionService ile aynı
  static const Set<String> productIds = {
    'tasbee_pro_premium_monthly',
    'tasbee_pro_premium_yearly',
  };

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeConnectivityListener();
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }

  Future<void> _initializeConnectivityListener() async {
    try {
      // İlk bağlantı durumunu kontrol et
      final initialConnectivity = await _connectivity.checkConnectivity();
      _wasDisconnected = _isDisconnected(initialConnectivity);
      
      if (kDebugMode) {
        print('🌐 Initial connectivity: $initialConnectivity');
        print('🌐 Initially disconnected: $_wasDisconnected');
        print('🌐 NetworkSubscriptionService will only work on reconnection (offline -> online)');
      }

      // Bağlantı değişikliklerini dinle
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _onConnectivityChanged,
        onError: (error) {
          if (kDebugMode) {
            print('❌ Connectivity stream error: $error');
          }
        },
      );
      
      if (kDebugMode) {
        print('🌐 Network subscription service initialized - waiting for reconnection events');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing connectivity listener: $e');
      }
    }
  }

  bool _isDisconnected(List<ConnectivityResult> results) {
    return results.isEmpty || 
           results.every((result) => result == ConnectivityResult.none);
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) async {
    final isCurrentlyDisconnected = _isDisconnected(results);
    
    if (kDebugMode) {
      print('🌐 Connectivity changed: $results');
      print('🌐 Was disconnected: $_wasDisconnected, Currently disconnected: $isCurrentlyDisconnected');
    }

    // SADECE bağlantısız durumdan bağlantılı duruma geçtiyse çalış
    // Bu servisin amacı: Kullanıcı internetsiz açtı -> sonra internet geldi -> kontrol yap
    if (_wasDisconnected && !isCurrentlyDisconnected) {
      if (kDebugMode) {
        print('🌐 ✅ RECONNECTION DETECTED! User was offline, now online.');
        print('🌐 🎯 Actions to perform:');
        print('🌐    1. Check premium subscription status');
        print('🌐    2. Reload ad services (rewarded ads)');
        print('🌐 🚀 Starting reconnection process...');
      }
      
      // Premium durumu kontrol et
      await _checkPremiumStatusOnReconnect();
      
      // Reklam servislerini yeniden başlat
      await _reloadAdServicesOnReconnect();
    } else if (!_wasDisconnected && !isCurrentlyDisconnected) {
      if (kDebugMode) {
        print('🌐 ℹ️ Still online - no action needed (SubscriptionService handles initial checks)');
      }
    } else if (!_wasDisconnected && isCurrentlyDisconnected) {
      if (kDebugMode) {
        print('🌐 ⚠️ Connection lost - waiting for reconnection...');
      }
    }
    
    // Mevcut durumu güncelle
    _wasDisconnected = isCurrentlyDisconnected;
  }

  Future<void> _checkPremiumStatusOnReconnect() async {
    // Eğer zaten kontrol ediyorsa, tekrar kontrol etme
    if (_isCheckingPurchases) {
      if (kDebugMode) {
        print('🌐 Already checking purchases, skipping...');
      }
      return;
    }

    try {
      _isCheckingPurchases = true;
      
      // In-app purchase servisinin kullanılabilir olup olmadığını kontrol et
      final bool available = await _inAppPurchase.isAvailable();
      if (!available) {
        if (kDebugMode) {
          print('❌ In-app purchase service not available');
        }
        return;
      }

      if (kDebugMode) {
        print('🛒 Checking active purchases from Google Play (after reconnection)...');
      }

      // Geçmiş satın alımları kontrol et
      await _inAppPurchase.restorePurchases();
      
      // Kısa bir bekleme süresi - restore işleminin tamamlanması için
      await Future.delayed(const Duration(seconds: 2));
      
      // Manual olarak premium durumunu kontrol et
      await _manuallyCheckPremiumStatus();
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking premium status on reconnect: $e');
      }
    } finally {
      _isCheckingPurchases = false;
    }
  }

  Future<void> _manuallyCheckPremiumStatus() async {
    try {
      // Subscription service'i al
      final subscriptionService = Get.find<SubscriptionService>();
      
      // Mevcut premium durumunu kaydet
      final oldPremiumStatus = subscriptionService.isPremium.value;
      
      if (kDebugMode) {
        print('🔍 Current premium status: $oldPremiumStatus');
      }

      // SubscriptionService'teki refresh metodunu çağır
      await subscriptionService.refreshPremiumStatus();
      
      // Yeni durumu kontrol et
      final newPremiumStatus = subscriptionService.isPremium.value;
      
      if (kDebugMode) {
        print('🔍 Updated premium status: $newPremiumStatus');
      }

      // Eğer durum değiştiyse log yaz
      if (oldPremiumStatus != newPremiumStatus) {
        if (kDebugMode) {
          print('🔄 Premium status changed: $oldPremiumStatus -> $newPremiumStatus');
        }
        
        // İstatistik için log
        if (newPremiumStatus) {
          if (kDebugMode) {
            print('✅ Premium subscription restored from Google Play');
          }
        } else {
          if (kDebugMode) {
            print('❌ Premium subscription not found in Google Play');
          }
        }
      } else {
        if (kDebugMode) {
          print('ℹ️ Premium status unchanged after network check');
        }
      }

    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in manual premium status check: $e');
      }
    }
  }

  Future<void> _reloadAdServicesOnReconnect() async {
    try {
      if (kDebugMode) {
        print('🎯 Reloading ad services after network reconnection...');
      }
      
      // AdService'i bul ve yeniden başlat
      if (Get.isRegistered<AdService>()) {
        final adService = Get.find<AdService>();
        
        if (kDebugMode) {
          print('🔄 Force reloading rewarded ads after reconnection...');
        }
        
        // Rewarded ad'leri yeniden yükle - public metod gerekli
        // AdService'e public metod eklenecek
        await _forceReloadRewardedAd(adService);
        
        if (kDebugMode) {
          print('✅ Ad services reloaded successfully after network reconnection');
        }
      } else {
        if (kDebugMode) {
          print('⚠️ AdService not found during network reconnection');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error reloading ad services on reconnect: $e');
      }
    }
  }

  Future<void> _forceReloadRewardedAd(AdService adService) async {
    try {
      if (kDebugMode) {
        print('🎬 Current rewarded ad ready status: ${adService.isRewardedAdReady}');
      }
      
      // AdService'in yeni public metodunu kullan
      await adService.forceReloadAdsAfterReconnection();
      
      // Kısa bir bekleme süresi - reklamların yüklenmesi için
      await Future.delayed(const Duration(seconds: 3));
      
      if (kDebugMode) {
        print('🔍 Rewarded ad status after reload: ${adService.isRewardedAdReady}');
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in force reload rewarded ad: $e');
      }
    }
  }

  // Manual kontrol için public metod (test amaçlı)
  Future<void> forceCheckPremiumStatus() async {
    if (kDebugMode) {
      print('🔄 Force checking premium status (manual trigger)...');
    }
    
    final connectivityResult = await _connectivity.checkConnectivity();
    if (_isDisconnected(connectivityResult)) {
      if (kDebugMode) {
        print('❌ No internet connection for manual check');
      }
      return;
    }
    
    await _checkPremiumStatusOnReconnect();
  }

  // Manuel reklam yeniden yükleme için public metod
  Future<void> forceReloadAds() async {
    if (kDebugMode) {
      print('🔄 Force reloading ads (manual trigger)...');
    }
    
    final connectivityResult = await _connectivity.checkConnectivity();
    if (_isDisconnected(connectivityResult)) {
      if (kDebugMode) {
        print('❌ No internet connection for manual ad reload');
      }
      return;
    }
    
    await _reloadAdServicesOnReconnect();
  }

  // Test için internet durumu bilgisi
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return !_isDisconnected(results);
  }

  // Mevcut bağlantı türü bilgisi
  Future<String> get connectionType async {
    final results = await _connectivity.checkConnectivity();
    if (_isDisconnected(results)) {
      return 'Bağlantı yok';
    }
    
    if (results.contains(ConnectivityResult.wifi)) {
      return 'Wi-Fi';
    } else if (results.contains(ConnectivityResult.mobile)) {
      return 'Mobil veri';
    } else if (results.contains(ConnectivityResult.ethernet)) {
      return 'Ethernet';
    } else {
      return 'Bilinmeyen';
    }
  }
}