import 'package:extrememedicaluserapp/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/quick_action_model.dart';
import '../controllers/home_controller.dart';

class QuickActionsSection extends GetView<HomeController> {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        // Action Buttons Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: controller.quickActions
              .map(
                (action) =>
                _buildActionButton(action as QuickActionModel, isDark),
          )
              .toList(),
        ),
        const SizedBox(height: 20),
        // Help Center Card
        _buildHelpCenterCard(isDark),
      ],
    );
  }

  Widget _buildActionButton(QuickActionModel action, bool isDark) {
    return Column(
      children: [
        GestureDetector(
          onTap: action.onTap,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: isDark ? AppColors.cinematicSurface : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? action.color.withValues(alpha: 0.2)
                    : action.color.withValues(alpha: 0.1),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: action.color.withValues(alpha: isDark ? 0.15 : 0.05),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(action.icon, color: action.color, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          action.title,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildHelpCenterCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cinematicSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.03),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          // Icon with background
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.help_center_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Help Center',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'FAQs, Error Codes, Tutorials & Support',
                  style: TextStyle(
                    color: (isDark ? Colors.white : Colors.black).withValues(
                      alpha:
                      0.4,
                    ),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          // Arrow
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: (isDark ? Colors.white : Colors.black).withValues(
                alpha: 0.2),
            size: 16,
          ),
        ],
      ),
    );
  }
}
