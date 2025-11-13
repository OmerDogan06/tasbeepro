import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:tasbeepro/widgets/islamic_snackbar.dart';
import '../l10n/app_localizations.dart';
import '../models/subscription_plan.dart';
import '../services/subscription_service.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key, this.fromFirstLaunch = false});

  final bool fromFirstLaunch;

  // İslami renk paleti
  static const emeraldGreen = Color(0xFF2D5016);
  static const goldColor = Color(0xFFD4AF37);
  static const lightGold = Color(0xFFF5E6A8);
  static const darkGreen = Color(0xFF1A3409);
  

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  @override
  void initState() {
    if (widget.fromFirstLaunch) {
      final controller = Get.find<SubscriptionService>();
      controller.fromFirstLaunchX = true;
      controller.fromPremiumScreenX = true;
    } else {
      final controller = Get.find<SubscriptionService>();
      controller.fromFirstLaunchX = false;
      controller.fromPremiumScreenX = true;
    }
    super.initState();
  }

  Future<void> _handlePurchase(
    SubscriptionService controller,
    SubscriptionPlan plan,
  ) async {
    try {
      debugPrint(
        '🛒 Premium Screen: Purchase initiated for plan: ${plan.name}',
      );

      // Önceki premium durumunu kaydet
      final wasPremium = controller.isPremium.value;
      debugPrint('🛒 Premium Screen: Was premium before: $wasPremium');

      // Satın alma işlemini başlat
      debugPrint(
        '🛒 Premium Screen: Calling controller.purchaseSubscription...',
      );
      final success = await controller.purchaseSubscription(plan);
      debugPrint('🛒 Premium Screen: Purchase result: $success');
    } catch (e) {
      debugPrint('❌ Premium Screen: Error in _handlePurchase: $e');
    }
  }

  @override
  void dispose() {
    final controller = Get.find<SubscriptionService>();
    controller.fromFirstLaunchX = false;
    controller.fromPremiumScreenX = false;
    super.dispose();
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
                        AppLocalizations.of(context)?.premiumRestorePurchases ??
                            'Geri Yükle',
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
                              colors: [
                                PremiumScreen.goldColor,
                                PremiumScreen.lightGold,
                              ],
                              center: Alignment.topLeft,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: PremiumScreen.goldColor.withAlpha(77),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            size: 50,
                            color: PremiumScreen.emeraldGreen,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)?.premiumTitle ??
                              'Premium\'a Geçin',
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)?.premiumSubtitle ??
                              'Tam dijital tesbih deneyimi',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
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

                        // Promosyon kodları
                        _buildPromotionCodesSection(context),

                        const SizedBox(height: 24),

                        // Terms
                        Text(
                          AppLocalizations.of(context)?.premiumTerms ??
                              'Abonelik otomatik olarak yenilenecektir. İstediğiniz zaman iptal edebilirsiniz.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white54,
                          ),
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
        'title':
            AppLocalizations.of(context)?.premiumFeatureAdFreeTitle ??
            'Reklamsız Deneyim',
        'description':
            AppLocalizations.of(context)?.premiumFeatureAdFreeDescription ??
            'Kesintisiz zikir deneyimi',
      },
      {
        'icon': Icons.notifications_active,
        'title':
            AppLocalizations.of(context)?.premiumFeatureRemindersTitle ??
            'Hatırlatıcılar',
        'description':
            AppLocalizations.of(context)?.premiumFeatureRemindersDescription ??
            'Özelleştirilebilir zikir hatırlatıcıları',
      },
      {
        'icon': Icons.widgets,
        'title':
            AppLocalizations.of(context)?.premiumFeatureWidgetTitle ??
            'Ana Ekran Widget\'ı',
        'description':
            AppLocalizations.of(context)?.premiumFeatureWidgetDescription ??
            'Android ana ekranında zikir sayacı',
      },
      {
        'icon': Icons.menu_book,
        'title':
            AppLocalizations.of(context)?.premiumFeatureQuranWidgetTitle ??
            'Kur\'an Ana Ekran Widget\'ı',
        'description':
            AppLocalizations.of(context)?.premiumFeatureQuranWidgetDescription ??
            'Ana ekranınızdan doğrudan Kur\'an okuyun',
      },
    ];

    return Column(
      children: features
          .map(
            (feature) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: PremiumScreen.lightGold.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: PremiumScreen.goldColor.withAlpha(77),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          PremiumScreen.goldColor,
                          PremiumScreen.lightGold,
                        ],
                        center: Alignment.topLeft,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: PremiumScreen.goldColor.withAlpha(77),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      feature['icon'] as IconData,
                      color: PremiumScreen.emeraldGreen,
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

  Widget _buildPricingPlans(
    BuildContext context,
    SubscriptionService controller,
  ) {
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
                  colors: [PremiumScreen.goldColor, PremiumScreen.lightGold],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isRecommended ? null : PremiumScreen.lightGold.withAlpha(25),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRecommended
                ? PremiumScreen.goldColor
                : PremiumScreen.goldColor.withAlpha(77),
            width: isRecommended ? 2 : 1,
          ),
          boxShadow: isRecommended
              ? [
                  BoxShadow(
                    color: PremiumScreen.goldColor.withAlpha(77),
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
                    color: isRecommended
                        ? PremiumScreen.emeraldGreen
                        : Colors.white,
                  ),
                ),
                if (isRecommended)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: PremiumScreen.emeraldGreen,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: PremiumScreen.emeraldGreen.withAlpha(77),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Text(
                      AppLocalizations.of(context)?.premiumRecommended ??
                          'ÖNERİLEN',
                      style: const TextStyle(
                        color: PremiumScreen.goldColor,
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
                      color: isRecommended
                          ? PremiumScreen.emeraldGreen
                          : Colors.white,
                    ),
                  ),
                  Text(
                    plan == SubscriptionPlan.yearly
                        ? (AppLocalizations.of(context)?.premiumPerYear ??
                              '/yıl')
                        : (AppLocalizations.of(context)?.premiumPerMonth ??
                              '/ay'),
                    style: TextStyle(
                      fontSize: 16,
                      color: isRecommended
                          ? PremiumScreen.emeraldGreen.withAlpha(179)
                          : Colors.white70,
                    ),
                  ),
                ],
              ),

              if (plan == SubscriptionPlan.yearly) ...[
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)?.premiumTwoMonthsFree ??
                      '2 ay ücretsiz',
                  style: TextStyle(
                    fontSize: 14,
                    color: isRecommended
                        ? PremiumScreen.emeraldGreen
                        : PremiumScreen.goldColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ] else ...[
              Text(
                AppLocalizations.of(context)?.premiumPriceLoading ??
                    'Fiyat yükleniyor...',
                style: TextStyle(
                  fontSize: 14,
                  color: isRecommended
                      ? PremiumScreen.emeraldGreen.withAlpha(179)
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
                    ? PremiumScreen.emeraldGreen.withAlpha(204)
                    : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionCodesSection(BuildContext context) {
       const emeraldGreen = Color(0xFF2D5016);
   const goldColor = Color(0xFFD4AF37);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A3409).withAlpha(77),
            emeraldGreen.withAlpha(51),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: goldColor.withAlpha(102), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: goldColor.withAlpha(25),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.local_offer, color: goldColor, size: 22),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)?.premiumPromotionCodes ??
                    'Özel Promosyon Kodları',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 2,
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Aylık abonelik promosyon kodu
          _buildPromotionCodeCard(
            context,
            'TasbeePro',
            AppLocalizations.of(context)?.premiumSevenDayTrial ??
                '7 Gün Ücretsiz Deneme',
            AppLocalizations.of(context)?.premiumMonthlySubscription ??
                'Aylık Abonelik',
            Icons.calendar_view_week,
            Colors.blue,
          ),

          const SizedBox(height: 12),

          // Yıllık abonelik promosyon kodu
          _buildPromotionCodeCard(
            context,
            'TasbeeProYearly',
            AppLocalizations.of(context)?.premiumFourteenDayTrial ??
                '14 Gün Ücretsiz Deneme',
            AppLocalizations.of(context)?.premiumYearlySubscription ??
                'Yıllık Abonelik',
            Icons.calendar_month,
            goldColor,
            isRecommended: true,
          ),

          const SizedBox(height: 12),

          Text(
            '💡 ${AppLocalizations.of(context)?.premiumPromotionCodeInfo ?? 'Bu kodları abonelik satın alırken kullanarak ücretsiz deneme süresinden yararlanabilirsiniz'}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withAlpha(204),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }


   Widget _buildPromotionCodeCard(
    BuildContext context,
    String code,
    String trialPeriod,
    String planType,
    IconData icon,
    Color accentColor, {
    bool isRecommended = false,
  }) {
         const emeraldGreen = Color(0xFF2D5016);
   const goldColor = Color(0xFFD4AF37);
    return GestureDetector(
      onTap: () => _copyPromotionCode(code),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isRecommended
              ? goldColor.withAlpha(25)
              : Colors.white.withAlpha(13),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRecommended ? goldColor : accentColor,
            width: isRecommended ? 2 : 1,
          ),
          boxShadow: isRecommended
              ? [
                  BoxShadow(
                    color: goldColor.withAlpha(51),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: accentColor.withAlpha(51),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: accentColor, width: 1),
              ),
              child: Icon(icon, color: accentColor, size: 20),
            ),

            const SizedBox(width: 5),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          code,
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isRecommended ? goldColor : Colors.white,
                            letterSpacing: 1,
                            
                          ),
                        ),
                      ),
                      if (isRecommended) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: goldColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child:  Text(
                            AppLocalizations.of(context)?.firstLaunchIntroRecommended ?? 'ÖNERİLEN',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: emeraldGreen,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$trialPeriod • $planType',
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 12,
                      color: isRecommended
                          ? Colors.white.withAlpha(230)
                          : Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.copy,
              color: isRecommended ? goldColor : Colors.white70,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _copyPromotionCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    
   IslamicSnackbar.showInfo(
      AppLocalizations.of(context)?.premiumCodeCopied ?? '📋 Kod Kopyalandı',
      AppLocalizations.of(Get.context!)?.premiumCodeCopiedMessage(code) ?? 'Promosyon kodu "$code" panoya kopyalandı',
    
      duration: const Duration(seconds: 3),
     
    );
  }
}
