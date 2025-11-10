
import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:tasbeepro/models/subscription_plan.dart';
import 'package:tasbeepro/screens/home_screen.dart';
import 'package:tasbeepro/screens/premium_screen.dart';
import '../widgets/islamic_snackbar.dart';
import '../l10n/app_localizations.dart';

import 'storage_service.dart';

class SubscriptionService extends GetxController {
 
  bool fromFirstLaunchX = false;

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
      isPremium.refresh();
     
        debugPrint('📱 Premium status loaded: $isPremium');
      
    } catch (e) {
 
        debugPrint('❌ Error loading premium status: $e');
      
      isPremium.value = false;
      isPremium.refresh();
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
     
        debugPrint('🔄 Premium status manually refreshed: $oldValue -> ${isPremium.value}');
      
    }
  }

  // Aktif satın alımları kontrol et
  Future<void> _checkActivePurchases() async {
    try {
     
        debugPrint('🔄 Checking active purchases...');
      
      
      // Restore işlemini başlat ve sonucu takip etmek için flag kullan
      bool foundActivePremium = false;
      
      // Stream'i geçici olarak dinle
      StreamSubscription<List<PurchaseDetails>>? tempSubscription;
      final Completer<void> restoreCompleter = Completer<void>();
      
      tempSubscription = _inAppPurchase.purchaseStream.listen((purchaseDetailsList) async {
        for (final purchase in purchaseDetailsList) {
          if (productIds.contains(purchase.productID) && 
              (purchase.status == PurchaseStatus.purchased || 
               purchase.status == PurchaseStatus.restored)) {
            foundActivePremium = true;
         
              debugPrint('✅ Found active premium: ${purchase.productID}');
            
            // ✅ Google Play'den satın alınan ürünler için completePurchase çağır
            if (purchase.pendingCompletePurchase) {
              try {
                await _inAppPurchase.completePurchase(purchase);
                if (kDebugMode) {
                  debugPrint('✅ Completed pending purchase from Google Play: ${purchase.productID}');
                }
              } catch (e) {
                if (kDebugMode) {
                  debugPrint('❌ Failed to complete pending purchase: $e');
                }
              }
            }
            
            break;
          }
        }
        
        // İlk response geldiğinde completer'ı tamamla
        if (!restoreCompleter.isCompleted) {
          restoreCompleter.complete();
        }
      });
      
      // Restore işlemini başlat
      await _inAppPurchase.restorePurchases();
      
      // 3 saniye bekle veya stream response gelene kadar
      await Future.any([
        restoreCompleter.future,
        Future.delayed(const Duration(seconds: 3))
      ]);
      
      // Temp subscription'ı kapat
      await tempSubscription.cancel();
      
      // Eğer aktif premium bulunamadı ve şu anki durum true ise false yap
      if (!foundActivePremium && isPremium.value) {
        isPremium.value = false;
        isPremium.refresh();
        final storageService = Get.find<StorageService>();
        await storageService.savePremiumStatus(false);
        
        // ✅ Widget'ları güncelle - Premium durumu false yapıldı
        await _updateAllWidgets();
        
     
          debugPrint('✅ Premium status corrected to false - no active subscriptions found');
        
      } else if (foundActivePremium && !isPremium.value) {
        // Aktif premium bulundu ama local durum false ise true yap
        isPremium.value = true;
        isPremium.refresh();
        final storageService = Get.find<StorageService>();
        await storageService.savePremiumStatus(true);
        
        // ✅ Widget'ları güncelle - Premium durumu true yapıldı
        await _updateAllWidgets();
        
    
          debugPrint('✅ Premium status corrected to true - active subscription found');
        
      }
      
    
        debugPrint('🔄 Active purchase check completed. Premium: ${isPremium.value}');
      
      
    } catch (e) {

        debugPrint('❌ Error checking active purchases: $e');
      
    }
  }

  Future<void> _initializePurchases() async {
    final bool available = await _inAppPurchase.isAvailable();
    
    if (!available) {
    
        debugPrint('❌ In-app purchase servisi kullanılamıyor');
      
      return;
    }

    await _loadProducts();
    // Aktif satın alımları kontrol et
    await _restorePurchases();
    await _checkActivePurchases();
  }

  void _startListeningToPurchaseUpdates() {
    _subscription = _inAppPurchase.purchaseStream.listen(
      (List<PurchaseDetails> purchaseDetailsList) {
        _handlePurchaseUpdates(purchaseDetailsList);
      },
      onDone: () {
     
          debugPrint('Purchase stream closed');
        
      },
      onError: (error) {
        
          debugPrint('Purchase stream error: $error');
        
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
        isPremium.refresh();
        
        // Storage'a kaydet
        final storageService = Get.find<StorageService>();
        await storageService.savePremiumStatus(true);
        
        // ✅ Widget'ları güncelle - Premium durumu değişti
        await _updateAllWidgets();
        
       
          debugPrint('🎉 Premium activated for product: $productId');
        
        
        final context = Get.context;
        
        // ✅ Önce navigate et, sonra snackbar göster
        if(fromFirstLaunchX == true){
          fromFirstLaunchX = false;
          Get.offAll(() => HomeScreen(), transition: Transition.rightToLeft);
        } else {
          Get.back();
        }
        
        // ✅ Navigation sonrası snackbar göster
        await Future.delayed(const Duration(milliseconds: 300));
        IslamicSnackbar.showSuccess(
          context != null ? (AppLocalizations.of(context.mounted ? context : Get.context!)?.purchaseSuccessTitle ?? 'Başarılı!') : 'Başarılı!',
          context != null ? (AppLocalizations.of(context.mounted ? context : Get.context!)?.purchaseSuccessMessage ?? 'Premium aboneliğiniz aktifleştirildi. Tüm premium özellikler artık kullanımınıza açık.') : 'Premium aboneliğiniz aktifleştirildi. Tüm premium özellikler artık kullanımınıza açık.',
        );
      }
    } catch (e) {
  
        debugPrint('❌ Error handling successful purchase: $e');
      
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
    
  
      debugPrint('❌ Purchase error: ${error.code} - $message');
    
    
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
     
          debugPrint('⚠️ Bazı ürünler bulunamadı: ${response.notFoundIDs}');
        
      }
      
      if (response.productDetails.isNotEmpty) {
        _availableProducts.value = response.productDetails;
        
        // Ürün bilgilerini göster
        for (final product in response.productDetails) {
    
            debugPrint('💰 Price: ${product.price}');
            debugPrint('💱 Currency: ${product.currencyCode}');
            debugPrint('📝 Title: ${product.title}');
            debugPrint('🆔 ID: ${product.id}');
          
        }
      } else {
   
          debugPrint('❌ Hiç ürün yüklenemedi');
        
      }
    } catch (e) {
  
        debugPrint('❌ Ürünler yüklenirken hata: $e');
      
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
          context != null ? (AppLocalizations.of(context.mounted ? context : Get.context!)?.subscriptionCheckTitle ?? 'Kontrol Tamamlandı') : 'Kontrol Tamamlandı',
          context != null ? (AppLocalizations.of(context.mounted ? context : Get.context!)?.subscriptionCheckActiveMessage ?? 'Premium durumunuz güncellendi: Aktif ✨') : 'Premium durumunuz güncellendi: Aktif ✨',
        );
      } else {
        IslamicSnackbar.showInfo(
          context != null ? (AppLocalizations.of(context.mounted ? context : Get.context!)?.subscriptionCheckTitle ?? 'Kontrol Tamamlandı') : 'Kontrol Tamamlandı',
          context != null ? (AppLocalizations.of(context.mounted ? context : Get.context!)?.subscriptionCheckInactiveMessage ?? 'Premium durumunuz güncellendi: Pasif') : 'Premium durumunuz güncellendi: Pasif',
        );
      }
    } catch (e) {
      IslamicSnackbar.showError(
        context != null ? (AppLocalizations.of(context.mounted ? context : Get.context!)?.purchaseErrorTitle ?? 'Hata') : 'Hata',
        context != null ? (AppLocalizations.of(context.mounted ? context : Get.context!)?.subscriptionCheckErrorMessage ?? 'Premium durumu kontrol edilirken hata oluştu. Lütfen daha sonra tekrar deneyin.') : 'Premium durumu kontrol edilirken hata oluştu. Lütfen daha sonra tekrar deneyin.',
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
      
    
        debugPrint('🛒 Purchasing product: ${product.id}');
      
      
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      bool success = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      
     
        debugPrint('🛒 Purchase initiated: $success');
      
      
      return success;
    } catch (e) {
    
        debugPrint('❌ Error purchasing subscription: $e');
      
      final context = Get.context;
      IslamicSnackbar.showError(
        context != null ? (AppLocalizations.of(context.mounted ? context : Get.context!)?.purchaseErrorTitle ?? 'Hata') : 'Hata',
        context != null ? (AppLocalizations.of(context.mounted ? context : Get.context!)?.purchaseNetworkErrorMessage ?? 'Satın alma işleminde hata oluştu. Lütfen internet bağlantınızı kontrol edin ve tekrar deneyin.') : 'Satın alma işleminde hata oluştu. Lütfen internet bağlantınızı kontrol edin ve tekrar deneyin.',
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
    
        debugPrint('❌ Error restoring purchases: $e');
      
    }
  }

  Future<void> restorePurchases() async {
    try {
      _isLoading.value = true;
      await _restorePurchases();
      
      final context = Get.context;
      IslamicSnackbar.showSuccess(
        context != null ? (AppLocalizations.of(context.mounted ? context : Get.context!)?.restorePurchaseSuccessTitle ?? 'Başarılı') : 'Başarılı',
        context != null ? (AppLocalizations.of(context.mounted ? context : Get.context!)?.restorePurchaseSuccessMessage ?? 'Satın alımlar geri yüklendi. Premium özellikleriniz kontrol ediliyor...') : 'Satın alımlar geri yüklendi. Premium özellikleriniz kontrol ediliyor...',
      );
    } catch (e) {
      final context = Get.context;
      IslamicSnackbar.showError(
        context != null ? (AppLocalizations.of(context.mounted ? context : Get.context!)?.restorePurchaseErrorTitle ?? 'Hata') : 'Hata',
        context != null ? (AppLocalizations.of(context.mounted ? context : Get.context!)?.restorePurchaseErrorMessage ?? 'Satın alımlar geri yüklenirken hata oluştu. Lütfen internet bağlantınızı kontrol edin.') : 'Satın alımlar geri yüklenirken hata oluştu. Lütfen internet bağlantınızı kontrol edin.',
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

  // ✅ Tüm widget'ları güncelle - Premium durumu değiştiğinde çağrılır
  Future<void> _updateAllWidgets() async {
    try {
      const platform = MethodChannel('com.skyforgestudios.tasbeepro/widget');
      await platform.invokeMethod('updateAllWidgets');
      
      if (kDebugMode) {
        debugPrint('🔄 All widgets updated after premium status change');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error updating widgets: $e');
      }
      // Widget güncellemesi başarısız olsa bile uygulama çalışmaya devam etsin
    }
  }
}