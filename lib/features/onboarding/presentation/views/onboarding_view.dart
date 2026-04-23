import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
          // Background Gradient matching the current page
          Obx(() {
            final page = controller.onboardingPages[controller.currentPage.value];
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark 
                    ? [
                        page.gradientColors[0].withValues(alpha: 0.15),
                        AppColors.backgroundDark,
                        AppColors.backgroundDark,
                        page.gradientColors[1].withValues(alpha: 0.15),
                      ]
                    : [
                        page.gradientColors[0].withValues(alpha: 0.05),
                        Colors.white,
                        Colors.white,
                        page.gradientColors[1].withValues(alpha: 0.05),
                      ],
                ),
              ),
            );
          }),

          // PageView Content
          PageView.builder(
            controller: controller.pageController,
            itemCount: controller.onboardingPages.length,
            onPageChanged: controller.onPageChanged,
            itemBuilder: (context, index) {
              final page = controller.onboardingPages[index];
              return Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Icon/Illustration Area
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: page.gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: page.gradientColors[0].withValues(alpha: 0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        page.icon,
                        size: 100,
                        color: Colors.white,
                      ),
                    )
                    .animate(key: ValueKey(index))
                    .scale(duration: const Duration(milliseconds: 600), curve: Curves.easeOutBack)
                    .shimmer(delay: const Duration(milliseconds: 800), duration: const Duration(milliseconds: 1500)),

                    const SizedBox(height: 60),

                    // Title
                    Text(
                      page.title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: 1.2,
                      ),
                    )
                    .animate(key: ValueKey('t$index'))
                    .fadeIn(duration: const Duration(milliseconds: 600))
                    .slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 20),

                    // Description
                    Text(
                      page.description,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        height: 1.5,
                      ),
                    )
                    .animate(key: ValueKey('d$index'))
                    .fadeIn(delay: const Duration(milliseconds: 200), duration: const Duration(milliseconds: 600))
                    .slideY(begin: 0.2, end: 0),
                  ],
                ),
              );
            },
          ),

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
          ).animate().fadeIn(delay: const Duration(milliseconds: 500)),

          // Bottom Navigation
          Positioned(
            bottom: 50,
            left: 30,
            right: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back Button (Hidden on first page)
                Obx(() => AnimatedOpacity(
                  opacity: controller.currentPage.value > 0 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: IconButton(
                    onPressed: controller.currentPage.value > 0 
                      ? controller.previousPage 
                      : null,
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                )),

                // Animated Indicators
                Row(
                  children: List.generate(
                    controller.onboardingPages.length,
                    (index) => Obx(() {
                      bool isSelected = controller.currentPage.value == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: isSelected ? 24 : 8,
                        decoration: BoxDecoration(
                          color: isSelected 
                            ? theme.colorScheme.primary 
                            : theme.colorScheme.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ),

                // Next/Get Started Button
                Obx(() => ElevatedButton(
                  onPressed: controller.nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                    elevation: 10,
                    shadowColor: theme.colorScheme.primary.withValues(alpha: 0.4),
                  ),
                  child: Icon(
                    controller.isLastPage 
                      ? Icons.check_rounded 
                      : Icons.arrow_forward_ios_rounded,
                    size: 24,
                  ),
                ).animate(target: controller.isLastPage ? 1 : 0)
                 .shimmer(delay: const Duration(seconds: 2), duration: const Duration(seconds: 1))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
