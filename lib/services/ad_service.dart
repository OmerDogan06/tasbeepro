import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'storage_service.dart';
import 'subscription_service.dart';

class AdService extends GetxService with WidgetsBindingObserver {
  static AdService get instance => Get.find<AdService>();
  
  // Interstitial Ad
  InterstitialAd? _interstitialAd;
  final _isInterstitialAdReady = false.obs;
  
  // App Open Ad
  AppOpenAd? _appOpenAd;
  final _isAppOpenAdReady = false.obs;
  
  // Rewarded Ad
  RewardedAd? _rewardedAd;
  final _isRewardedAdReady = false.obs;
  
  // Ad IDs - Sadece Android
  static String get _bannerAdUnitId => kDebugMode 
    ? 'ca-app-pub-3940256099942544/6300978111' // Test ID
    : 'ca-app-pub-8365973392717077/7933053261'; // Gerçek Android Banner ID
      
  static String get _interstitialAdUnitId => kDebugMode
    ? 'ca-app-pub-3940256099942544/1033173712' // Test ID
    : 'ca-app-pub-8365973392717077/2282105489'; // Gerçek Android Interstitial ID
      
  static String get _appOpenAdUnitId => kDebugMode
    ? 'ca-app-pub-3940256099942544/9257395921' // Test ID
    : 'ca-app-pub-8365973392717077/7002566230'; // Gerçek Android App Open ID
    
  static String get _rewardedAdUnitId => kDebugMode 
    ? 'ca-app-pub-3940256099942544/5224354917' // Test ID
    : 'ca-app-pub-8365973392717077/5052712824'; // TODO: Gerçek Rewarded Ad ID ekle
  
  // Getters
  bool get isInterstitialAdReady => _isInterstitialAdReady.value;
  bool get isAppOpenAdReady => _isAppOpenAdReady.value;
  bool get isRewardedAdReady => _isRewardedAdReady.value;
  
  // Target completion tracking
  final _completedTargetsCount = 0.obs;
  int get completedTargetsCount => _completedTargetsCount.value;
  
  // App lifecycle tracking
  bool _isAppInBackground = false;
  
  @override
  void onInit() {
    super.onInit();
    _loadCompletedTargetsFromStorage();
    _initializeAds();
    
    // App lifecycle'ı dinlemeye başla
    WidgetsBinding.instance.addObserver(this);
  }

  // Premium kontrolü
  bool get _isAdFreeEnabled {
    try {
      final subscriptionService = Get.find<SubscriptionService>();
      return subscriptionService.isAdFreeEnabled;
    } catch (e) {
      // SubscriptionService henüz initialize olmamış olabilir
      return false;
    }
  }
  
  // Storage'dan hedef tamamlama sayısını yükle
  void _loadCompletedTargetsFromStorage() {
    try {
      final storageService = Get.find<StorageService>();
      _completedTargetsCount.value = storageService.getCompletedTargetsCount();
      if (kDebugMode) print('Loaded completed targets from storage: ${_completedTargetsCount.value}');
    } catch (e) {
      if (kDebugMode) print('Error loading completed targets: $e');
      _completedTargetsCount.value = 0;
    }
  }
  
  Future<void> _initializeAds() async {
    await MobileAds.instance.initialize();
    
    // Test cihaz ekle (debug modunda)
    if (kDebugMode) {
      final List<String> testDeviceIds = ['YOUR_TEST_DEVICE_ID'];
      final RequestConfiguration configuration = RequestConfiguration(
        testDeviceIds: testDeviceIds,
      );
      MobileAds.instance.updateRequestConfiguration(configuration);
    }
    
    _loadInterstitialAd();
    _loadAppOpenAd();
    _loadRewardedAd();
  }
  
  // App Lifecycle Management
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.paused) {
      _isAppInBackground = true;
      if (kDebugMode) print('📱 App went to background');
    } else if (state == AppLifecycleState.resumed && _isAppInBackground) {
      _isAppInBackground = false;
      if (kDebugMode) print('📱 App returned from background - showing App Open Ad');
      _showAppOpenAdIfReady();
    }
  }
  
  // App Open Ad'i uygun zamanda göster
  void _showAppOpenAdIfReady() {
    if (_isAppOpenAdReady.value) {
      if (kDebugMode) print('🚀 Showing App Open Ad (App Resume)');
      showAppOpenAd();
    } else {
      if (kDebugMode) print('❌ App Open Ad not ready yet');
      // Hemen yüklemeyi dene
      _loadAppOpenAd();
    }
  }
  
  // Banner Ad Factory - Her çağrıda yeni ad oluşturur
  BannerAd? createBannerAd() {
    // Premium kullanıcılar için reklam gösterme
    if (_isAdFreeEnabled) {
      if (kDebugMode) print('🚫 Banner ad blocked - Premium user');
      return null;
    }
    
    return BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (kDebugMode) print('Banner ad loaded successfully');
        },
        onAdFailedToLoad: (ad, error) {
          if (kDebugMode) print('Banner ad failed to load: $error');
          ad.dispose();
        },
        onAdOpened: (ad) {
          if (kDebugMode) print('Banner ad opened');
        },
        onAdClosed: (ad) {
          if (kDebugMode) print('Banner ad closed');
        },
      ),
    );
  }
  
  // Interstitial Ad Methods
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady.value = true;
          if (kDebugMode) print('Interstitial ad loaded successfully');
          
          _interstitialAd?.setImmersiveMode(true);
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdReady.value = false;
          _interstitialAd = null;
          if (kDebugMode) print('Interstitial ad failed to load: $error');
          
          // Retry after 30 seconds
          Future.delayed(const Duration(seconds: 30), () {
            _loadInterstitialAd();
          });
        },
      ),
    );
  }
  
  Future<void> showInterstitialAd() async {
    // Premium kullanıcılar için reklam gösterme
    if (_isAdFreeEnabled) {
      if (kDebugMode) print('🚫 Interstitial ad blocked - Premium user');
      return;
    }
    
    if (_interstitialAd != null && _isInterstitialAdReady.value) {
      _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          if (kDebugMode) print('Interstitial ad showed full screen content');
        },
        onAdDismissedFullScreenContent: (ad) {
          if (kDebugMode) print('Interstitial ad dismissed full screen content');
          ad.dispose();
          _interstitialAd = null;
          _isInterstitialAdReady.value = false;
          _loadInterstitialAd(); // Load new ad
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          if (kDebugMode) print('Interstitial ad failed to show: $error');
          ad.dispose();
          _interstitialAd = null;
          _isInterstitialAdReady.value = false;
          _loadInterstitialAd(); // Load new ad
        },
      );
      
      await _interstitialAd?.show();
    } else {
      if (kDebugMode) print('Interstitial ad not ready');
    }
  }
  
  // App Open Ad Methods
  void _loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: _appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isAppOpenAdReady.value = true;
          if (kDebugMode) print('App open ad loaded successfully');
        },
        onAdFailedToLoad: (error) {
          _isAppOpenAdReady.value = false;
          _appOpenAd = null;
          if (kDebugMode) print('App open ad failed to load: $error');
          
          // Retry after 30 seconds
          Future.delayed(const Duration(seconds: 30), () {
            _loadAppOpenAd();
          });
        },
      ),
    );
  }
  
  Future<void> showAppOpenAd() async {
    // Premium kullanıcılar için reklam gösterme
    if (_isAdFreeEnabled) {
      if (kDebugMode) print('🚫 App open ad blocked - Premium user');
      return;
    }
    
    if (_appOpenAd != null && _isAppOpenAdReady.value) {
      _appOpenAd?.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          if (kDebugMode) print('App open ad showed full screen content');
        },
        onAdDismissedFullScreenContent: (ad) {
          if (kDebugMode) print('App open ad dismissed full screen content');
          ad.dispose();
          _appOpenAd = null;
          _isAppOpenAdReady.value = false;
          _loadAppOpenAd(); // Load new ad
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          if (kDebugMode) print('App open ad failed to show: $error');
          ad.dispose();
          _appOpenAd = null;
          _isAppOpenAdReady.value = false;
          _loadAppOpenAd(); // Load new ad
        },
      );
      
      await _appOpenAd?.show();
    } else {
      if (kDebugMode) print('App open ad not ready');
    }
  }
  
  // Rewarded Ad Methods
  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdReady.value = true;
          if (kDebugMode) print('✅ Rewarded ad loaded successfully');
        },
        onAdFailedToLoad: (error) {
          _isRewardedAdReady.value = false;
          _rewardedAd = null;
          if (kDebugMode) print('❌ Rewarded ad failed to load: $error');
          
          // Retry after 30 seconds
          Future.delayed(const Duration(seconds: 30), () {
            _loadRewardedAd();
          });
        },
      ),
    );
  }
  
  Future<bool> showRewardedAd(Function(int, String) onUserEarnedReward) async {
    // Premium kullanıcılar için reklam gösterme
    if (_isAdFreeEnabled) {
      if (kDebugMode) print('🚫 Rewarded ad blocked - Premium user');
      return false;
    }
    
    if (_rewardedAd != null && _isRewardedAdReady.value) {
      bool rewardEarned = false;
      
      _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          if (kDebugMode) print('🎬 Rewarded ad showed full screen content');
        },
        onAdDismissedFullScreenContent: (ad) {
          if (kDebugMode) print('✅ Rewarded ad dismissed');
          ad.dispose();
          _rewardedAd = null;
          _isRewardedAdReady.value = false;
          _loadRewardedAd(); // Load new ad
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          if (kDebugMode) print('❌ Rewarded ad failed to show: $error');
          ad.dispose();
          _rewardedAd = null;
          _isRewardedAdReady.value = false;
          _loadRewardedAd(); // Load new ad
        },
      );
      
      await _rewardedAd?.show(
        onUserEarnedReward: (ad, reward) {
          if (kDebugMode) {
            print('🎉 User earned reward: ${reward.amount} ${reward.type}');
          }
          rewardEarned = true;
          onUserEarnedReward(reward.amount.toInt(), reward.type);
        },
      );
      
      return rewardEarned;
    } else {
      if (kDebugMode) print('❌ Rewarded ad not ready');
      return false;
    }
  }
  
  // Target completion tracking methods
  void onTargetCompleted() {
    onUserAction('hedef_tamamlama');
  }
  
  // Genel kullanıcı aksiyonu takibi - Tüm işlemler için tek sayaç
  void onUserAction(String actionType) {
    _completedTargetsCount.value++;
    
    // Storage'a kaydet
    try {
      final storageService = Get.find<StorageService>();
      storageService.saveCompletedTargetsCount(_completedTargetsCount.value);
      if (kDebugMode) print('User action ($actionType)! Total count: ${_completedTargetsCount.value}');
    } catch (e) {
      if (kDebugMode) print('Error saving user actions: $e');
    }
    
    // Her 5 işlemde bir tam ekran reklam göster
    if (_completedTargetsCount.value % 5 == 0) {
      _showFullScreenAd();
    }
  }
  
  void _showFullScreenAd() {
    if (kDebugMode) {
      print('=== HEDEF TAMAMLAMA REKLAMI ===');
      print('Interstitial Ready: ${_isInterstitialAdReady.value}');
      print('===============================');
    }
    
    // Hedef tamamlandığında sadece Interstitial Ad göster
    if (_isInterstitialAdReady.value) {
      if (kDebugMode) print('🎯 Showing Interstitial Ad for Target Completion');
      showInterstitialAd();
    } else {
      // Hiçbir reklam yüklenmemişse zorlamayalım, kullanıcı normal devam etsin
      if (kDebugMode) print('❌ No interstitial ad available - user continues normally');
      if (kDebugMode) print('💡 Interstitial ad will be loaded in background for next time');
      
      // Arka planda tekrar yüklemeyi dene (kullanıcıyı engellemeden)
      Future.delayed(const Duration(seconds: 5), () {
        _loadInterstitialAd();
      });
    }
  }
  
  @override
  void onClose() {
    // App lifecycle observer'ı kaldır
    WidgetsBinding.instance.removeObserver(this);
    
    _interstitialAd?.dispose();
    _appOpenAd?.dispose();
    _rewardedAd?.dispose();
    super.onClose();
  }
}