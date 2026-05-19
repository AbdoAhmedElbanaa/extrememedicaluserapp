import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';

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
        color: const Color(0xFF6366F1),
      ),
      HelpCategoryItem(
        title: 'Error Codes',
        subtitle: 'Fix errors fast',
        icon: Icons.warning_amber_rounded,
        color: const Color(0xFFEF4444),
      ),
      HelpCategoryItem(
        title: 'Troubleshoot',
        subtitle: 'Step-by-step',
        icon: Icons.build_outlined,
        color: const Color(0xFFF59E0B),
      ),
      HelpCategoryItem(
        title: 'Video Guides',
        subtitle: 'Watch & learn',
        icon: Icons.play_circle_outline_rounded,
        color: const Color(0xFFA855F7),
      ),
      HelpCategoryItem(
        title: 'User Manual',
        subtitle: 'Setup & guides',
        icon: Icons.menu_book_rounded,
        color: const Color(0xFF3B82F6),
      ),
      HelpCategoryItem(
        title: 'Contact Us',
        subtitle: 'Get help now',
        icon: Icons.chat_bubble_outline_rounded,
        color: const Color(0xFF10B981),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Browse Categories',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
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
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark 
            ? item.color.withOpacity(0.08) 
            : item.color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark 
              ? item.color.withOpacity(0.2) 
              : item.color.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.15),
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
                  ? AppColors.mutedForegroundDark.withOpacity(0.7) 
                  : AppColors.mutedForegroundLight,
            ),
          ),
        ],
      ),
    );
  }
}
