import 'dart:ui';

import 'package:extrememedicaluserapp/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/devices_controller.dart';

class DevicesHeader extends GetView<DevicesController> {
  final bool isSidebar;

  const DevicesHeader({super.key, this.isSidebar = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;

    final textColor = isDark ? Colors.white : Colors.black;
    final mutedTextColor = isDark ? AppColors.textMutedDark : Colors.black54;

    if (isSidebar) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'My Devices',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: textColor,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Text(
                '${controller.onlineCount} online · ${controller.warningCount} need attention',
                style: TextStyle(
                  fontSize: 16,
                  color: mutedTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 40),
            _buildSearchBar(isDark, textColor),
            const SizedBox(height: 30),
            Text(
              'FILTERS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: mutedTextColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildSidebarFilters(),
          ],
        ),
      );
    }

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.fromLTRB(20, topPadding + 10, 20, 15),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.backgroundDark.withValues(alpha: 0.7)
                : Colors.white.withValues(alpha: 0.8),
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? AppColors.distinctBorderDark
                    : AppColors.distinctBorderLight,
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row: Title and Top Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Devices',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Obx(
                        () => Text(
                          '${controller.onlineCount} online · ${controller.warningCount} need attention',
                          style: TextStyle(
                            fontSize: 15,
                            color: mutedTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => controller.onRefresh(),
                    child: const _HeaderCircularButton(
                      icon: Icons.refresh_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              _buildSearchBar(isDark, textColor),
              const SizedBox(height: 20),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _CustomFilterChip(
                      label: 'All',
                      count: controller.getCount('All'),
                    ),
                    const SizedBox(width: 10),
                    _CustomFilterChip(
                      label: 'Online',
                      count: controller.getCount('Online'),
                    ),
                    const SizedBox(width: 10),
                    _CustomFilterChip(
                      label: 'Warning',
                      count: controller.getCount('Warning'),
                    ),
                    const SizedBox(width: 10),
                    _CustomFilterChip(
                      label: 'Offline',
                      count: controller.getCount('Offline'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark, Color textColor) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.deepNavy.withValues(alpha: 0.5)
            : AppColors.mutedLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? AppColors.distinctBorderDark
              : AppColors.distinctBorderLight,
        ),
      ),
      child: TextField(
        onChanged: controller.setSearchQuery,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          hintText: 'Search devices...',
          hintStyle: TextStyle(
            color: isDark ? Colors.white30 : Colors.black38,
            fontSize: 16,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Icon(
              Icons.search_rounded,
              color: isDark ? Colors.white30 : Colors.black38,
              size: 26,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget _buildSidebarFilters() {
    return Column(
      children: [
        _buildSidebarFilterItem('All'),
        _buildSidebarFilterItem('Online'),
        _buildSidebarFilterItem('Warning'),
        _buildSidebarFilterItem('Offline'),
      ],
    );
  }

  Widget _buildSidebarFilterItem(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: _CustomFilterChip(
        label: label,
        count: controller.getCount(label),
        isSidebar: true,
      ),
    );
  }
}

class _HeaderCircularButton extends StatelessWidget {
  final IconData icon;

  const _HeaderCircularButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.deepNavy.withValues(alpha: 0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDark
              ? AppColors.distinctBorderDark
              : AppColors.distinctBorderLight,
        ),
      ),
      child: Icon(
        icon,
        size: 22,
        color: isDark
            ? Colors.white.withValues(alpha: 0.7)
            : Colors.black.withValues(alpha: 0.7),
      ),
    );
  }
}

class _CustomFilterChip extends GetView<DevicesController> {
  final String label;
  final int count;
  final bool isSidebar;

  const _CustomFilterChip({
    required this.label,
    required this.count,
    this.isSidebar = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Obx(() {
      final isSelected = controller.selectedFilter.value == label;
      final activeThumbColor = AppColors.primary;
      final activeBg = isDark
          ? AppColors.indigoDeep
          : activeThumbColor.withValues(alpha: 0.1);

      return GestureDetector(
        onTap: () => controller.applyFilter(label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: isSidebar ? double.infinity : null,
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
          decoration: BoxDecoration(
            color: isSelected
                ? activeBg
                : (isDark
                      ? Colors.white.withValues(alpha: 0.03)
                      : Colors.transparent),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? activeThumbColor.withValues(alpha: 0.5)
                  : (isDark
                        ? AppColors.distinctBorderDark
                        : AppColors.distinctBorderLight),
            ),
          ),
          child: Row(
            mainAxisSize: isSidebar ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? (isDark ? AppColors.indigoSoft : activeThumbColor)
                      : (isDark ? Colors.white54 : Colors.black54),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark
                            ? AppColors.backgroundDark.withValues(alpha: 0.5)
                            : activeThumbColor.withValues(alpha: 0.2))
                      : (isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.05)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: isSelected
                        ? (isDark ? AppColors.indigoSoft : activeThumbColor)
                        : (isDark ? Colors.white38 : Colors.black38),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
