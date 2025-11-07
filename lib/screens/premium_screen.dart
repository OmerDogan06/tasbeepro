import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../models/subscription_plan.dart';
import '../services/subscription_service.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SubscriptionService>();
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Get.back(),
              ),
              actions: [
                TextButton(
                  onPressed: () => controller.restorePurchases(),
                  child: const Text(
                    'Geri Yükle',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Header
                    const Icon(
                      Icons.star_rounded,
                      size: 80,
                      color: Colors.amber,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Premium\'a Geçin',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tam dijital tesbih deneyimi',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    // Trial info
                    Obx(() {
                      final trialText = controller.trialStatusText;
                      if (trialText.isNotEmpty && controller.isTrialActive) {
                        return Container(
                          margin: const EdgeInsets.only(top: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.timer, color: Colors.green, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                trialText,
                                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),

                    const SizedBox(height: 32),
                    
                    // Features
                    _buildFeaturesList(),
                    
                    const SizedBox(height: 32),
                    
                    // Pricing plans
                    _buildPricingPlans(controller),
                    
                    const SizedBox(height: 24),
                    
                    // Terms
                    const Text(
                      'Abonelik otomatik olarak yenilenecektir. İstediğiniz zaman iptal edebilirsiniz.',
                      style: TextStyle(
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
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      {
        'icon': Icons.block,
        'title': 'Reklamsız Deneyim',
        'description': 'Kesintisiz zikir deneyimi',
      },
      {
        'icon': Icons.notifications_active,
        'title': 'Hatırlatıcılar',
        'description': 'Özelleştirilebilir zikir hatırlatıcıları',
      },
      {
        'icon': Icons.widgets,
        'title': 'Ana Ekran Widget\'ı',
        'description': 'Android ana ekranında zikir sayacı',
      },
    ];
    
    return Column(
      children: features.map((feature) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                feature['icon'] as IconData,
                color: Colors.black,
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
      )).toList(),
    );
  }

  Widget _buildPricingPlans(SubscriptionService controller) {
    return Obx(() {
      if (controller.isLoading) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.amber),
        );
      }
      
      final products = controller.availableProducts;
      
      return Column(
        children: [
          // Yearly plan (recommended)
          _buildPricingCard(
            controller,
            SubscriptionPlan.yearly,
            products.firstWhereOrNull((p) => p.id == SubscriptionPlan.yearly.productId),
            isRecommended: true,
          ),
          const SizedBox(height: 16),
          
          // Monthly plan
          _buildPricingCard(
            controller,
            SubscriptionPlan.monthly,
            products.firstWhereOrNull((p) => p.id == SubscriptionPlan.monthly.productId),
          ),
        ],
      );
    });
  }

  Widget _buildPricingCard(
    SubscriptionService controller,
    SubscriptionPlan plan,
    ProductDetails? product, {
    bool isRecommended = false,
  }) {
    return GestureDetector(
      onTap: product != null ? () => controller.purchaseSubscription(plan) : null,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isRecommended
              ? const LinearGradient(
                  colors: [Colors.amber, Color(0xFFFFD700)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isRecommended ? null : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRecommended ? Colors.amber : Colors.white.withOpacity(0.3),
            width: isRecommended ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  plan.displayName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isRecommended ? Colors.black : Colors.white,
                  ),
                ),
                if (isRecommended)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'ÖNERİLEN',
                      style: TextStyle(
                        color: Colors.white,
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
                    product.price, // Otomatik lokalize edilmiş fiyat (örn: 19.90 TL, $0.99, 4.99 SAR)
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isRecommended ? Colors.black : Colors.white,
                    ),
                  ),
                  Text(
                    plan == SubscriptionPlan.yearly ? '/yıl' : '/ay',
                    style: TextStyle(
                      fontSize: 16,
                      color: isRecommended ? Colors.black54 : Colors.white70,
                    ),
                  ),
                ],
              ),
              
              if (plan == SubscriptionPlan.yearly) ...[
                const SizedBox(height: 4),
                Text(
                  '2 ay ücretsiz',
                  style: TextStyle(
                    fontSize: 14,
                    color: isRecommended ? Colors.black : Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ] else ...[
              Text(
                'Fiyat yükleniyor...',
                style: TextStyle(
                  fontSize: 16,
                  color: isRecommended ? Colors.black54 : Colors.white70,
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            Text(
              plan.description,
              style: TextStyle(
                fontSize: 14,
                color: isRecommended ? Colors.black87 : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}