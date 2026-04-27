import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import 'package:extrememedicaluserapp/core/utils/responsive_layout.dart';
import '../controllers/home_controller.dart';

class CustomBottomNav extends GetView<HomeController> {
  final bool isDark;
  const CustomBottomNav({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    // If it's desktop, we might want a different navigation or none at all at the bottom
    if (context.isDesktopLayout) return const SizedBox.shrink();

    return Container(
      // Responsive padding
      padding: EdgeInsets.only(
        bottom: context.responsive(25, tablet: 30),
        left: context.responsive(16, tablet: 100),
        right: context.responsive(16, tablet: 100),
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        double totalWidth = constraints.maxWidth;
        double itemWidth = totalWidth / 4;
        double selectionWidth = itemWidth - 16;

        return ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceDark.withOpacity(0.35)
                    : AppColors.surfaceLight.withOpacity(0.4),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.06)
                      : AppColors.borderLight.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Obx(() => AnimatedPositioned(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutBack,
                    left: (controller.selectedIndex.value * itemWidth) + 8,
                    top: 10,
                    child: Container(
                      width: selectionWidth,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 1.2,
                        ),
                      ),
                    ),
                  )),

                  Row(
                    children: [
                      _buildNavItem(0, Icons.home_outlined, 'Home'),
                      _buildNavItem(1, Icons.layers_outlined, 'Devices'),
                      _buildNavItem(2, Icons.help_outline_rounded, 'Help'),
                      _buildNavItem(3, Icons.person_outline_rounded, 'Profile'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changeIndex(index),
        behavior: HitTestBehavior.opaque,
        child: Obx(() {
          final isSelected = controller.selectedIndex.value == index;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                transform: Matrix4.translationValues(0, isSelected ? -2 : 0, 0),
                child: Icon(
                  icon,
                  color: isSelected 
                      ? AppColors.primary 
                      : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                  size: isSelected ? 26 : 24,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: isSelected 
                      ? AppColors.primary 
                      : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
