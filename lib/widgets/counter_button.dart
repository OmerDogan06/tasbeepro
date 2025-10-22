import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import '../controllers/counter_controller.dart';
import '../l10n/app_localizations.dart';

class CounterButton extends StatefulWidget {
  const CounterButton({super.key});

  @override
  State<CounterButton> createState() => _CounterButtonState();
}

class _CounterButtonState extends State<CounterButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressAnimationController;
  late Animation<double> _pressAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _pressAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _pressAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pressAnimationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _pressAnimationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _pressAnimationController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _pressAnimationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CounterController>();
    
    // Responsive button size
    final screenSize = MediaQuery.of(context).size;
    final buttonSize = (screenSize.width * 0.45).clamp(180.0, 250.0);
    
    return Center(
      child: Obx(() {
        // Dynamic font size based on number length
        final countString = controller.count.toString();
        final maxFontSize = buttonSize * 0.24; // Base font size
        final minFontSize = buttonSize * 0.12; // Minimum font size
        
        // Calculate font size based on text length
        double fontSize;
        if (countString.length <= 2) {
          fontSize = maxFontSize;
        } else if (countString.length <= 3) {
          fontSize = maxFontSize * 0.85;
        } else if (countString.length <= 4) {
          fontSize = maxFontSize * 0.7;
        } else {
          fontSize = minFontSize;
        }
        
        // Progress reactive olarak hesapla
        final currentProgress = controller.target > 0 
            ? (controller.count / controller.target).clamp(0.0, 1.0) 
            : 0.0;
        
        return AnimatedBuilder(
          animation: _pressAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pressAnimation.value,
              child: GestureDetector(
                onTapDown: _onTapDown,
                onTapUp: _onTapUp,
                onTapCancel: _onTapCancel,
                onTap: () {
                  final completionTitle = AppLocalizations.of(context)?.targetCompletionTitle ?? 'Tebrikler! 🎉';
                  final completionMessage = AppLocalizations.of(context)?.targetCompletionMessage ?? 'Hedefini tamamladın!';
                  controller.increment(completionTitle, completionMessage);
                },
                child: CustomPaint(
                  size: Size(buttonSize, buttonSize),
                  painter: ModernButtonPainter(
                    primaryColor: Theme.of(context).colorScheme.primary,
                    isPressed: _isPressed,
                    isAnimating: controller.isAnimating,
                    progress: currentProgress, // Reactive progress kullan
                    target: controller.target,
                  ),
                  child: SizedBox(
                    width: buttonSize,
                    height: buttonSize,
                    child: Padding(
                      padding: EdgeInsets.all(buttonSize * 0.1), // Dynamic padding
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                controller.count.toString(),
                                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  color: const Color(0xFFFFD700), // Kraliyet altını - Pro renk
                                  fontWeight: FontWeight.w900, // Daha kalın
                                  fontSize: fontSize,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withAlpha(153),
                                      offset: const Offset(0, 4),
                                      blurRadius: 8,
                                    ),
                                    Shadow(
                                      color: const Color(0xFF0D4F3C).withAlpha(102), // Derin deniz yeşili gölge
                                      offset: const Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                    Shadow(
                                      color: const Color(0xFFCD7F32).withAlpha(77), // Bronz parıltı
                                      offset: const Offset(1, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          SizedBox(height: buttonSize * 0.04),
                          Text(
                            AppLocalizations.of(context)?.counterButtonText ?? 'Dokun',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white, // Beyaz renk - En belirgin olacak
                              fontSize: (buttonSize * 0.08).clamp(12.0, 18.0), // Responsive font
                              fontWeight: FontWeight.w800, // Daha da kalın
                              letterSpacing: 2.0, // Daha geniş karakter aralığı
                              shadows: [
                                Shadow(
                                  color: Colors.black.withAlpha(179), // Daha koyu gölge
                                  offset: const Offset(0, 4),
                                  blurRadius: 8,
                                ),
                                Shadow(
                                  color: const Color(0xFF0A2818).withAlpha(128), // Daha belirgin yeşil gölge
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                                Shadow(
                                  color: const Color(0xFFFFD700).withAlpha(77), // Altın parıltı
                                  offset: const Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class ModernButtonPainter extends CustomPainter {
  final Color primaryColor;
  final bool isPressed;
  final bool isAnimating;
  final double progress;
  final int target;

  ModernButtonPainter({
    required this.primaryColor,
    required this.isPressed,
    required this.isAnimating,
    required this.progress,
    required this.target,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Pro İslami renk paleti - Daha premium ve sofistike
    final deepTeal = const Color(0xFF0D4F3C); // Derin deniz yeşili
    final royalGold = const Color(0xFFFFD700); // Kraliyet altını
    final champagneGold = const Color(0xFFF7E7CE); // Şampanya altını
    final darkForest = const Color(0xFF0A2818); // Koyu orman yeşili

    // Outer shadow (elevation effect)
    if (!isPressed) {
      final shadowPaint = Paint()
        ..color = darkForest.withAlpha(77)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
      
      canvas.drawCircle(
        center + const Offset(0, 8),
        radius - 2,
        shadowPaint,
      );
    }

    // Ana buton - Pro İslami gradient (HER ŞEY SABİT)
    final gradientColors = [
      champagneGold.withAlpha(90), // Parlaklık azaltıldı (179'dan 120'ye)
      royalGold.withAlpha(100), // Parlaklık azaltıldı (230'dan 180'e)
      deepTeal, 
      darkForest
    ]; // SABİT renkler - basma durumuna göre değişmiyor

    final gradientStops = [0.05, 0.3, 0.8, 1.0]; // SABİT stops

    final gradient = RadialGradient(
      colors: gradientColors,
      stops: gradientStops,
      center: const Alignment(-0.5, -0.5), // SABİT merkez
    );

    final buttonPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    // Draw main button
    canvas.drawCircle(center, radius - (isPressed ? 3 : 0), buttonPaint);

    // İslami desenler - Geometrik pattern
    _drawIslamicPattern(canvas, center, radius);

    // Kraliyet altın kenar bordür
    final borderPaint = Paint()
      ..color = royalGold.withAlpha(isPressed ? 153 : 230)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(center, radius - 5, borderPaint);

    // İç şampanya altın bordür
    final innerBorderPaint = Paint()
      ..color = champagneGold.withAlpha(179)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(center, radius - 15, innerBorderPaint);

    // Progress ring - Kraliyet altını renkte
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = royalGold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round;

      final progressRect = Rect.fromCircle(
        center: center,
        radius: radius - 12,
      );

      canvas.drawArc(
        progressRect,
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        progressPaint,
      );

      // Progress glow
      final glowPaint = Paint()
        ..color = royalGold.withAlpha(40) // Parlaklık azaltıldı (77'den 40'a)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8 // Kalınlık da azaltıldı (12'den 8'e)
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6); // Blur azaltıldı (8'den 6'ya)

      canvas.drawArc(
        progressRect,
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        glowPaint,
      );
    }

    // Ripple effect - Altın renkte
    // if (isAnimating) {
    //   final ripplePaint = Paint()
    //     ..color = goldColor.withOpacity(0.2)
    //     ..style = PaintingStyle.fill;
      
    //   canvas.drawCircle(center, radius * 0.7, ripplePaint);
    // }

    // Sol üst sabit highlight - Tamamen kaldırıldı
    /* Highlight efekti kaldırıldı
    final highlightPaint = Paint()
      ..color = champagneGold.withAlpha(8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    
    canvas.drawCircle(
      center + const Offset(-30, -30),
      radius * 0.35,
      highlightPaint,
    );
    */
  }

  void _drawIslamicPattern(Canvas canvas, Offset center, double radius) {
    // Pro İslami renk paleti
    final champagneGold = const Color(0xFFF7E7CE);
    final bronzeAccent = const Color(0xFFCD7F32);
    
    // Pro Hilal (Türk bayrağı tarzı eğimli ay) çizimi
    final crescentRadius = radius * 0.4;
    final crescentCenter = Offset(center.dx, center.dy - radius * 0.1); // Biraz yukarıda
    
    // Ana hilal - tek katman (eğimli)
    final outerCircle = Path()
      ..addOval(Rect.fromCircle(
        center: crescentCenter, 
        radius: crescentRadius,
      ));
    
    // İç daire merkezi - orta seviye eğim için dengeli pozisyon
    final innerCircleCenter = Offset(
      crescentCenter.dx + crescentRadius * 0.4, // X ekseni 
      crescentCenter.dy - crescentRadius * 0.25, // Y ekseni - orta seviye yukarı kaydır
    );
    final innerCircle = Path()
      ..addOval(Rect.fromCircle(
        center: innerCircleCenter, 
        radius: crescentRadius * 0.75,
      ));
    
    final crescentPath = Path.combine(
      PathOperation.difference, 
      outerCircle, 
      innerCircle,
    );
    
    // Ana hilal - koyu altın renk (dokun yazısından farklı)
    final crescentPaint = Paint()
      ..color = const Color(0xFFB8860B) // Koyu altın rengi - DarkGoldenRod
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(crescentPath, crescentPaint);

    // Merkez etrafında bronz vurgu daireler (Pro İslami motif)
    for (int i = 1; i <= 3; i++) {
      final circleRadius = radius * 0.15 * i;
      final circlePaint = Paint()
        ..color = bronzeAccent.withAlpha((0.4 * 255 / i).toInt()) // Daha belirgin
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5; // Daha kalın çizgiler
        
      canvas.drawCircle(center, circleRadius, circlePaint);
    }
    
    // 12 yönde Pro radyal çizgiler (sofistike İslami geometri)
    for (int i = 0; i < 12; i++) {
      final angle = (i * 2 * math.pi) / 12;
      final startRadius = radius * 0.65;
      final endRadius = radius * 0.85;
      
      final startX = center.dx + startRadius * math.cos(angle);
      final startY = center.dy + startRadius * math.sin(angle);
      final endX = center.dx + endRadius * math.cos(angle);
      final endY = center.dy + endRadius * math.sin(angle);
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        Paint()
          ..color = champagneGold.withAlpha((0.4 * 255).toInt()) // Daha belirgin
          ..strokeWidth = 1.5, // Daha kalın
      );
    }
  }

  @override
  bool shouldRepaint(ModernButtonPainter oldDelegate) {
    return oldDelegate.isPressed != isPressed ||
           oldDelegate.isAnimating != isAnimating ||
           oldDelegate.progress != progress ||
           oldDelegate.target != target ||
           oldDelegate.primaryColor != primaryColor;
  }
}