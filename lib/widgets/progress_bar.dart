import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../controllers/counter_controller.dart';
import '../l10n/app_localizations.dart';

class ProgressBar extends StatefulWidget {
  const ProgressBar({super.key});

  @override
  State<ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar> 
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  double _currentProgress = 0.0;

  // İslami renk paleti - counter_button ile aynı
  static const emeraldGreen = Color(0xFF2D5016);
  static const goldColor = Color(0xFFD4AF37);
  static const lightGold = Color(0xFFF5E6A8);
  static const darkGreen = Color(0xFF1A3409);

  @override
  void initState() {
    super.initState();
    
    // Progress animasyon kontrolü
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Progress animasyonu - smooth geçiş için curved animation
    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOutCubic,
    );
    
    // İlk değerleri ayarla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<CounterController>();
      _updateProgress(controller.progress);
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _updateProgress(double newProgress) {
    if (_currentProgress != newProgress) {
      _currentProgress = newProgress;
      _progressController.animateTo(newProgress);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CounterController>();
    
    return Obx(() {
      // Bu değerler reactive olduğu için progress hesaplaması da otomatik güncellenir
      final currentProgress = controller.progress;
      
      // Progress değiştiğinde animasyonu güncelle
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateProgress(currentProgress);
      });
        
        return AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return FadeInDown(
              duration: const Duration(milliseconds: 600),
              child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8F6F0), // Açık krem
              Color(0xFFF0E9D2), // Biraz daha koyu krem
            ],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: goldColor.withAlpha(77),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: darkGreen.withAlpha(26),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Sayı ve yüzde bilgisi - Animasyonlu
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SlideInLeft(
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: lightGold.withAlpha(102),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: goldColor.withAlpha(77),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: darkGreen.withAlpha(13),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        '${controller.count}/${controller.target}',
                        style: const TextStyle(
                          color: emeraldGreen,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                  SlideInRight(
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [lightGold, goldColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: darkGreen.withAlpha(39),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                          BoxShadow(
                            color: goldColor.withAlpha(26),
                            blurRadius: 8,
                            offset: const Offset(0, 0),
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Text(
                        '${(controller.progress * 100).toInt()}%',
                        style: const TextStyle(
                          color: emeraldGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            
            // Modern animasyonlu progress bar
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: lightGold.withAlpha(77),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: goldColor.withAlpha(51),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: darkGreen.withAlpha(13),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Stack(
                  children: [
                    // Ana progress bar
                    LinearProgressIndicator(
                      value: _progressAnimation.value,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        goldColor,
                      ),
                      minHeight: 10,
                    ),
                    // Işıltı efekti
                    if (_progressAnimation.value > 0)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              stops: [
                                (_progressAnimation.value - 0.3).clamp(0.0, 1.0),
                                _progressAnimation.value,
                                (_progressAnimation.value + 0.1).clamp(0.0, 1.0),
                              ],
                              colors: [
                                Colors.transparent,
                                Colors.white.withAlpha(102),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            // Hedef tamamlandı mesajı - Modern animasyonlu
            if (controller.isCompleted) ...[
              const SizedBox(height: 4),
              BounceInDown(
                duration: const Duration(milliseconds: 600),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [lightGold, goldColor],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: emeraldGreen.withAlpha(77),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: darkGreen.withAlpha(26),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                      BoxShadow(
                        color: goldColor.withAlpha(51),
                        blurRadius: 12,
                        offset: const Offset(0, 0),
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flash(
                        infinite: true,
                        duration: const Duration(milliseconds: 1500),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: emeraldGreen,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: emeraldGreen.withAlpha(102),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: lightGold,
                            size: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.progressBarCompleted,
                        style: const TextStyle(
                          color: emeraldGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
              ),
            );
          },
        );
    });
  }
}