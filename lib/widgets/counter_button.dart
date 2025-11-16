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
  bool _isUndoMode = false; // Geri alma modu

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

  void _onPointerDown(PointerDownEvent event) {
    setState(() => _isPressed = true);
    _pressAnimationController.forward();
  }

  void _onPointerUp(PointerUpEvent event) {
    setState(() => _isPressed = false);
    _pressAnimationController.reverse();
  }

  void _onPointerCancel(PointerCancelEvent event) {
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
              child: Listener(
                onPointerDown: _onPointerDown,
                onPointerUp: _onPointerUp,
                onPointerCancel: _onPointerCancel,
                child: GestureDetector(
                  onTap: () {
                  if (_isUndoMode) {
                    // Geri alma modu - decrement
                    controller.decrement();
                  } else {
                    // Normal mod - increment
                    final completionTitle = AppLocalizations.of(context)?.targetCompletionTitle ?? 'Tebrikler! 🎉';
                    final completionMessage = AppLocalizations.of(context)?.targetCompletionMessage ?? 'Hedefini tamamladın!';
                    controller.increment(completionTitle, completionMessage);
                  }
                },
                onLongPress: () async {
                  // İslami renk paleti - Settings ile aynı
                  const emeraldGreen = Color(0xFF2D5016);
                  const goldColor = Color(0xFFD4AF37);
                  const lightGold = Color(0xFFF5E6A8);
                  const darkGreen = Color(0xFF1A3409);
                  
                  // Dialog ile onay al
                  final newMode = !_isUndoMode;
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => Dialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: const EdgeInsets.all(20),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 320),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFF8F6F0), Color(0xFFF0E9D2)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: goldColor.withAlpha(102), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: darkGreen.withAlpha(51),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: const RadialGradient(
                                        colors: [lightGold, goldColor],
                                        center: Alignment(-0.2, -0.2),
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      newMode ? Icons.undo : Icons.add_circle_outline,
                                      color: emeraldGreen,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      newMode 
                                        ? (AppLocalizations.of(context)?.undoModeTitle ?? 'Geri Alma Modu')
                                        : (AppLocalizations.of(context)?.normalModeTitle ?? 'Normal Mod'),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: emeraldGreen,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Divider
                            Container(
                              height: 1,
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    goldColor.withAlpha(77),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            
                            // Content
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                              child: Text(
                                newMode 
                                  ? (AppLocalizations.of(context)?.undoModeMessage ?? 'Geri alma moduna geçmek istiyor musunuz?\n\nBu modda butona tıkladığınızda sayaç azalacak.')
                                  : (AppLocalizations.of(context)?.normalModeMessage ?? 'Normal moda geçmek istiyor musunuz?\n\nBu modda butona tıkladığınızda sayaç artacak.'),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: emeraldGreen.withAlpha(179),
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            
                            // Divider
                            Container(
                              height: 1,
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    goldColor.withAlpha(77),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            
                            // Actions
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // İptal butonu
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: goldColor.withAlpha(102),
                                          width: 1,
                                        ),
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(8),
                                          onTap: () => Navigator.of(context).pop(false),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                            child: Text(
                                              AppLocalizations.of(context)?.cancel ?? 'İptal',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: emeraldGreen,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Tamam butonu
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: RadialGradient(
                                          colors: [lightGold, goldColor],
                                          center: const Alignment(-0.3, -0.5),
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: goldColor.withAlpha(77),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(8),
                                          onTap: () => Navigator.of(context).pop(true),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                            child: Text(
                                              AppLocalizations.of(context)?.ok ?? 'Tamam',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: emeraldGreen,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                  
                  // Kullanıcı onayladıysa modu değiştir
                  if (confirmed == true) {
                    setState(() {
                      _isUndoMode = newMode;
                    });
                  }
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
                          if (_isUndoMode)
                            Icon(
                              Icons.undo,
                              size: (buttonSize * 0.12).clamp(18.0, 28.0),
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withAlpha(179),
                                  offset: const Offset(0, 4),
                                  blurRadius: 8,
                                ),
                                Shadow(
                                  color: const Color(0xFF0A2818).withAlpha(128),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            )
                          else
                            Text(
                              AppLocalizations.of(context)?.counterButtonText ?? 'Dokun',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white,
                                fontSize: (buttonSize * 0.08).clamp(12.0, 18.0),
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2.0,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withAlpha(179),
                                    offset: const Offset(0, 4),
                                    blurRadius: 8,
                                  ),
                                  Shadow(
                                    color: const Color(0xFF0A2818).withAlpha(128),
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                  Shadow(
                                    color: const Color(0xFFFFD700).withAlpha(77),
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