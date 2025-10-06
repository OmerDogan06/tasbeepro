import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import '../controllers/counter_controller.dart';

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
                  controller.increment();
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
                                  color: const Color(0xFFD4AF37), // Altın rengi
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontSize,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.5),
                                      offset: const Offset(0, 3),
                                      blurRadius: 6,
                                    ),
                                    Shadow(
                                      color: const Color(0xFF2D5016).withOpacity(0.3), // Yeşil gölge
                                      offset: const Offset(0, 1),
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
                            'Dokun',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFFF5E6A8), // Açık altın
                              fontSize: (buttonSize * 0.08).clamp(12.0, 18.0), // Responsive font
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.4),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
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

    // İslami renk paleti
    final emeraldGreen = const Color(0xFF2D5016);
    final goldColor = const Color(0xFFD4AF37);
    final lightGold = const Color(0xFFF5E6A8);
    final darkGreen = const Color(0xFF1A3409);

    // Outer shadow (elevation effect)
    if (!isPressed) {
      final shadowPaint = Paint()
        ..color = darkGreen.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
      
      canvas.drawCircle(
        center + const Offset(0, 8),
        radius - 2,
        shadowPaint,
      );
    }

    // Ana buton - İslami gradient (HER ŞEY SABİT)
    final gradientColors = [
      lightGold.withOpacity(0.7), 
      goldColor.withOpacity(0.9), 
      emeraldGreen, 
      darkGreen
    ]; // SABİT renkler - basma durumuna göre değişmiyor

    final gradientStops = [0.0, 0.3, 0.8, 1.0]; // SABİT stops

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

    // Altın kenar bordür
    final borderPaint = Paint()
      ..color = goldColor.withOpacity(isPressed ? 0.6 : 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(center, radius - 5, borderPaint);

    // İç altın bordür
    final innerBorderPaint = Paint()
      ..color = lightGold.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(center, radius - 15, innerBorderPaint);

    // Progress ring - Altın renkte
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = goldColor
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
        ..color = goldColor.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

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

    // Sol üst sabit highlight - Hilalin gözükmesi için çok açık
    final highlightPaint = Paint()
      ..color = lightGold.withOpacity(0.10) // Sabit açıklık - değişmiyor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);
    
    canvas.drawCircle(
      center + const Offset(-30, -30), // Pixel değer ile sabit - değişmiyor!
      radius * 0.4,
      highlightPaint,
    );
  }

  void _drawIslamicPattern(Canvas canvas, Offset center, double radius) {
    // İslami renk paleti
    final goldColor = const Color(0xFFD4AF37);
    
    final patternPaint = Paint()
      ..color = goldColor.withOpacity(isPressed ? 0.2 : 0.3) // Daha açık opacity
      ..style = PaintingStyle.fill;

    // Hilal (Yarım ay) çizimi - Türk bayrağındaki gibi
    final crescentRadius = radius * 0.5; // Daha büyük
    final crescentCenter = Offset(center.dx - crescentRadius * 0.1, center.dy);
    
    // Dış daire (büyük)
    final outerCircle = Path()
      ..addOval(Rect.fromCircle(
        center: crescentCenter, 
        radius: crescentRadius,
      ));
    
    // İç daire (küçük) - hilali oluşturmak için, daha az örtüşecek
    final innerCircleCenter = Offset(
      crescentCenter.dx + crescentRadius * 0.5, // Daha az örtüşme
      crescentCenter.dy,
    );
    final innerCircle = Path()
      ..addOval(Rect.fromCircle(
        center: innerCircleCenter, 
        radius: crescentRadius * 0.75, // Daha ince hilal için büyük iç daire
      ));
    
    // Hilal şeklini oluştur (dış daire - iç daire)
    final crescentPath = Path.combine(
      PathOperation.difference, 
      outerCircle, 
      innerCircle,
    );
    
    canvas.drawPath(crescentPath, patternPaint);

    // Hilal kenarına ince altın çizgi
    final crescentBorderPaint = Paint()
      ..color = goldColor.withOpacity(0.3) // Daha açık kenar çizgisi
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    canvas.drawPath(crescentPath, crescentBorderPaint);

    // Merkez etrafında ince daireler (geleneksel İslami motif)
    for (int i = 1; i <= 3; i++) {
      final circleRadius = radius * 0.15 * i;
      final circlePaint = Paint()
        ..color = goldColor.withOpacity(0.3 / i)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
        
      canvas.drawCircle(center, circleRadius, circlePaint);
    }
    
    // 8 yönde ince radyal çizgiler (geleneksel İslami geometri)
    for (int i = 0; i < 8; i++) {
      final angle = (i * 2 * math.pi) / 8;
      final startRadius = radius * 0.6;
      final endRadius = radius * 0.8;
      
      final startX = center.dx + startRadius * math.cos(angle);
      final startY = center.dy + startRadius * math.sin(angle);
      final endX = center.dx + endRadius * math.cos(angle);
      final endY = center.dy + endRadius * math.sin(angle);
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        Paint()
          ..color = goldColor.withOpacity(0.3)
          ..strokeWidth = 1,
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