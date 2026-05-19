import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import 'package:extrememedicaluserapp/core/utils/responsive_layout.dart';
import '../controllers/manual_controller.dart';

class ManualHeader extends GetView<ManualController> {
  const ManualHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isWide = context.isDesktopLayout || context.isTabletLayout;

    return Container(
      constraints: const BoxConstraints(maxWidth: 1400),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: context.responsive(20, tablet: 40, desktop: 60),
        right: context.responsive(20, tablet: 40, desktop: 60),
        bottom: 20,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D0C21) : Colors.white,
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildSquareButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Get.back(),
                isDark: isDark,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Manual',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: context.responsive(22, tablet: 26, desktop: 30),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'SmartThermo Pro - SN-2024-001234',
                      style: TextStyle(
                        color: (isDark ? Colors.white : Colors.black).withOpacity(0.4),
                        fontSize: context.responsive(13, tablet: 14, desktop: 16),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsive(14, tablet: 20),
                  vertical: context.responsive(8, tablet: 12),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.file_download_outlined, color: Color(0xFF6366F1), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'PDF',
                      style: TextStyle(
                        color: const Color(0xFF6366F1),
                        fontSize: context.responsive(13, tablet: 14),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          
          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 3, child: _buildDeviceInfoCard(isDark, context)),
                const SizedBox(width: 20),
                Expanded(flex: 2, child: _buildCategoriesList(isDark, context)),
              ],
            )
          else
            Column(
              children: [
                _buildDeviceInfoCard(isDark, context),
                const SizedBox(height: 20),
                _buildCategoriesList(isDark, context),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDeviceInfoCard(bool isDark, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161531) : const Color(0xFFF5F6FF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.memory_rounded, color: Color(0xFF6366F1), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SmartThermo Pro X',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 2.4 · 48 pages · EN/AR',
                  style: TextStyle(
                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.3),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.greenAccent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.greenAccent,
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList(bool isDark, BuildContext context) {
    return Obx(() => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildCategoryChip(Icons.flash_on_rounded, 'Installation', isDark),
          _buildCategoryChip(Icons.settings_rounded, 'Setup', isDark),
          _buildCategoryChip(Icons.build_rounded, 'Maintenance', isDark),
          _buildCategoryChip(Icons.security_rounded, 'Safety', isDark),
        ],
      ),
    ));
  }

  Widget _buildSquareButton({required IconData icon, required VoidCallback onTap, required bool isDark}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161531) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
          ),
        ),
        child: Icon(icon, color: isDark ? Colors.white : Colors.black, size: 20),
      ),
    );
  }

  Widget _buildCategoryChip(IconData icon, String label, bool isDark) {
    final bool isSelected = controller.selectedCategory.value == label;

    return GestureDetector(
      onTap: () => controller.changeCategory(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFF6366F1).withOpacity(0.1) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF6366F1).withOpacity(0.4) 
                : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon, 
              color: isSelected ? const Color(0xFF6366F1) : (isDark ? Colors.white38 : Colors.black38), 
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF6366F1) : (isDark ? Colors.white38 : Colors.black38),
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
