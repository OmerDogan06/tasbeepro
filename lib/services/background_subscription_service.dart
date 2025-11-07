import 'dart:async';
import 'package:get/get.dart';
import 'package:workmanager/workmanager.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter/foundation.dart';
import 'storage_service.dart';


class BackgroundSubscriptionService extends GetxService {
  static const String _taskName = 'dailySubscriptionCheck';
  static const String _uniqueTaskName = 'dailySubscriptionCheckUnique';
  
  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeWorkManager();
    await _scheduleDailyCheck();
  }

  Future<void> _initializeWorkManager() async {
    await Workmanager().initialize(
      _callbackDispatcher,
      isInDebugMode: kDebugMode,
    );
  }

  Future<void> _scheduleDailyCheck() async {
    try {
      // Önceki task'ları iptal et
      await Workmanager().cancelAll();
      
      // Günde bir kez çalışacak periyodik task
      await Workmanager().registerPeriodicTask(
        _uniqueTaskName,
        _taskName,
        frequency: const Duration(minutes: 3), // Günde 1 kez
        initialDelay: const Duration(minutes: 1), // İlk çalıştırma 5dk sonra
        constraints: Constraints(
          networkType: NetworkType.connected, // İnternet gerekli
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
      );
      
      if (kDebugMode) {
        print('🔄 Daily subscription check scheduled');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error scheduling daily check: $e');
      }
    }
  }

  // Test için manuel kontrol
  Future<void> checkSubscriptionNow() async {
    await _performSubscriptionCheck();
  }

  // Ana subscription kontrol fonksiyonu
  static Future<void> _performSubscriptionCheck() async {
    try {
      if (kDebugMode) {
        print('🔍 Performing daily subscription check...');
      }

      final InAppPurchase inAppPurchase = InAppPurchase.instance;
      final bool available = await inAppPurchase.isAvailable();
      
      // Mevcut premium durumunu al (internet yoksa bu korunacak)
      final storage = StorageService();
      await storage.init();
      bool isPremium = storage.getPremiumStatus(); // Mevcut durumu koru
      
      if (available) {
        try {
          // Aktif satın alımları kontrol et
          await inAppPurchase.restorePurchases();
          
          // Purchase stream'i dinle (kısa süre)
          final StreamSubscription subscription = inAppPurchase.purchaseStream.listen(
            (List<PurchaseDetails> purchaseDetailsList) async {
              for (final PurchaseDetails purchase in purchaseDetailsList) {
                if (purchase.status == PurchaseStatus.purchased || 
                    purchase.status == PurchaseStatus.restored) {
                  // Premium paket bulundu
                  isPremium = true;
                  if (kDebugMode) {
                    print('✅ Active premium subscription found: ${purchase.productID}');
                  }
                  break;
                }
              }
            },
          );
          
          // 10 saniye bekle
          await Future.delayed(const Duration(seconds: 10));
          await subscription.cancel();
          
        } catch (e) {
          if (kDebugMode) {
            print('❌ Error checking purchases: $e');
            print('ℹ️ Keeping existing premium status: $isPremium');
          }
          // İnternet hatası - mevcut durumu koru, değiştirme
        }
      } else {
        if (kDebugMode) {
          print('❌ In-app purchase not available');
          print('ℹ️ Keeping existing premium status: $isPremium');
        }
        // İnternet yok - mevcut durumu koru, değiştirme
      }

      // Sadece internet varken ve kontrol başarılıysa sonucu kaydet
      if (available) {
        await _savePremiumStatus(isPremium);
        if (kDebugMode) {
          print('💾 Premium status updated: $isPremium');
        }
      } else {
        if (kDebugMode) {
          print('ℹ️ No internet - premium status unchanged: $isPremium');
        }
      }

    } catch (e) {
      if (kDebugMode) {
        print('❌ Subscription check failed: $e');
        print('ℹ️ Keeping existing premium status due to error');
      }
      // Genel hata durumunda mevcut durumu koru, değiştirme
    }
  }

  // Premium durumunu SharedPreferences'a kaydet
  static Future<void> _savePremiumStatus(bool isPremium) async {
    try {
      // SharedPreferences'ı manuel başlat (background task'ta GetX mevcut olmayabilir)
      final storage = StorageService();
      await storage.init();
      
      await storage.savePremiumStatus(isPremium);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving premium status: $e');
      }
    }
  }
}

// WorkManager callback dispatcher - Global fonksiyon olmalı
@pragma('vm:entry-point')
void _callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (kDebugMode) {
      print('🚀 Background task started: $task');
    }

    try {
      switch (task) {
        case 'dailySubscriptionCheck':
          await BackgroundSubscriptionService._performSubscriptionCheck();
          break;
        default:
          if (kDebugMode) {
            print('❓ Unknown task: $task');
          }
      }
      
      return Future.value(true);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Background task failed: $e');
      }
      return Future.value(false);
    }
  });
}