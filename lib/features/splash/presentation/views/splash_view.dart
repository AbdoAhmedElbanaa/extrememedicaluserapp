import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ContextExtensionss, ContextExtensions;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:extrememedicaluserapp/features/splash/presentation/controllers/splash_controller.dart';
import 'package:extrememedicaluserapp/theme/app_theme.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    Get.lazyPut(() => SplashController());
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppTheme.gradientBackground(context),
        child: Stack(
          children: [
            // Ambient Glow Effects
            Positioned(
              top: -100,
              right: -100,
              child: _buildGlow(theme.colorScheme.primary, 300),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .move(end: const Offset(-20, 30), duration: const Duration(seconds: 5), curve: Curves.easeInOut),
            
            Positioned(
              bottom: -50,
              left: -50,
              child: _buildGlow(theme.colorScheme.secondary, 250),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .move(end: const Offset(30, -20), duration: const Duration(seconds: 4), curve: Curves.easeInOut),

            // Background Stars (Only in dark mode for better look)
            if (isDark)
              const Positioned.fill(
                child: StarsWidget(),
              ),
            
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with GSAP-like reveal
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.4),
                          blurRadius: 40,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'UM',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                          Container(
                            width: 35,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white70,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(duration: const Duration(milliseconds: 800))
                  .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), curve: Curves.elasticOut, duration: const Duration(milliseconds: 1200))
                  .shimmer(delay: const Duration(milliseconds: 1500), duration: const Duration(seconds: 2), color: Colors.white24),

                  const SizedBox(height: 48),
                  
                  // App Name with Character-like Reveal
                  Text(
                    'UserManual',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  )
                  .animate()
                  .fadeIn(delay: const Duration(milliseconds: 400), duration: const Duration(milliseconds: 800))
                  .slideY(begin: 0.5, end: 0, curve: Curves.easeOutBack),

                  const SizedBox(height: 12),
                  
                  // Subtitle with focus reveal
                  Text(
                    'Smart Device Intelligence',
                    style: TextStyle(
                      color: theme.colorScheme.tertiary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.5,
                    ),
                  )
                  .animate()
                  .fadeIn(delay: const Duration(milliseconds: 900))
                  .blurXY(begin: 15, end: 0, duration: const Duration(seconds: 1)),
                ],
              ),
            ),

            // Professional Footer
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Smooth Sequential Loading Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary.withValues(alpha: 0.8),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      )
                      .animate(onPlay: (c) => c.repeat())
                      .scale(
                        duration: const Duration(milliseconds: 800),
                        delay: Duration(milliseconds: index * 200),
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.5, 1.5),
                        curve: Curves.easeInOut,
                      )
                      .then()
                      .scale(duration: const Duration(milliseconds: 800), begin: const Offset(1.5, 1.5), end: const Offset(0.8, 0.8));
                    }),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Version Pill with Glassmorphism
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Obx(() => Text(
                      'v${controller.version.value}',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    )),
                  )
                  .animate()
                  .fadeIn(delay: const Duration(milliseconds: 1200))
                  .slideY(begin: 1, end: 0, curve: Curves.easeOut),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlow(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 80,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }
}

class StarsWidget extends StatelessWidget {
  const StarsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: StarsPainter(),
    );
  }
}

class StarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.2);
    final random = math.Random(42);
    
    for (var i = 0; i < 60; i++) {
      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height;
      double radius = random.nextDouble() * 1.5;
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
