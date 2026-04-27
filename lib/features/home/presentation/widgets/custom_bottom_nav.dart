import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import '../controllers/home_controller.dart';

class CustomBottomNav extends GetView<HomeController> {
  final bool isDark;
  const CustomBottomNav({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Padding from screen edges
      padding: const EdgeInsets.only(bottom: 25, left: 16, right: 16),
      child: LayoutBuilder(builder: (context, constraints) {
        // Calculate dynamic width for the sliding effect
        double totalWidth = constraints.maxWidth;
        double itemWidth = totalWidth / 4;
        double selectionWidth = itemWidth - 16; // Adjust selection box width

        return ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30), // Much more blur for cinematic glass effect
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceDark.withOpacity(0.35) // Much more transparent than header
                    : AppColors.surfaceLight.withOpacity(0.4), // Much more transparent than header
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.06)
                      : AppColors.borderLight.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // THE FLUID SLIDING BACKGROUND
                  Obx(() => AnimatedPositioned(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutBack, // Fluid/Watery bounce effect
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
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.1),
                            blurRadius: 15,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                    ),
                  )),

                  // NAVIGATION ITEMS
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
          return SizedBox(
            height: 80, // Matches container height for vertical centering
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with subtle pop-up animation
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected 
                        ? AppColors.primary 
                        : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
                // Indicator Dot
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: isSelected ? 1 : 0,
                  child: Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
