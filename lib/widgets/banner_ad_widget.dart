import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';
import '../services/subscription_service.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  // İslami renk paleti
  static const goldColor = Color(0xFFD4AF37);
  static const darkGreen = Color(0xFF1A3409);

  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    // AdService'den banner ad oluştur
    final adService = AdService.instance;
    _bannerAd = adService.createBannerAd();
    
    // Premium kullanıcılar için null döner
    if (_bannerAd == null) {
      if (mounted) {
        setState(() {
          _isLoaded = false;
        });
      }
      return;
    }
    
    // Listener'ı güncelle
    _bannerAd = BannerAd(
      adUnitId: _bannerAd!.adUnitId,
      size: _bannerAd!.size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          if (mounted) {
            setState(() {
              _isLoaded = false;
            });
          }
          ad.dispose();
        },
      ),
    );
    
    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Premium kontrolü - SubscriptionService kullanarak
    try {
      final subscriptionService = Get.find<SubscriptionService>();
      if (subscriptionService.isAdFreeEnabled) {
        return const SizedBox.shrink(); // Premium kullanıcı, reklam gösterme
      }
    } catch (e) {
      // SubscriptionService henüz hazır değil, reklam göster
    }
    
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink(); // Reklam hazır değilse hiçbir şey gösterme
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFDF7), Color(0xFFF5F3E8)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: goldColor.withAlpha(77), width: 1),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          alignment: Alignment.center,
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        ),
      ),
    );
  }
}