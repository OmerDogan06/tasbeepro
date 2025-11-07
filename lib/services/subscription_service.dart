
import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:tasbeepro/models/subscription_plan.dart';

import 'storage_service.dart';
import 'background_subscription_service.dart';

class SubscriptionService extends GetxController {
  static SubscriptionService get to => Get.find();
  
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final _isPremium = false.obs;
  final _availableProducts = <ProductDetails>[].obs;
  final _isLoading = false.obs;
  
  // Product IDs - Google Play Console'da tanımlanmış
  static const String monthlyPremiumId = 'tasbee_pro_premium_monthly';
  static const String yearlyPremiumId = 'tasbee_pro_premium_yearly';
  
  static const Set<String> productIds = {
    monthlyPremiumId,
    yearlyPremiumId,
  };
  
  // Getters
  bool get isPremium => _isPremium.value;
  List<ProductDetails> get availableProducts => _availableProducts;
  bool get isLoading => _isLoading.value;
  
  // Premium özelliklere erişim kontrolü
  bool get isAdFreeEnabled => _isPremium.value;
  bool get areRemindersEnabled => _isPremium.value;
  bool get isWidgetEnabled => _isPremium.value;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _loadPremiumStatus();
    await _initializePurchases();
    
    // Background service'i başlat
    Get.put(BackgroundSubscriptionService());
  }

  // Premium durumunu yükle
  Future<void> _loadPremiumStatus() async {
    try {
      final storageService = Get.find<StorageService>();
      final isPremium = storageService.getPremiumStatus();
      _isPremium.value = isPremium;
      
      if (kDebugMode) {
        print('📱 Premium status loaded: $isPremium');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading premium status: $e');
      }
      _isPremium.value = false;
    }
  }

  // Premium durumunu güncelle (background service tarafından çağrılabilir)
  Future<void> refreshPremiumStatus() async {
    final oldValue = _isPremium.value;
    await _loadPremiumStatus();
    
    // Eğer değer değiştiyse güncelle
    if (oldValue != _isPremium.value) {
      if (kDebugMode) {
        print('🔄 Premium status manually refreshed: $oldValue -> ${_isPremium.value}');
      }
    }
  }

  Future<void> _initializePurchases() async {
    final bool available = await _inAppPurchase.isAvailable();
    
    if (!available) {
      if (kDebugMode) {
        print('❌ In-app purchase servisi kullanılamıyor');
      }
      return;
    }

    await _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      _isLoading.value = true;

      final ProductDetailsResponse response = 
          await _inAppPurchase.queryProductDetails(productIds);

      if (response.notFoundIDs.isNotEmpty) {
        if (kDebugMode) {
          print('⚠️ Bazı ürünler bulunamadı: ${response.notFoundIDs}');
        }
      }
      
      if (response.productDetails.isNotEmpty) {
        _availableProducts.value = response.productDetails;
        
        // Ürün bilgilerini göster
        for (final product in response.productDetails) {
          if (kDebugMode) {
            print('💰 Price: ${product.price}');
            print('💱 Currency: ${product.currencyCode}');
            print('📝 Title: ${product.title}');
            print('🆔 ID: ${product.id}');
          }
        }
      } else {
        if (kDebugMode) {
          print('❌ Hiç ürün yüklenemedi');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Ürünler yüklenirken hata: $e');
      }
    } finally {
      _isLoading.value = false;
    }
  }

  // Premium özellik kullanmaya çalışırken çağrılacak
  void showPremiumDialog() {
    Get.defaultDialog(
      title: 'Premium Özellik',
      middleText: 'Bu özellik premium abonelik gerektirir.',
      textConfirm: 'Premium\'a Geç',
      textCancel: 'İptal',
      onConfirm: () {
        Get.back();
        // Premium satın alma sayfasına git
      Get.toNamed('/premium');
      },
    );
  }

  // Premium kontrol ve gerekirse dialog göster
  bool checkPremiumAccess({bool showDialog = true}) {
    if (_isPremium.value) {
      return true;
    }
    
    if (showDialog) {
      showPremiumDialog();
    }
    
    return false;
  }

  // Test için manuel subscription check
  Future<void> forceCheckSubscription() async {
    try {
      final backgroundService = Get.find<BackgroundSubscriptionService>();
      await backgroundService.checkSubscriptionNow();
      await refreshPremiumStatus();
      
      Get.snackbar(
        'Kontrol Tamamlandı',
        'Premium durumunuz güncellendi: ${_isPremium.value ? "Aktif" : "Pasif"}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Premium durumu kontrol edilirken hata oluştu.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Premium screen için uyumluluk method'ları
  bool get isTrialActive => false; // Artık deneme süresi yok
  String get trialStatusText => ''; // Artık deneme süresi metni yok
  
  // Uyumluluk için boş method'lar - Premium screen kullanması için
  Future<bool> purchaseSubscription(SubscriptionPlan plan) async {
    if (plan == SubscriptionPlan.free) return false;
    
    try {
      _isLoading.value = true;
      
      final ProductDetails? product = _availableProducts.firstWhereOrNull(
        (p) => p.id == plan.productId,
      );
      
      if (product == null) {
        Get.snackbar(
          'Hata',
          'Ürün bulunamadı.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
      
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      bool success = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      return success;
    } catch (e) {
      print('Error purchasing subscription: $e');
      Get.snackbar(
        'Hata',
        'Satın alma işleminde hata oluştu.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      print('Error restoring purchases: $e');
    }
  }

  // Abonelik durumu metni
  String get subscriptionStatusText {
    if (_isPremium.value) {
      return 'Premium üyelik aktif';
    } else {
      return 'Premium ile daha fazla özellik';
    }
  }
}