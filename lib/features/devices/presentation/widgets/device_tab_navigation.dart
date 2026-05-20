import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

class DeviceTabNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChanged;

  const DeviceTabNavigation({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;
    final List<String> tabs = ['Overview', 'Stats', 'Settings'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.indigoDeep.withValues(alpha: 0.3) : Colors
            .white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black
              .withValues(alpha: 0.03),
        ),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = selectedIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: isSelected
                      ? LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                    ],
                  )
                      : null,
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    tabs[index],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight
                          .w600,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppColors.textMutedDark : AppColors
                          .textMutedLight),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
