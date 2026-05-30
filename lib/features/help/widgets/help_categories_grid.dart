import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import 'package:extrememedicaluserapp/core/utils/responsive_layout.dart';
import 'package:extrememedicaluserapp/core/routes/app_routes.dart';
import 'package:extrememedicaluserapp/features/manual/presentation/views/manual_view.dart';
import 'package:extrememedicaluserapp/features/manual/presentation/controllers/manual_controller.dart';

class HelpCategoryItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  HelpCategoryItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

class HelpCategoriesGrid extends StatelessWidget {
  const HelpCategoriesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final List<HelpCategoryItem> categories = [
      HelpCategoryItem(
        title: 'Knowledge Hub',
        subtitle: 'FAQ - Errors - Diagnose',
        icon: Icons.help_outline_rounded,
        color: AppColors.primary,
      ),
      HelpCategoryItem(
        title: 'Error Codes',
        subtitle: 'Fix errors fast',
        icon: Icons.warning_amber_rounded,
        color: AppColors.errorRed,
      ),
      HelpCategoryItem(
        title: 'Troubleshoot',
        subtitle: 'Step-by-step',
        icon: Icons.build_outlined,
        color: AppColors.warning,
      ),
      HelpCategoryItem(
        title: 'Video Guides',
        subtitle: 'Watch & learn',
        icon: Icons.play_circle_outline_rounded,
        color: AppColors.secondary,
      ),
      HelpCategoryItem(
        title: 'User Manual',
        subtitle: 'Setup & guides',
        icon: Icons.menu_book_rounded,
        color: AppColors.bluePrimary,
      ),
      HelpCategoryItem(
        title: 'Contact Us',
        subtitle: 'Get help now',
        icon: Icons.chat_bubble_outline_rounded,
        color: AppColors.success,
      ),
    ];

    final crossAxisCount = context.responsive<int>(2, tablet: 3, desktop: 3);
    final childAspectRatio = context.responsive<double>(
        1.1, tablet: 1.3, desktop: 1.5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Browse Categories',
          style: Theme
              .of(context)
              .textTheme
              .titleLarge
              ?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.isDarkMode
                ? AppColors.foregroundDark
                : AppColors.foregroundLight,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return _CategoryCard(item: categories[index]);
          },
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final HelpCategoryItem item;

  const _CategoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return GestureDetector(
      onTap: () {
        if (item.title == 'Knowledge Hub') {
          Get.toNamed(AppRoutes.knowledgeCenter, arguments: 0);
        } else if (item.title == 'Error Codes') {
          Get.toNamed(AppRoutes.knowledgeCenter, arguments: 2);
        } else if (item.title == 'Troubleshoot') {
          Get.toNamed(AppRoutes.knowledgeCenter, arguments: 3);
        } else if (item.title == 'User Manual') {
          Get.put(ManualController());
          Get.to(() => const ManualView(), transition: Transition.rightToLeftWithFade);
        } else if (item.title == 'Video Guides') {
          Get.toNamed(AppRoutes.videoTutorials);
        } else if (item.title == 'Contact Us') {
          Get.toNamed(AppRoutes.contactSupport);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? item.color.withValues(alpha: 0.08)
            : item.color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? item.color.withValues(alpha: 0.2)
              : item.color.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              item.icon,
              color: item.color,
              size: 24,
            ),
          ),
          const Spacer(),
          Text(
            item.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.subtitle,
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.mutedForegroundDark.withValues(alpha: 0.7)
                  : AppColors.mutedForegroundLight,
            ),
          ),
        ],
      ),
    ),
  );
}
}
