// import 'dart:async';
// import 'package:get/get.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';
// import 'package:in_app_purchase_android/in_app_purchase_android.dart';
// import 'package:tasbeepro/screens/premium_screen.dart';
// import '../models/subscription_plan.dart';
// import 'storage_service.dart';

// class SubscriptionService extends GetxController {
//   static SubscriptionService get to => Get.find();
  
//   final InAppPurchase _inAppPurchase = InAppPurchase.instance;
//   late StreamSubscription<List<PurchaseDetails>> _subscription;
  
//   final _subscriptionStatus = SubscriptionStatus.defaultFree.obs;
//   final _availableProducts = <ProductDetails>[].obs;
//   final _isLoading = false.obs;
  
//   // Product IDs - Google Play Console'da tanımlanmış
//   // Test için önce sadece product ID'leri deneyelim
//   static const String monthlyPremiumId = 'tasbee_pro_premium_monthly';
//   static const String yearlyPremiumId = 'tasbee_pro_premium_yearly';
  
//   static const Set<String> productIds = {
//     monthlyPremiumId,
//     yearlyPremiumId,
//   };

//   SubscriptionStatus get subscriptionStatus => _subscriptionStatus.value;
//   List<ProductDetails> get availableProducts => _availableProducts;
//   bool get isLoading => _isLoading.value;
  
//   // Premium özelliklere erişim kontrolü
//   bool get isAdFreeEnabled => _subscriptionStatus.value.hasFeature(PremiumFeature.adFree);
//   bool get areRemindersEnabled => _subscriptionStatus.value.hasFeature(PremiumFeature.reminders);
//   bool get isWidgetEnabled => _subscriptionStatus.value.hasFeature(PremiumFeature.androidWidget);
//   bool get isPremium => _subscriptionStatus.value.isPremium;
//   // Google Play deneme süresi sadece isPremium ile kontrol edilir
//   bool get isTrialActive => false; // Artık kendi deneme süremiz yok

//   @override
//   Future<void> onInit() async {
//     super.onInit();
//     await _initializePurchases();
//     await _loadSubscriptionStatus();
//     _startListeningToPurchaseUpdates();
//   }

//   @override
//   void onClose() {
//     _subscription.cancel();
//     super.onClose();
//   }

//   Future<void> _initializePurchases() async {
//     final bool available = await _inAppPurchase.isAvailable();
    
//     if (!available) {
//       Get.snackbar(
//         'Hata',
//         'In-app purchase servisi kullanılamıyor. Lütfen Google Play Store\'un güncel olduğundan emin olun.',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       return;
//     }

//     await _loadProducts();
//   }

//   Future<void> _loadProducts() async {
//     try {
//       _isLoading.value = true;

      
//       final ProductDetailsResponse response = 
//           await _inAppPurchase.queryProductDetails(productIds);
          

      
//       if (response.notFoundIDs.isNotEmpty) {
//         Get.snackbar(
//           'Ürün Bulunamadı',
//           'Bazı ürünler yüklenemedi. Lütfen daha sonra tekrar deneyin.',
//           snackPosition: SnackPosition.BOTTOM,
//           duration: Duration(seconds: 3),
//         );
//       }
      
//       if (response.productDetails.isNotEmpty) {
//         _availableProducts.value = response.productDetails;
        
//         // Ürün bilgilerini göster
//         for (final product in response.productDetails) {
//           print('💰 Price: ${product.price}');
//           print('💱 Currency: ${product.currencyCode}');
//           print('📝 Title: ${product.title}');
//           print('📄 Description: ${product.description}');
//         }
//       } else {
//         Get.snackbar(
//           'Hata',
//           'Ürünler yüklenemedi. Lütfen internet bağlantınızı kontrol edin.',
//           snackPosition: SnackPosition.BOTTOM,
//         );
//       }
//     } catch (e) {
//       Get.snackbar(
//         'Hata',
//         'Ürünler yüklenirken hata oluştu.',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     } finally {
//       _isLoading.value = false;
//     }
//   }

//   Future<void> _loadSubscriptionStatus() async {
//     try {
//       final storedStatus = await StorageService.to.getSubscriptionStatus();
//       if (storedStatus != null) {
//         _subscriptionStatus.value = storedStatus;
//       } else {
//         // İlk açılış - sadece ücretsiz plan
//         _subscriptionStatus.value = SubscriptionStatus.defaultFree;
//         await StorageService.to.saveSubscriptionStatus(_subscriptionStatus.value);
//       }
      
//       // Aktif satın alımları kontrol et
//       await _restorePurchases();
//     } catch (e) {
//       print('Error loading subscription status: $e');
//     }
//   }



//   void _startListeningToPurchaseUpdates() {
//     _subscription = _inAppPurchase.purchaseStream.listen(
//       (List<PurchaseDetails> purchaseDetailsList) {
//         _handlePurchaseUpdates(purchaseDetailsList);
//       },
//       onDone: () {
//         print('Purchase stream closed');
//       },
//       onError: (error) {
//         print('Purchase stream error: $error');
//       },
//     );
//   }

//   Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) async {
//     for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
//       if (purchaseDetails.status == PurchaseStatus.pending) {
//         // Satın alma beklemede
//         _showPendingUI();
//       } else {
//         if (purchaseDetails.status == PurchaseStatus.error) {
//           // Hata durumu
//           _handleError(purchaseDetails.error!);
//         } else if (purchaseDetails.status == PurchaseStatus.purchased ||
//                    purchaseDetails.status == PurchaseStatus.restored) {
//           // Başarılı satın alma
//           await _handleSuccessfulPurchase(purchaseDetails);
//         }
        
//         if (purchaseDetails.pendingCompletePurchase) {
//           await _inAppPurchase.completePurchase(purchaseDetails);
//         }
//       }
//     }
//   }

//   Future<void> _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) async {
//     try {
//       final String productId = purchaseDetails.productID;
//       final SubscriptionPlan plan = _getSubscriptionPlanFromProductId(productId);
      
//       final now = DateTime.now();
//       final subscriptionStatus = _subscriptionStatus.value.copyWith(
//         currentPlan: plan,
//         subscriptionStartDate: now,
//         subscriptionEndDate: now.add(plan.duration),
//         isTrialPeriod: false,
//         trialEndDate: null,
//         isActive: true,
//         availableFeatures: _getAllPremiumFeatures(),
//       );
      
//       _subscriptionStatus.value = subscriptionStatus;
//       await StorageService.to.saveSubscriptionStatus(subscriptionStatus);
      
//       Get.snackbar(
//         'Başarılı!',
//         'Premium aboneliğiniz aktifleştirildi.',
//         snackPosition: SnackPosition.BOTTOM,
//       );
      
//     } catch (e) {
//       print('Error handling successful purchase: $e');
//     }
//   }

//   List<PremiumFeature> _getAllPremiumFeatures() {
//     return [
//       PremiumFeature.adFree,
//       PremiumFeature.reminders,
//       PremiumFeature.androidWidget,
//     ];
//   }

//   SubscriptionPlan _getSubscriptionPlanFromProductId(String productId) {
//     switch (productId) {
//       case monthlyPremiumId:
//         return SubscriptionPlan.monthly;
//       case yearlyPremiumId:
//         return SubscriptionPlan.yearly;
//       default:
//         return SubscriptionPlan.free;
//     }
//   }

//   void _showPendingUI() {
//     Get.snackbar(
//       'Satın alma işlemi',
//       'Satın alma işlemi devam ediyor...',
//       snackPosition: SnackPosition.BOTTOM,
//     );
//   }

//   void _handleError(IAPError error) {
//     String message = 'Satın alma işleminde hata oluştu.';
    
//     switch (error.code) {
//       case 'user_cancelled':
//         message = 'Satın alma işlemi iptal edildi.';
//         break;
//       case 'payment_invalid':
//         message = 'Ödeme bilgileri geçersiz.';
//         break;
//       case 'product_not_available':
//         message = 'Ürün mevcut değil.';
//         break;
//     }
    
//     Get.snackbar(
//       'Hata',
//       message,
//       snackPosition: SnackPosition.BOTTOM,
//     );
//   }

//   Future<bool> purchaseSubscription(SubscriptionPlan plan) async {
//     if (plan == SubscriptionPlan.free) return false;
    
//     try {
//       _isLoading.value = true;
      
//       final ProductDetails? product = _availableProducts.firstWhereOrNull(
//         (p) => p.id == plan.productId,
//       );
      
//       if (product == null) {
//         Get.snackbar(
//           'Hata',
//           'Ürün bulunamadı.',
//           snackPosition: SnackPosition.BOTTOM,
//         );
//         return false;
//       }
      
//       final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
//       bool success = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
//       return success;
//     } catch (e) {
//       print('Error purchasing subscription: $e');
//       Get.snackbar(
//         'Hata',
//         'Satın alma işleminde hata oluştu.',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       return false;
//     } finally {
//       _isLoading.value = false;
//     }
//   }

//   Future<void> _restorePurchases() async {
//     try {
//       await _inAppPurchase.restorePurchases();
//     } catch (e) {
//       print('Error restoring purchases: $e');
//     }
//   }

//   Future<void> restorePurchases() async {
//     try {
//       _isLoading.value = true;
//       await _restorePurchases();
      
//       Get.snackbar(
//         'Bilgi',
//         'Satın alımlar geri yüklendi.',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     } catch (e) {
//       Get.snackbar(
//         'Hata',
//         'Satın alımlar geri yüklenirken hata oluştu.',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     } finally {
//       _isLoading.value = false;
//     }
//   }

//   // Premium özellik kontrolü
//   bool canUseFeature(PremiumFeature feature) {
//     // Premium abonelik varsa (Google Play deneme süresi dahil)
//     if (isPremium && _subscriptionStatus.value.isActive && !_subscriptionStatus.value.isExpired) {
//       return _subscriptionStatus.value.hasFeature(feature);
//     }
    
//     return false;
//   }

//   // Premium özellik kullanmaya çalışırken çağrılacak
//   void showPremiumDialog(PremiumFeature feature) {
//     Get.defaultDialog(
//       title: 'Premium Özellik',
//       middleText: '${feature.displayName} özelliği premium abonelik gerektirir.',
//       textConfirm: 'Premium\'a Geç',
//       textCancel: 'İptal',
//       onConfirm: () {
//         Get.back();
//         // Premium satın alma sayfasına git
//         Get.to(() => PremiumScreen());
//       },
//     );
//   }

//   // Deneme süresi durumu (Google Play tarafından yönetilir)
//   String get trialStatusText {
//     // Google Play deneme süresi varsa, abonelik bitiş tarihi deneme bitiş tarihi olur
//     if (isPremium && _subscriptionStatus.value.subscriptionEndDate != null) {
//       final daysLeft = _subscriptionStatus.value.subscriptionEndDate!
//           .difference(DateTime.now())
//           .inDays;
          
//       if (daysLeft <= 0) return '';
      
//       // İlk 14 gün (yıllık) veya 7 gün (aylık) deneme süresi olarak kabul edilir
//       final totalDays = _subscriptionStatus.value.subscriptionEndDate!
//           .difference(_subscriptionStatus.value.subscriptionStartDate ?? DateTime.now())
//           .inDays;
          
//       if (totalDays <= 14) { // Deneme süresi
//         return 'Deneme süresi: $daysLeft gün kaldı';
//       }
//     }
    
//     return '';
//   }

//   // Abonelik durumu metni
//   String get subscriptionStatusText {
//     if (isPremium) {
//       if (_subscriptionStatus.value.isExpired) {
//         return 'Premium abonelik süresi dolmuş';
//       }
      
//       // Deneme süresi metni varsa onu göster, yoksa normal abonelik
//       final trialText = trialStatusText;
//       if (trialText.isNotEmpty) {
//         return trialText;
//       }
      
//       return '${_subscriptionStatus.value.currentPlan.displayName} aktif';
//     }
    
//     return 'Ücretsiz kullanım';
//   }

// }