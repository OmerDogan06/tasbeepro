import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _shimmerController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _shimmerAnimation;

  // İslami renk paleti
  static const emeraldGreen = Color(0xFF2D5016);
  static const goldColor = Color(0xFFD4AF37);
  static const lightGold = Color(0xFFF5E6A8);
  static const darkGreen = Color(0xFF1A3409);

  @override
  void initState() {
    super.initState();
    
    // Animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    _startAnimations();
  }

  void _startAnimations() async {
    // Start animations with delays
    _fadeController.forward();
    
    await Future.delayed(const Duration(milliseconds: 300));
    _scaleController.forward();
    
    await Future.delayed(const Duration(milliseconds: 500));
    _rotationController.forward();
    
    await Future.delayed(const Duration(milliseconds: 800));
    _shimmerController.repeat(reverse: true);

    // Navigate to home after all animations
    await Future.delayed(const Duration(milliseconds: 3200));
    // if (mounted) {
    //   Get.offAll(
    //     () => const HomeScreen(),
    //     transition: Transition.fadeIn,
    //     duration: const Duration(milliseconds: 800),
    //   );
    // }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: emeraldGreen,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.3),
              radius: 1.2,
              colors: [
                Color(0xFF3D6B1F), // Açık emerald
                Color(0xFF2D5016), // Ana emerald
                Color(0xFF1A3409), // Koyu emerald
              ],
              stops: [0.0, 0.6, 1.0],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // İslami pattern background
                // _buildIslamicPattern(),
                
                // Main content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),
                      
                      // Logo/Icon section
                      AnimatedBuilder(
                        animation: Listenable.merge([
                          _fadeAnimation,
                          _scaleAnimation,
                          _rotationAnimation,
                        ]),
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Opacity(
                              opacity: _fadeAnimation.value,
                              child: _buildLogo(),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // App name with shimmer effect
                      AnimatedBuilder(
                        animation: _shimmerAnimation,
                        builder: (context, child) {
                          return AnimatedBuilder(
                            animation: _fadeAnimation,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _fadeAnimation.value,
                                child: _buildAppTitle(),
                              );
                            },
                          );
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Subtitle
                      AnimatedBuilder(
                        animation: _fadeAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _fadeAnimation.value * 0.8,
                            child: _buildSubtitle(),
                          );
                        },
                      ),
                      
                      const Spacer(flex: 3),
                      
                      // Loading indicator
                      AnimatedBuilder(
                        animation: _fadeAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _fadeAnimation.value,
                            child: _buildLoadingIndicator(),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildIslamicPattern() {
  //   return Positioned.fill(
  //     child: CustomPaint(
  //       painter: IslamicPatternPainter(),
  //     ),
  //   );
  // }

  Widget _buildLogo() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.3, -0.3),
          radius: 0.8,
          colors: [
            Color(0xFFF5E6A8), // Light gold
            Color(0xFFD4AF37), // Gold
            Color(0xFFB8941F), // Darker gold
          ],
          stops: [0.0, 0.6, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: goldColor.withOpacity(0.3),
            blurRadius: 40,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: CustomPaint(
        size: const Size(140, 140),
        painter: LogoPainter(
          rotationAnimation: _rotationAnimation,
        ),
      ),
    );
  }

  Widget _buildAppTitle() {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: Alignment(-1.0 + _shimmerAnimation.value * 2, 0.0),
          end: Alignment(1.0 + _shimmerAnimation.value * 2, 0.0),
          colors: const [
            Color(0xFFF5E6A8),
            Color(0xFFFFFFFF),
            Color(0xFFF5E6A8),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(bounds);
      },
      child: const Text(
        'Tasbee Pro',
        style: TextStyle(
          fontSize: 35,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 2.0,
          shadows: [
            Shadow(
              color: Colors.black38,
              offset: Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return const Column(
      children: [
        Text(
          'بِسْمِ اللَّهِ الرَّحْمَـٰنِ الرَّحِيمِ',
          style: TextStyle(
            fontSize: 16,
            color: lightGold,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.0,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          'Dijital Tesbih Uygulaması',
          style: TextStyle(
            fontSize: 12,
            color: lightGold,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.8,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: const AlwaysStoppedAnimation<Color>(goldColor),
            backgroundColor: lightGold.withOpacity(0.3),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Yükleniyor...',
          style: TextStyle(
            fontSize: 14,
            color: lightGold,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class IslamicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3D6B1F).withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Geometric Islamic pattern
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width * 0.6;

    // Draw concentric circles
    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(
        Offset(centerX, centerY),
        radius * (i / 4),
        paint,
      );
    }

    // Draw radiating lines
    for (int i = 0; i < 16; i++) {
      final angle = (i * 2 * math.pi) / 16;
      final startX = centerX + (radius * 0.3) * math.cos(angle);
      final startY = centerY + (radius * 0.3) * math.sin(angle);
      final endX = centerX + radius * math.cos(angle);
      final endY = centerY + radius * math.sin(angle);

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
    }

    // Small decorative circles
    for (int i = 0; i < 8; i++) {
      final angle = (i * 2 * math.pi) / 8;
      final x = centerX + (radius * 0.8) * math.cos(angle);
      final y = centerY + (radius * 0.8) * math.sin(angle);

      canvas.drawCircle(
        Offset(x, y),
        8,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LogoPainter extends CustomPainter {
  final Animation<double> rotationAnimation;

  LogoPainter({required this.rotationAnimation});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Save canvas state
    canvas.save();
    
    // Rotate canvas
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAnimation.value);
    canvas.translate(-center.dx, -center.dy);

    // Draw crescent moon (Islamic symbol) - eğimli ve gerçekçi
    final crescentPaint = Paint()
      ..color = const Color(0xFF2D5016)
      ..style = PaintingStyle.fill;

    final crescentRadius = radius * 0.6;
    
    // Ayı eğimli konumlandır (Türk bayrağındaki gibi - yukarı bakacak)
    final crescentCenter = Offset(
      center.dx - crescentRadius * -0.15, 
      center.dy + crescentRadius * -0.05  // Yukarı bakması için + değeri
    );

    // Outer circle
    final outerCircle = Path()
      ..addOval(Rect.fromCircle(
        center: crescentCenter,
        radius: crescentRadius,
      ));

    // Inner circle to create crescent - yukarı bakan hilal için
    final innerCircleCenter = Offset(
      crescentCenter.dx + crescentRadius * 0.4,
      crescentCenter.dy - crescentRadius * 0.3, // Yukarı bakması için - değeri
    );
    final innerCircle = Path()
      ..addOval(Rect.fromCircle(
        center: innerCircleCenter,
        radius: crescentRadius * 0.8, // Daha ince hilal için
      ));

    // Create crescent shape
    final crescentPath = Path.combine(
      PathOperation.difference,
      outerCircle,
      innerCircle,
    );

    canvas.drawPath(crescentPath, crescentPaint);

    // Restore canvas state
    canvas.restore();

    // Draw tasbih beads around the crescent (non-rotating)
    final beadPaint = Paint()
      ..color = const Color(0xFF2D5016)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 12; i++) {
      final angle = (i * 2 * math.pi) / 12;
      final beadX = center.dx + (radius * 0.85) * math.cos(angle);
      final beadY = center.dy + (radius * 0.85) * math.sin(angle);

      canvas.drawCircle(
        Offset(beadX, beadY),
        3,
        beadPaint,
      );
    }

  
  }

  @override
  bool shouldRepaint(LogoPainter oldDelegate) {
    return oldDelegate.rotationAnimation != rotationAnimation;
  }
}