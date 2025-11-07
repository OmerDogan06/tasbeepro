enum SubscriptionPlan {
  free('free'),
  monthly('tasbee_pro_premium_monthly'),
  yearly('tasbee_pro_premium_yearly');

  const SubscriptionPlan(this.productId);
  
  final String productId;

  String get displayName {
    switch (this) {
      case SubscriptionPlan.free:
        return 'Ücretsiz';
      case SubscriptionPlan.monthly:
        return 'Aylık Premium';
      case SubscriptionPlan.yearly:
        return 'Yıllık Premium';
    }
  }

  String get description {
    switch (this) {
      case SubscriptionPlan.free:
        return 'Temel özellikler (reklamlı)';
      case SubscriptionPlan.monthly:
        return 'Tüm premium özellikler - Aylık';
      case SubscriptionPlan.yearly:
        return 'Tüm premium özellikler - Yıllık (2 ay ücretsiz)';
    }
  }

  Duration get duration {
    switch (this) {
      case SubscriptionPlan.free:
        return Duration.zero;
      case SubscriptionPlan.monthly:
        return const Duration(days: 30);
      case SubscriptionPlan.yearly:
        return const Duration(days: 365);
    }
  }
}

enum PremiumFeature {
  adFree('ad_free'),
  reminders('reminders'),
  androidWidget('android_widget');

  const PremiumFeature(this.key);
  
  final String key;

  String get displayName {
    switch (this) {
      case PremiumFeature.adFree:
        return 'Reklamsız Deneyim';
      case PremiumFeature.reminders:
        return 'Hatırlatıcılar';
      case PremiumFeature.androidWidget:
        return 'Ana Ekran Widget\'ı';
    }
  }

  String get description {
    switch (this) {
      case PremiumFeature.adFree:
        return 'Uygulamayı reklamsız kullanın';
      case PremiumFeature.reminders:
        return 'Zikir hatırlatıcıları ayarlayın';
      case PremiumFeature.androidWidget:
        return 'Ana ekranda zikir widget\'ı kullanın';
    }
  }
}

class SubscriptionStatus {
  final SubscriptionPlan currentPlan;
  final DateTime? subscriptionStartDate;
  final DateTime? subscriptionEndDate;
  final bool isTrialPeriod;
  final DateTime? trialEndDate;
  final bool isActive;
  final List<PremiumFeature> availableFeatures;

  const SubscriptionStatus({
    required this.currentPlan,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    this.isTrialPeriod = false,
    this.trialEndDate,
    required this.isActive,
    required this.availableFeatures,
  });

  bool hasFeature(PremiumFeature feature) {
    return availableFeatures.contains(feature);
  }

  bool get isPremium => currentPlan != SubscriptionPlan.free;

  bool get isExpired {
    if (subscriptionEndDate == null) return false;
    return DateTime.now().isAfter(subscriptionEndDate!);
  }

  bool get isTrialExpired {
    if (trialEndDate == null) return false;
    return DateTime.now().isAfter(trialEndDate!);
  }

  SubscriptionStatus copyWith({
    SubscriptionPlan? currentPlan,
    DateTime? subscriptionStartDate,
    DateTime? subscriptionEndDate,
    bool? isTrialPeriod,
    DateTime? trialEndDate,
    bool? isActive,
    List<PremiumFeature>? availableFeatures,
  }) {
    return SubscriptionStatus(
      currentPlan: currentPlan ?? this.currentPlan,
      subscriptionStartDate: subscriptionStartDate ?? this.subscriptionStartDate,
      subscriptionEndDate: subscriptionEndDate ?? this.subscriptionEndDate,
      isTrialPeriod: isTrialPeriod ?? this.isTrialPeriod,
      trialEndDate: trialEndDate ?? this.trialEndDate,
      isActive: isActive ?? this.isActive,
      availableFeatures: availableFeatures ?? this.availableFeatures,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPlan': currentPlan.productId,
      'subscriptionStartDate': subscriptionStartDate?.toIso8601String(),
      'subscriptionEndDate': subscriptionEndDate?.toIso8601String(),
      'isTrialPeriod': isTrialPeriod,
      'trialEndDate': trialEndDate?.toIso8601String(),
      'isActive': isActive,
      'availableFeatures': availableFeatures.map((f) => f.key).toList(),
    };
  }

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatus(
      currentPlan: SubscriptionPlan.values.firstWhere(
        (plan) => plan.productId == json['currentPlan'],
        orElse: () => SubscriptionPlan.free,
      ),
      subscriptionStartDate: json['subscriptionStartDate'] != null
          ? DateTime.parse(json['subscriptionStartDate'])
          : null,
      subscriptionEndDate: json['subscriptionEndDate'] != null
          ? DateTime.parse(json['subscriptionEndDate'])
          : null,
      isTrialPeriod: json['isTrialPeriod'] ?? false,
      trialEndDate: json['trialEndDate'] != null
          ? DateTime.parse(json['trialEndDate'])
          : null,
      isActive: json['isActive'] ?? false,
      availableFeatures: (json['availableFeatures'] as List<dynamic>?)
              ?.map((key) => PremiumFeature.values.firstWhere(
                    (feature) => feature.key == key,
                  ))
              .toList() ??
          [],
    );
  }

  static SubscriptionStatus get defaultFree => SubscriptionStatus(
        currentPlan: SubscriptionPlan.free,
        isActive: true,
        availableFeatures: const [],
      );

  static SubscriptionStatus createTrialStatus() {
    final now = DateTime.now();
    return SubscriptionStatus(
      currentPlan: SubscriptionPlan.free,
      isTrialPeriod: true,
      trialEndDate: now.add(const Duration(days: 7)), // 1 hafta ücretsiz deneme
      isActive: true,
      availableFeatures: [
        PremiumFeature.reminders,
        PremiumFeature.androidWidget,
        // Ad-free hariç tüm özellikler
      ],
    );
  }
}