import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../l10n/app_localizations.dart';
import '../models/subscription_plan.dart';
import '../services/subscription_service.dart';
import 'home_screen.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key, this.fromFirstLaunch = false});

  final bool fromFirstLaunch;

  // İslami renk paleti
  static const emeraldGreen = Color(0xFF2D5016);
  static const goldColor = Color(0xFFD4AF37);
  static const lightGold = Color(0xFFF5E6A8);
  static const darkGreen = Color(0xFF1A3409);

  Future<void> _handlePurchase(
    SubscriptionService controller,
    SubscriptionPlan plan,
  ) async {
    try {
      debugPrint('🛒 Premium Screen: Purchase initiated for plan: ${plan.name}');
      
      // Önceki premium durumunu kaydet
      final wasPremium = controller.isPremium.value;
      debugPrint('🛒 Premium Screen: Was premium before: $wasPremium');

      // Satın alma işlemini başlat
      debugPrint('🛒 Premium Screen: Calling controller.purchaseSubscription...');
      final success = await controller.purchaseSubscription(plan);
      debugPrint('🛒 Premium Screen: Purchase result: $success');

      if (success) {
        // Satın alma başlatıldıysa, premium durumunu dinle
        debugPrint('🛒 Premium Screen: Starting to listen for success...');
        _startListeningForSuccess(controller, wasPremium);
      } else {
        debugPrint('❌ Premium Screen: Purchase failed or was cancelled');
      }
    } catch (e) {
      debugPrint('❌ Premium Screen: Error in _handlePurchase: $e');
    }
  }

  void _startListeningForSuccess(
    SubscriptionService controller,
    bool wasPremium,
  ) {
    debugPrint('🔄 Premium Screen: Started listening for purchase success...');
    // 5 saniye boyunca premium durumunu kontrol et
    int checkCount = 0;
    const maxChecks = 25; // 5 saniye (200ms * 25)

    void checkPremiumStatus() {
      checkCount++;
      debugPrint('🔄 Premium Screen: Check $checkCount/$maxChecks - Premium status: ${controller.isPremium.value}');

      // Eğer premium aktif olduysa ve önceden premium değildiyse
      if (!wasPremium && controller.isPremium.value) {
        debugPrint('🎉 Premium Screen: Purchase successful! Premium activated.');
        if (fromFirstLaunch) {
          // First launch'tan geldiyse ana sayfaya yönlendir
          debugPrint('🏠 Premium Screen: Redirecting to home screen...');
          Future.delayed(const Duration(seconds: 1), () {
            Get.offAll(() => const HomeScreen());
          });
        }
        return; // Başarılı oldu, kontrol etmeyi durdur
      }

      // Maksimum kontrol sayısına ulaşmadıysak devam et
      if (checkCount < maxChecks) {
        Future.delayed(const Duration(milliseconds: 200), checkPremiumStatus);
      } else {
        debugPrint('⏰ Premium Screen: Stopped listening after $maxChecks checks');
      }
    }

    // İlk kontrolü başlat
    Future.delayed(const Duration(milliseconds: 500), checkPremiumStatus);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SubscriptionService>();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF1A3409),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1A3409), // Dark green
                Color(0xFF2D5016), // Emerald green
                Color(0xFF2D5016), // Emerald green
                Color(0xFF1A3409), // Dark green
              ],
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,

                  systemOverlayStyle: SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: Brightness.light,
                    systemNavigationBarColor: Color(0xFF1A3409),
                    systemNavigationBarIconBrightness: Brightness.light,
                  ),

                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => controller.restorePurchases(),
                      child: Text(
                        AppLocalizations.of(context)?.premiumRestorePurchases ?? 'Geri Yükle',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                  flexibleSpace: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF1A3409), // Dark green
                          Color(0xFF2D5016), // Emerald green
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Header - İslami desen
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [goldColor, lightGold],
                              center: Alignment.topLeft,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: goldColor.withAlpha(77),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            size: 50,
                            color: emeraldGreen,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)?.premiumTitle ?? 'Premium\'a Geçin',
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)?.premiumSubtitle ?? 'Tam dijital tesbih deneyimi',
                          style: const TextStyle(fontSize: 16, color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),

                        // Trial info removed since we don't have active trials in this simple version
                        const SizedBox(height: 32),

                        // Features
                        _buildFeaturesList(context),

                        const SizedBox(height: 10),

                        // Pricing plans
                        _buildPricingPlans(context, controller),

                        const SizedBox(height: 24),

                        // Terms
                        Text(
                          AppLocalizations.of(context)?.premiumTerms ?? 'Abonelik otomatik olarak yenilenecektir. İstediğiniz zaman iptal edebilirsiniz.',
                          style: const TextStyle(fontSize: 12, color: Colors.white54),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesList(BuildContext context) {
    final features = [
      {
        'icon': Icons.block,
        'title': AppLocalizations.of(context)?.premiumFeatureAdFreeTitle ?? 'Reklamsız Deneyim',
        'description': AppLocalizations.of(context)?.premiumFeatureAdFreeDescription ?? 'Kesintisiz zikir deneyimi',
      },
      {
        'icon': Icons.notifications_active,
        'title': AppLocalizations.of(context)?.premiumFeatureRemindersTitle ?? 'Hatırlatıcılar',
        'description': AppLocalizations.of(context)?.premiumFeatureRemindersDescription ?? 'Özelleştirilebilir zikir hatırlatıcıları',
      },
      {
        'icon': Icons.widgets,
        'title': AppLocalizations.of(context)?.premiumFeatureWidgetTitle ?? 'Ana Ekran Widget\'ı',
        'description': AppLocalizations.of(context)?.premiumFeatureWidgetDescription ?? 'Android ana ekranında zikir sayacı',
      },
    ];

    return Column(
      children: features
          .map(
            (feature) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: lightGold.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: goldColor.withAlpha(77), width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [goldColor, lightGold],
                        center: Alignment.topLeft,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: goldColor.withAlpha(77),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      feature['icon'] as IconData,
                      color: emeraldGreen,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feature['title'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          feature['description'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildPricingPlans(BuildContext context, SubscriptionService controller) {
    final products = controller.availableProducts;

    return Column(
      children: [
        // Yearly plan (recommended)
        _buildPricingCard(
          context,
          controller,
          SubscriptionPlan.yearly,
          products.firstWhereOrNull(
            (p) => p.id == SubscriptionPlan.yearly.productId,
          ),
          isRecommended: true,
        ),
        const SizedBox(height: 16),

        // Monthly plan
        _buildPricingCard(
          context,
          controller,
          SubscriptionPlan.monthly,
          products.firstWhereOrNull(
            (p) => p.id == SubscriptionPlan.monthly.productId,
          ),
        ),
      ],
    );
  }

  Widget _buildPricingCard(
    BuildContext context,
    SubscriptionService controller,
    SubscriptionPlan plan,
    ProductDetails? product, {
    bool isRecommended = false,
  }) {
    return GestureDetector(
      onTap: product != null ? () => _handlePurchase(controller, plan) : null,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: isRecommended
              ? const LinearGradient(
                  colors: [goldColor, lightGold],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isRecommended ? null : lightGold.withAlpha(25),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRecommended ? goldColor : goldColor.withAlpha(77),
            width: isRecommended ? 2 : 1,
          ),
          boxShadow: isRecommended
              ? [
                  BoxShadow(
                    color: goldColor.withAlpha(77),
                    blurRadius: 15,
                    spreadRadius: 3,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  plan.displayName(context),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isRecommended ? emeraldGreen : Colors.white,
                  ),
                ),
                if (isRecommended)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: emeraldGreen,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: emeraldGreen.withAlpha(77),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Text(
                      AppLocalizations.of(context)?.premiumRecommended ?? 'ÖNERİLEN',
                      style: const TextStyle(
                        color: goldColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            if (product != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    product
                        .price, // Otomatik lokalize edilmiş fiyat (örn: 19.90 TL, $0.99, 4.99 SAR)
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isRecommended ? emeraldGreen : Colors.white,
                    ),
                  ),
                  Text(
                    plan == SubscriptionPlan.yearly 
                        ? (AppLocalizations.of(context)?.premiumPerYear ?? '/yıl')
                        : (AppLocalizations.of(context)?.premiumPerMonth ?? '/ay'),
                    style: TextStyle(
                      fontSize: 16,
                      color: isRecommended
                          ? emeraldGreen.withAlpha(179)
                          : Colors.white70,
                    ),
                  ),
                ],
              ),

              if (plan == SubscriptionPlan.yearly) ...[
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)?.premiumTwoMonthsFree ?? '2 ay ücretsiz',
                  style: TextStyle(
                    fontSize: 14,
                    color: isRecommended ? emeraldGreen : goldColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ] else ...[
              Text(
                AppLocalizations.of(context)?.premiumPriceLoading ?? 'Fiyat yükleniyor...',
                style: TextStyle(
                  fontSize: 14,
                  color: isRecommended
                      ? emeraldGreen.withAlpha(179)
                      : Colors.white70,
                ),
              ),
            ],

            const SizedBox(height: 12),
            Text(
              plan.description(context),
              style: TextStyle(
                fontSize: 14,
                color: isRecommended
                    ? emeraldGreen.withAlpha(204)
                    : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
