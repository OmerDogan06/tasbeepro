import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tasbeepro/widgets/islamic_snackbar.dart';
import 'dart:math' as math;

import 'premium_screen.dart';
import 'home_screen.dart';
import '../services/storage_service.dart';
import '../services/subscription_service.dart';
import '../l10n/app_localizations.dart';

class FirstLaunchPremiumIntroScreen extends StatefulWidget {
  const FirstLaunchPremiumIntroScreen({super.key});

  @override
  State<FirstLaunchPremiumIntroScreen> createState() =>
      _FirstLaunchPremiumIntroScreenState();
}

class _FirstLaunchPremiumIntroScreenState
    extends State<FirstLaunchPremiumIntroScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // İslami renk paleti
  static const emeraldGreen = Color(0xFF2D5016);
  static const goldColor = Color(0xFFD4AF37);

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
        );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Animasyonları sırayla başlat
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            child: Column(
              children: [
                // Header with close button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => _skipToHome(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(25),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: goldColor.withAlpha(77),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white70,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),

                        // Ana logo ve title
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: _buildHeaderSection(),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Premium features
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildFeaturesSection(context),
                        ),

                        const SizedBox(height: 10),

                        // Deneme süresi bilgisi
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildTrialInfoSection(context),
                        ),

                        const SizedBox(height: 0),
                      ],
                    ),
                  ),
                ),

                // Action buttons
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildActionButtons(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      children: [


        const Text(
          'Tasbee Pro',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
            shadows: [
              Shadow(
                color: Colors.black26,
                offset: Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
        ),

        const SizedBox(height: 0),

        Text(
          AppLocalizations.of(context)?.firstLaunchIntroSubtitle ?? 'Premium Dijital Tesbih Deneyimi',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    final features = [
      {
        'icon': Icons.block_outlined,
        'title': AppLocalizations.of(context)?.firstLaunchIntroAdFreeTitle ?? 'Reklamsız Deneyim',
        'description': AppLocalizations.of(context)?.firstLaunchIntroAdFreeDescription ?? 'Kesintisiz zikir ve dua deneyimi yaşayın',
        'color': Colors.red,
      },
      {
        'icon': Icons.notifications_active_outlined,
        'title': AppLocalizations.of(context)?.firstLaunchIntroRemindersTitle ?? 'Akıllı Hatırlatıcılar',
        'description': AppLocalizations.of(context)?.firstLaunchIntroRemindersDescription ?? 'Özelleştirilebilir namaz ve zikir hatırlatıcıları',
        'color': Colors.blue,
      },
      {
        'icon': Icons.widgets_outlined,
        'title': AppLocalizations.of(context)?.firstLaunchIntroWidgetTitle ?? 'Ana Ekran Widget\'ı',
        'description': AppLocalizations.of(context)?.firstLaunchIntroWidgetDescription ?? 'Android ana ekranında hızlı erişim',
        'color': Colors.green,
      },
      {
        'icon': Icons.cloud_sync_outlined,
        'title': AppLocalizations.of(context)?.firstLaunchIntroUnlimitedTitle ?? 'Sınırsız Özellikler',
        'description': AppLocalizations.of(context)?.firstLaunchIntroUnlimitedDescription ?? 'Tüm premium özellikler ve gelecek güncellemeler',
        'color': goldColor,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)?.firstLaunchIntroPremiumFeatures ?? 'Premium Özellikler',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 8),

        ...features.asMap().entries.map((entry) {
          final index = entry.key;
          final feature = entry.value;

          return Container(
            margin: EdgeInsets.only(
              bottom: 10,
              left: index.isEven ? 0 : 20,
              right: index.isOdd ? 0 : 20,
            ),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withAlpha(25),
                  Colors.white.withAlpha(13),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: goldColor.withAlpha(77), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (feature['color'] as Color).withAlpha(51),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: feature['color'] as Color,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    feature['icon'] as IconData,
                    color: feature['color'] as Color,
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
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTrialInfoSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [goldColor.withAlpha(51), goldColor.withAlpha(25)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: goldColor.withAlpha(125), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.timer_outlined, color: goldColor, size: 24),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)?.firstLaunchIntroFreeTrial ?? 'Ücretsiz Deneme Süresi',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _buildTrialOption(
                    context,
                    AppLocalizations.of(context)?.firstLaunchIntroSevenDays ?? '7 Gün',
                    AppLocalizations.of(context)?.firstLaunchIntroMonthlyPlan ?? 'Aylık Abonelik',
                    AppLocalizations.of(context)?.firstLaunchIntroTrialDescription ?? 'İlk 7 gün ücretsiz\nSonra aylık ödeme',
                    Icons.calendar_view_week,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTrialOption(
                    context,
                    AppLocalizations.of(context)?.firstLaunchIntroFourteenDays ?? '14 Gün',
                    AppLocalizations.of(context)?.firstLaunchIntroYearlyPlan ?? 'Yıllık Abonelik',
                    AppLocalizations.of(context)?.firstLaunchIntroYearlyTrialDescription ?? 'İlk 14 gün ücretsiz\nSonra yıllık ödeme',
                    Icons.calendar_month,
                    isRecommended: true,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text(
            AppLocalizations.of(context)?.firstLaunchIntroTrialNote ?? 'Deneme süresinde istediğiniz zaman iptal edebilirsiniz.\nİptal etmezseniz otomatik olarak ücretli abonelik başlar.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withAlpha(204),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Promosyon kodları bölümü
          _buildPromotionCodesSection(context),
        ],
      ),
    );
  }

  Widget _buildTrialOption(
    BuildContext context,
    String days,
    String planName,
    String description,
    IconData icon, {
    bool isRecommended = false,
  }) {
    // Subscription service'ten fiyat bilgilerini al
    final controller = Get.find<SubscriptionService>();
    final products = controller.availableProducts;
    final productId = planName.contains('Yıllık')
        ? 'tasbee_pro_premium_yearly'
        : 'tasbee_pro_premium_monthly';
    final product = products.firstWhereOrNull((p) => p.id == productId);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isRecommended
            ? goldColor.withAlpha(51)
            : Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRecommended ? goldColor : Colors.white.withAlpha(77),
          width: isRecommended ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          if (isRecommended)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: goldColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                AppLocalizations.of(context)?.firstLaunchIntroRecommended ?? 'ÖNERİLEN',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: emeraldGreen,
                ),
              ),
            )
          else
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: emeraldGreen,
                ),
              ),
            ),

          Icon(
            icon,
            color: isRecommended ? goldColor : Colors.white70,
            size: 25,
          ),

          const SizedBox(height: 8),

          Text(
            days,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isRecommended ? goldColor : Colors.white,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            planName,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: isRecommended ? Colors.white : Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 4),

          // Fiyat bilgisi ekle
          if (product != null)
            Text(
              product.price,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isRecommended ? goldColor : Colors.white,
              ),
            )
          else
            Text(
              AppLocalizations.of(context)?.firstLaunchIntroPriceLoading ?? 'Fiyat yükleniyor...',
              style: TextStyle(
                fontSize: 12,
                color: isRecommended
                    ? Colors.white.withAlpha(179)
                    : Colors.white60,
              ),
            ),

          const SizedBox(height: 6),

          // Dinamik açıklama ve ekonomik hesaplama
          _buildDynamicDescription(context, controller, planName, description, isRecommended),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          // Ana premium button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => _goToPremiumScreen(),
              style: ElevatedButton.styleFrom(
                backgroundColor: goldColor,
                foregroundColor: emeraldGreen,
                elevation: 8,
                shadowColor: goldColor.withAlpha(125),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)?.firstLaunchIntroStartPremium ?? 'Premium\'a Başla',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => _skipToHome(),
              style: ElevatedButton.styleFrom(
                backgroundColor: emeraldGreen,
                foregroundColor: Colors.white,
                elevation: 8,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.arrow_forward, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)?.firstLaunchIntroLaterButton ?? 'Daha Sonra',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goToPremiumScreen() {
    // İlk açılış işaretini set et
    final storageService = Get.find<StorageService>();
    storageService.setFirstLaunchCompleted();

    Get.to(
      () => const PremiumScreen(fromFirstLaunch: true),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _skipToHome() {
    // İlk açılış işaretini set et
    final storageService = Get.find<StorageService>();
    storageService.setFirstLaunchCompleted();

    // Ana sayfaya git
    Get.offAll(
      () => const HomeScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 800),
    );
  }

  Widget _buildPromotionCodesSection(BuildContext context) {
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
      AppLocalizations.of(Get.context!)?.premiumCodeCopied ?? '📋 Kod Kopyalandı',
      AppLocalizations.of(Get.context!)?.premiumCodeCopiedMessage(code) ?? 'Promosyon kodu "$code" panoya kopyalandı',
     
      duration: const Duration(seconds: 2),
     
    );
  }

  Widget _buildDynamicDescription(BuildContext context, SubscriptionService controller, String planName, String description, bool isRecommended) {
    final products = controller.availableProducts;
    
    if (planName.contains(AppLocalizations.of(context)?.firstLaunchIntroYearlyPlan ?? 'Yıllık')) {
      // Yıllık plan için ekonomik hesaplama
      final yearlyProduct = products.firstWhereOrNull((p) => p.id == 'tasbee_pro_premium_yearly');
      final monthlyProduct = products.firstWhereOrNull((p) => p.id == 'tasbee_pro_premium_monthly');
      
      if (yearlyProduct != null && monthlyProduct != null) {
        // Fiyatlardan sayısal değerleri çıkar
        final yearlyPrice = _extractPrice(yearlyProduct.price);
        final monthlyPrice = _extractPrice(monthlyProduct.price);
        
        if (yearlyPrice > 0 && monthlyPrice > 0) {
          final monthlyTotal = monthlyPrice * 12; // 12 aylık toplam
          final savings = ((monthlyTotal - yearlyPrice) / monthlyTotal * 100).round();
          
          return Text(
            (AppLocalizations.of(context)?.firstLaunchIntroSavingsText(savings) ?? 'İlk 14 gün ücretsiz\n$savings% daha ekonomik'),
            style: TextStyle(
              fontSize: 10,
              color: isRecommended ? Colors.white.withAlpha(230) : Colors.white60,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          );
        }
      }
    }
    
    // Varsayılan açıklama
    final isYearly = planName.contains(AppLocalizations.of(context)?.firstLaunchIntroYearlyPlan ?? 'Yıllık');
    final defaultText = 'İlk ${isYearly ? '14' : '7'} gün ücretsiz\nSonra ${isYearly ? 'yıllık' : 'aylık'} ödeme';
    
    return Text(
      description.isNotEmpty ? description : defaultText,
      style: TextStyle(
        fontSize: 10,
        color: isRecommended ? Colors.white.withAlpha(230) : Colors.white60,
        height: 1.2,
      ),
      textAlign: TextAlign.center,
    );
  }

  double _extractPrice(String priceString) {
    // Fiyat string'inden sayısal değeri çıkar (örn: "19,90 TL" -> 19.90)
    final regex = RegExp(r'[\d,\.]+');
    final match = regex.firstMatch(priceString);
    if (match != null) {
      final numberString = match.group(0)!.replaceAll(',', '.');
      return double.tryParse(numberString) ?? 0.0;
    }
    return 0.0;
  }
}

// İslami desen painter
class IslamicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2D5016).withAlpha(77)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Geometrik İslami desen
    for (int i = 0; i < 8; i++) {
      final angle = (i * 2 * math.pi) / 8;
      final x = center.dx + (radius * 0.7) * math.cos(angle);
      final y = center.dy + (radius * 0.7) * math.sin(angle);

      canvas.drawCircle(Offset(x, y), radius * 0.15, paint);
    }

    // Merkez daire
    canvas.drawCircle(center, radius * 0.3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
