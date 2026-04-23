import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:extrememedicaluserapp/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(OnboardingController());
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Dynamic Background & Floating Elements Layer
          PageView.builder(
            controller: controller.pageController,
            itemCount: controller.onboardingPages.length,
            onPageChanged: controller.onPageChanged,
            itemBuilder: (context, index) {
              final page = controller.onboardingPages[index];
              return Stack(
                children: [
                  // Background
                  if (page.isImagePage)
                    Positioned.fill(
                      child: CachedNetworkImage(
                        imageUrl: page.imagePath!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: page.gradientColors[0]),
                      ),
                    )
                  else
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isDark 
                              ? [
                                  page.gradientColors[0].withValues(alpha: 0.2),
                                  AppColors.backgroundDark,
                                  page.gradientColors[1].withValues(alpha: 0.2),
                                ]
                              : [
                                  page.gradientColors[0].withValues(alpha: 0.1),
                                  Colors.white,
                                  page.gradientColors[1].withValues(alpha: 0.1),
                                ],
                          ),
                        ),
                      ),
                    ),

                  // Floating Particles/Icons Layer
                  const Positioned.fill(
                    child: FloatingIconsOverlay(),
                  ),

                  // Professional Gradient Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.3, 0.6, 1.0],
                          colors: [
                            Colors.black.withValues(alpha: page.isImagePage ? 0.4 : 0.0),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.5),
                            Colors.black.withValues(alpha: 0.9),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Non-Image Page Centered Icon
                  if (!page.isImagePage)
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(colors: page.gradientColors),
                              boxShadow: [
                                BoxShadow(
                                  color: page.gradientColors[0].withValues(alpha: 0.4),
                                  blurRadius: 40,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(page.icon, size: 90, color: Colors.white),
                          ).animate().scale(duration: const Duration(milliseconds: 800), curve: Curves.easeOutBack).shimmer(delay: const Duration(seconds: 1), duration: const Duration(seconds: 2)),
                          const SizedBox(height: 150), // Space for bottom content
                        ],
                      ),
                    ),
                ],
              );
            },
          ),

          // 2. Bottom Content & Fixed UI
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 40, bottom: 140, left: 30, right: 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Obx(() {
                final page = controller.onboardingPages[controller.currentPage.value];
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      page.title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.5,
                        fontSize: 32,
                        shadows: [const Shadow(color: Colors.black, blurRadius: 15)],
                      ),
                    ).animate(key: ValueKey('title${controller.currentPage.value}'))
                     .fadeIn(duration: const Duration(milliseconds: 600))
                     .slideY(begin: 0.3, end: 0),
                    
                    const SizedBox(height: 20),
                    
                    Text(
                      page.description,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        height: 1.6,
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                      ),
                    ).animate(key: ValueKey('desc${controller.currentPage.value}'))
                     .fadeIn(delay: const Duration(milliseconds: 200), duration: const Duration(milliseconds: 600))
                     .slideY(begin: 0.3, end: 0),
                  ],
                );
              }),
            ),
          ),

          // 3. Navigation Controls
          _buildNavigationUI(context, theme),
        ],
      ),
    );
  }

  Widget _buildNavigationUI(BuildContext context, ThemeData theme) {
    return Stack(
      children: [
        // Top Skip
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          right: 20,
          child: Obx(() => AnimatedOpacity(
            opacity: controller.isLastPage ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 400),
            child: IgnorePointer(
              ignoring: controller.isLastPage,
              child: TextButton(
                onPressed: controller.skip,
                child: const Text(
                  'SKIP',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          )),
        ).animate().fadeIn(delay: const Duration(milliseconds: 500)),

        // Bottom Bar Area
        Positioned(
          bottom: 50,
          left: 30,
          right: 30,
          child: SizedBox(
            height: 65,
            child: Obx(() {
              bool isLast = controller.isLastPage;
              bool showBack = controller.currentPage.value > 0;
              return Stack(
                alignment: Alignment.centerRight,
                children: [
                  // 1. Back Button (Always stays on the left)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AnimatedOpacity(
                      opacity: showBack ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: IconButton(
                        onPressed: showBack ? controller.previousPage : null,
                        icon: const Icon(Icons.keyboard_backspace_rounded, size: 30),
                        color: Colors.white70,
                      ),
                    ),
                  ),

                  // 2. Indicators (Fade out when last page)
                  Align(
                    alignment: Alignment.center,
                    child: AnimatedOpacity(
                      opacity: isLast ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 400),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          controller.onboardingPages.length,
                          (index) => Obx(() {
                            bool isSelected = controller.currentPage.value == index;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              height: 5,
                              width: isSelected ? 30 : 10,
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: isSelected ? [
                                  BoxShadow(color: Colors.white.withValues(alpha: 0.5), blurRadius: 10)
                                ] : null,
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),

                  // 3. Action Button (Expands from right to cover center)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOutCubic,
                    width: isLast ? Get.width - 120 : 65,
                    height: 65,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(isLast ? 20 : 35),
                      boxShadow: [
                        BoxShadow(
                          color: (isLast ? theme.colorScheme.primary : Colors.white)
                              .withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: controller.nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLast ? theme.colorScheme.primary : Colors.white,
                        foregroundColor: isLast ? Colors.white : theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(isLast ? 20 : 35),
                        ),
                        padding: EdgeInsets.zero,
                        elevation: 0,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: isLast
                            ? const Text(
                                'GET STARTED',
                                key: ValueKey('btn_text'),
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                  fontSize: 16,
                                ),
                              ).animate().fadeIn(delay: const Duration(milliseconds: 200)).scale(begin: const Offset(0.8, 0.8))
                            : const Icon(
                                Icons.arrow_forward_ios_rounded,
                                key: ValueKey('btn_icon'),
                                size: 26,
                              ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class FloatingIconsOverlay extends StatelessWidget {
  const FloatingIconsOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final icons = [
      Icons.favorite_rounded,
      Icons.add_circle_outline_rounded,
      Icons.health_and_safety_rounded,
      Icons.emergency_rounded,
      Icons.biotech_rounded,
    ];

    return Stack(
      children: List.generate(12, (index) {
        final random = math.Random(index);
        final size = 20.0 + random.nextDouble() * 30.0;
        final startX = random.nextDouble() * 400;
        final startY = random.nextDouble() * 800;
        
        return Positioned(
          left: startX,
          top: startY,
          child: Opacity(
            opacity: 0.15,
            child: Icon(
              icons[random.nextInt(icons.length)],
              size: size,
              color: Colors.white,
            ),
          )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .move(
            duration: Duration(milliseconds: 4000 + random.nextInt(4000)),
            begin: const Offset(0, 0),
            end: Offset(random.nextDouble() * 40 - 20, random.nextDouble() * 40 - 20),
            curve: Curves.easeInOut,
          )
          .rotate(duration: const Duration(seconds: 10), end: 1),
        );
      }),
    );
  }
}
