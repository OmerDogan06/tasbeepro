
import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:tasbeepro/models/subscription_plan.dart';
import 'package:tasbeepro/screens/premium_screen.dart';
import '../widgets/islamic_snackbar.dart';

import 'storage_service.dart';

class SubscriptionService extends GetxController {
  static SubscriptionService get to => Get.find();
  
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  final isPremium = false.obs;
  final _availableProducts = <ProductDetails>[].obs;
  final _isLoading = false.obs;
  
  // Product IDs - Google Play Console'da tanımlanmış
  static const String monthlyPremiumId = 'tasbee_pro_premium_monthly';
  static const String yearlyPremiumId = 'tasbee_pro_premium_yearly';
  
  static const Set<String> productIds = {
    monthlyPremiumId,
    yearlyPremiumId,
  };
  
 
  List<ProductDetails> get availableProducts => _availableProducts;
  bool get isLoading => _isLoading.value;
  
  // Premium özelliklere erişim kontrolü
  bool get isAdFreeEnabled => isPremium.value;
  bool get areRemindersEnabled => isPremium.value;
  bool get isWidgetEnabled => isPremium.value;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _loadPremiumStatus();
    await _initializePurchases();
    _startListeningToPurchaseUpdates();
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }

  // Premium durumunu yükle
  Future<void> _loadPremiumStatus() async {
    try {
      final storageService = Get.find<StorageService>();
      final isPremiumX = storageService.getPremiumStatus();
      isPremium.value = isPremiumX;
      
      if (kDebugMode) {
        print('📱 Premium status loaded: $isPremium');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading premium status: $e');
      }
      isPremium.value = false;
    }
  }

  // Premium durumunu güncelle (background service tarafından çağrılabilir)
  Future<void> refreshPremiumStatus() async {
    final oldValue = isPremium.value;
    
    // Önce storage'dan yükle
    await _loadPremiumStatus();
    
    // Aktif satın alımları da kontrol et
    await _checkActivePurchases();
    
    // Eğer değer değiştiyse güncelle
    if (oldValue != isPremium.value) {
      if (kDebugMode) {
        print('🔄 Premium status manually refreshed: $oldValue -> ${isPremium.value}');
      }
    }
  }

  // Aktif satın alımları kontrol et
  Future<void> _checkActivePurchases() async {
    try {
      // RestorePurchases çağrısından sonra stream üzerinden güncellenecek
      // Bu yüzden sadece restore işlemini başlat
      await _inAppPurchase.restorePurchases();
      
      if (kDebugMode) {
        print('🔄 Restore purchases initiated for active purchase check');
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking active purchases: $e');
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
    // Aktif satın alımları kontrol et
    await _restorePurchases();
  }

  void _startListeningToPurchaseUpdates() {
    _subscription = _inAppPurchase.purchaseStream.listen(
      (List<PurchaseDetails> purchaseDetailsList) {
        _handlePurchaseUpdates(purchaseDetailsList);
      },
      onDone: () {
        if (kDebugMode) {
          print('Purchase stream closed');
        }
      },
      onError: (error) {
        if (kDebugMode) {
          print('Purchase stream error: $error');
        }
      },
    );
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Satın alma beklemede
        _showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          // Hata durumu
          _handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                   purchaseDetails.status == PurchaseStatus.restored) {
          // Başarılı satın alma
          await _handleSuccessfulPurchase(purchaseDetails);
        }
        
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) async {
    try {
      final String productId = purchaseDetails.productID;
      
      // Eğer bu bizim premium ürünlerimizden biriyse
      if (productIds.contains(productId)) {
        // Premium durumunu aktif et
        isPremium.value = true;
        
        // Storage'a kaydet
        final storageService = Get.find<StorageService>();
        await storageService.savePremiumStatus(true);
        
        if (kDebugMode) {
          print('🎉 Premium activated for product: $productId');
        }
        
        IslamicSnackbar.showSuccess(
          'Başarılı!',
          'Premium aboneliğiniz aktifleştirildi. Tüm premium özellikler artık kullanımınıza açık.',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error handling successful purchase: $e');
      }
    }
  }

  void _showPendingUI() {
    IslamicSnackbar.showInfo(
      'Satın alma işlemi',
      'Satın alma işlemi devam ediyor. Lütfen bekleyin...',
    );
  }

  void _handleError(IAPError error) {
    String message = 'Satın alma işleminde hata oluştu.';
    
    switch (error.code) {
      case 'user_cancelled':
        message = 'Satın alma işlemi iptal edildi.';
        break;
      case 'payment_invalid':
        message = 'Ödeme bilgileri geçersiz.';
        break;
      case 'product_not_available':
        message = 'Ürün mevcut değil.';
        break;
    }
    
    if (kDebugMode) {
      print('❌ Purchase error: ${error.code} - $message');
    }
    
    IslamicSnackbar.showError(
      'Hata',
      message,
    );
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
      Get.to(() => PremiumScreen(), transition: Transition.rightToLeft);
      },
    );
  }

  // Premium kontrol ve gerekirse dialog göster
  bool checkPremiumAccess({bool showDialog = true}) {
    if (isPremium.value) {
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
      await refreshPremiumStatus();
      
      if (isPremium.value) {
        IslamicSnackbar.showSuccess(
          'Kontrol Tamamlandı',
          'Premium durumunuz güncellendi: Aktif ✨',
        );
      } else {
        IslamicSnackbar.showInfo(
          'Kontrol Tamamlandı',
          'Premium durumunuz güncellendi: Pasif',
        );
      }
    } catch (e) {
      IslamicSnackbar.showError(
        'Hata',
        'Premium durumu kontrol edilirken hata oluştu. Lütfen daha sonra tekrar deneyin.',
      );
    }
  }

  // Premium screen için uyumluluk method'ları
  bool get isTrialActive => false; // Artık deneme süresi yok
  String get trialStatusText => ''; // Artık deneme süresi metni yok
  
  Future<bool> purchaseSubscription(SubscriptionPlan plan) async {
    if (plan == SubscriptionPlan.free) return false;
    
    try {
      _isLoading.value = true;
      
      final ProductDetails? product = _availableProducts.firstWhereOrNull(
        (p) => p.id == plan.productId,
      );
      
      if (product == null) {
        IslamicSnackbar.showError(
          'Hata',
          'Ürün bulunamadı. Lütfen daha sonra tekrar deneyin.',
        );
        return false;
      }
      
      if (kDebugMode) {
        print('🛒 Purchasing product: ${product.id}');
      }
      
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      bool success = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      
      if (kDebugMode) {
        print('🛒 Purchase initiated: $success');
      }
      
      return success;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error purchasing subscription: $e');
      }
      IslamicSnackbar.showError(
        'Hata',
        'Satın alma işleminde hata oluştu. Lütfen internet bağlantınızı kontrol edin ve tekrar deneyin.',
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error restoring purchases: $e');
      }
    }
  }

  Future<void> restorePurchases() async {
    try {
      _isLoading.value = true;
      await _restorePurchases();
      
      IslamicSnackbar.showSuccess(
        'Başarılı',
        'Satın alımlar geri yüklendi. Premium özellikleriniz kontrol ediliyor...',
      );
    } catch (e) {
      IslamicSnackbar.showError(
        'Hata',
        'Satın alımlar geri yüklenirken hata oluştu. Lütfen internet bağlantınızı kontrol edin.',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Abonelik durumu metni
  String get subscriptionStatusText {
    if (isPremium.value) {
      return 'Premium üyelik aktif';
    } else {
      return 'Premium ile daha fazla özellik';
    }
  }
}