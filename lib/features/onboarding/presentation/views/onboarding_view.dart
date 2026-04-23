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
          // Dynamic Background (Image or Gradient)
          PageView.builder(
            controller: controller.pageController,
            itemCount: controller.onboardingPages.length,
            onPageChanged: controller.onPageChanged,
            itemBuilder: (context, index) {
              final page = controller.onboardingPages[index];
              return Stack(
                children: [
                  // 1. Background Layer
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

                  // 2. Professional Color Overlay (Gradient)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.4, 0.8, 1.0],
                          colors: [
                            if (page.isImagePage) ...[
                              Colors.black.withValues(alpha: 0.3),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                              Colors.black.withValues(alpha: 0.9),
                            ] else ...[
                              Colors.transparent,
                              Colors.transparent,
                              (isDark ? AppColors.backgroundDark : Colors.white).withValues(alpha: 0.6),
                              (isDark ? AppColors.backgroundDark : Colors.white),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 3. Content Layer
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(flex: 3),
                        
                        // Icon for non-image pages
                        if (!page.isImagePage)
                          Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(colors: page.gradientColors),
                              boxShadow: [
                                BoxShadow(
                                  color: page.gradientColors[0].withValues(alpha: 0.4),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(page.icon, size: 80, color: Colors.white),
                          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),

                        const Spacer(flex: 1),

                        // Title with glassmorphism container if it's an image page
                        _buildTextContent(context, page, isDark),
                        
                        const Spacer(flex: 2),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          // 4. Fixed UI Elements (Skip, Indicators, Nav)
          _buildFixedUI(context, theme),
        ],
      ),
    );
  }

  Widget _buildTextContent(BuildContext context, dynamic page, bool isDark) {
    return Container(
      padding: page.isImagePage ? const EdgeInsets.all(24) : EdgeInsets.zero,
      decoration: page.isImagePage ? BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ) : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: page.isImagePage ? Colors.white : Theme.of(context).colorScheme.onSurface,
              letterSpacing: 1.2,
              shadows: page.isImagePage ? [const Shadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4))] : null,
            ),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 16),
          
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: page.isImagePage 
                ? Colors.white.withValues(alpha: 0.9) 
                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.5,
              fontSize: 16,
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildFixedUI(BuildContext context, ThemeData theme) {
    return Stack(
      children: [
        // Top Skip Button
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          right: 20,
          child: TextButton(
            onPressed: controller.skip,
            child: Text(
              'Skip',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ).animate().fadeIn(delay: 500.ms),

        // Bottom Navigation Area
        Positioned(
          bottom: 50,
          left: 30,
          right: 30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button
              Obx(() => AnimatedOpacity(
                opacity: controller.currentPage.value > 0 ? 1.0 : 0.0,
                duration: 300.ms,
                child: IconButton(
                  onPressed: controller.currentPage.value > 0 ? controller.previousPage : null,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              )),

              // Animated Indicators
              Row(
                children: List.generate(
                  controller.onboardingPages.length,
                  (index) => Obx(() {
                    bool isSelected = controller.currentPage.value == index;
                    return AnimatedContainer(
                      duration: 300.ms,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 6,
                      width: isSelected ? 24 : 6,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              ),

              // Next Button
              Obx(() => ElevatedButton(
                onPressed: controller.nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(18),
                  elevation: 8,
                ),
                child: Icon(
                  controller.isLastPage ? Icons.check_rounded : Icons.arrow_forward_ios_rounded,
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }
}
