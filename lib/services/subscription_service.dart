
import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:tasbeepro/models/subscription_plan.dart';
import 'package:tasbeepro/screens/premium_screen.dart';
import '../widgets/islamic_snackbar.dart';
import '../l10n/app_localizations.dart';

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
        
        final context = Get.context;
        IslamicSnackbar.showSuccess(
          context != null ? (AppLocalizations.of(context)?.purchaseSuccessTitle ?? 'Başarılı!') : 'Başarılı!',
          context != null ? (AppLocalizations.of(context)?.purchaseSuccessMessage ?? 'Premium aboneliğiniz aktifleştirildi. Tüm premium özellikler artık kullanımınıza açık.') : 'Premium aboneliğiniz aktifleştirildi. Tüm premium özellikler artık kullanımınıza açık.',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error handling successful purchase: $e');
      }
    }
  }

  void _showPendingUI() {
    final context = Get.context;
    IslamicSnackbar.showInfo(
      context != null ? (AppLocalizations.of(context)?.purchasePendingTitle ?? 'Satın alma işlemi') : 'Satın alma işlemi',
      context != null ? (AppLocalizations.of(context)?.purchasePendingMessage ?? 'Satın alma işlemi devam ediyor. Lütfen bekleyin...') : 'Satın alma işlemi devam ediyor. Lütfen bekleyin...',
    );
  }

  void _handleError(IAPError error) {
    final context = Get.context;
    String message = context != null ? (AppLocalizations.of(context)?.purchaseErrorDefault ?? 'Satın alma işleminde hata oluştu.') : 'Satın alma işleminde hata oluştu.';
    
    if (context != null) {
      switch (error.code) {
        case 'user_cancelled':
          message = AppLocalizations.of(context)?.purchaseErrorCancelled ?? 'Satın alma işlemi iptal edildi.';
          break;
        case 'payment_invalid':
          message = AppLocalizations.of(context)?.purchaseErrorInvalidPayment ?? 'Ödeme bilgileri geçersiz.';
          break;
        case 'product_not_available':
          message = AppLocalizations.of(context)?.purchaseErrorProductNotAvailable ?? 'Ürün mevcut değil.';
          break;
      }
    } else {
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
    }
    
    if (kDebugMode) {
      print('❌ Purchase error: ${error.code} - $message');
    }
    
    IslamicSnackbar.showError(
      context != null ? (AppLocalizations.of(context)?.purchaseErrorTitle ?? 'Hata') : 'Hata',
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
    final context = Get.context;
    Get.defaultDialog(
      title: context != null ? (AppLocalizations.of(context)?.premiumFeatureTitle ?? 'Premium Özellik') : 'Premium Özellik',
      middleText: context != null ? (AppLocalizations.of(context)?.premiumFeatureMessage ?? 'Bu özellik premium abonelik gerektirir.') : 'Bu özellik premium abonelik gerektirir.',
      textConfirm: context != null ? (AppLocalizations.of(context)?.premiumFeatureConfirm ?? 'Premium\'a Geç') : 'Premium\'a Geç',
      textCancel: context != null ? (AppLocalizations.of(context)?.premiumFeatureCancel ?? 'İptal') : 'İptal',
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
    final context = Get.context;
    try {
      await refreshPremiumStatus();
      
      if (isPremium.value) {
        IslamicSnackbar.showSuccess(
          context != null ? (AppLocalizations.of(context)?.subscriptionCheckTitle ?? 'Kontrol Tamamlandı') : 'Kontrol Tamamlandı',
          context != null ? (AppLocalizations.of(context)?.subscriptionCheckActiveMessage ?? 'Premium durumunuz güncellendi: Aktif ✨') : 'Premium durumunuz güncellendi: Aktif ✨',
        );
      } else {
        IslamicSnackbar.showInfo(
          context != null ? (AppLocalizations.of(context)?.subscriptionCheckTitle ?? 'Kontrol Tamamlandı') : 'Kontrol Tamamlandı',
          context != null ? (AppLocalizations.of(context)?.subscriptionCheckInactiveMessage ?? 'Premium durumunuz güncellendi: Pasif') : 'Premium durumunuz güncellendi: Pasif',
        );
      }
    } catch (e) {
      IslamicSnackbar.showError(
        context != null ? (AppLocalizations.of(context)?.purchaseErrorTitle ?? 'Hata') : 'Hata',
        context != null ? (AppLocalizations.of(context)?.subscriptionCheckErrorMessage ?? 'Premium durumu kontrol edilirken hata oluştu. Lütfen daha sonra tekrar deneyin.') : 'Premium durumu kontrol edilirken hata oluştu. Lütfen daha sonra tekrar deneyin.',
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
        final context = Get.context;
        IslamicSnackbar.showError(
          context != null ? (AppLocalizations.of(context)?.productNotFoundTitle ?? 'Hata') : 'Hata',
          context != null ? (AppLocalizations.of(context)?.productNotFoundMessage ?? 'Ürün bulunamadı. Lütfen daha sonra tekrar deneyin.') : 'Ürün bulunamadı. Lütfen daha sonra tekrar deneyin.',
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
      final context = Get.context;
      IslamicSnackbar.showError(
        context != null ? (AppLocalizations.of(context)?.purchaseErrorTitle ?? 'Hata') : 'Hata',
        context != null ? (AppLocalizations.of(context)?.purchaseNetworkErrorMessage ?? 'Satın alma işleminde hata oluştu. Lütfen internet bağlantınızı kontrol edin ve tekrar deneyin.') : 'Satın alma işleminde hata oluştu. Lütfen internet bağlantınızı kontrol edin ve tekrar deneyin.',
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
      
      final context = Get.context;
      IslamicSnackbar.showSuccess(
        context != null ? (AppLocalizations.of(context)?.restorePurchaseSuccessTitle ?? 'Başarılı') : 'Başarılı',
        context != null ? (AppLocalizations.of(context)?.restorePurchaseSuccessMessage ?? 'Satın alımlar geri yüklendi. Premium özellikleriniz kontrol ediliyor...') : 'Satın alımlar geri yüklendi. Premium özellikleriniz kontrol ediliyor...',
      );
    } catch (e) {
      final context = Get.context;
      IslamicSnackbar.showError(
        context != null ? (AppLocalizations.of(context)?.restorePurchaseErrorTitle ?? 'Hata') : 'Hata',
        context != null ? (AppLocalizations.of(context)?.restorePurchaseErrorMessage ?? 'Satın alımlar geri yüklenirken hata oluştu. Lütfen internet bağlantınızı kontrol edin.') : 'Satın alımlar geri yüklenirken hata oluştu. Lütfen internet bağlantınızı kontrol edin.',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Abonelik durumu metni
  String get subscriptionStatusText {
    final context = Get.context;
    if (isPremium.value) {
      return context != null ? (AppLocalizations.of(context)?.subscriptionActiveStatus ?? 'Premium üyelik aktif') : 'Premium üyelik aktif';
    } else {
      return context != null ? (AppLocalizations.of(context)?.subscriptionInactiveStatus ?? 'Premium ile daha fazla özellik') : 'Premium ile daha fazla özellik';
    }
  }
}