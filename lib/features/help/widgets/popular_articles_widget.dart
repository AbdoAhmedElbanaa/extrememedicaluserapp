import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';

class PopularArticlesWidget extends StatelessWidget {
  const PopularArticlesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final textColor = isDark ? AppColors.foregroundDark : AppColors.foregroundLight;
    final subtitleColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular Articles',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
        ),
        const SizedBox(height: 16),
        _ArticleItem(
          title: 'Quick Start Guide',
          subtitle: 'Get up & running in 5 mins',
          icon: Icons.star_outline_rounded,
          iconColor: const Color(0xFF818CF8),
          iconBgColor: const Color(0xFF1E1B4B),
          onTap: () {},
        ),
        _ArticleItem(
          title: 'Device Won\'t Turn On?',
          subtitle: 'Most common fix',
          icon: Icons.bolt_rounded,
          iconColor: const Color(0xFFFBBF24),
          iconBgColor: const Color(0xFF451A03),
          onTap: () {},
        ),
        _ArticleItem(
          title: 'Live Chat Support',
          subtitle: 'Online - Avg. response 2 min',
          icon: Icons.chat_bubble_outline_rounded,
          iconColor: const Color(0xFF60A5FA),
          iconBgColor: const Color(0xFF172554),
          isLiveChat: true,
          onTap: () {},
        ),
        _ArticleItem(
          title: 'My Support Requests',
          subtitle: 'View & track all your tickets',
          icon: Icons.history_rounded,
          iconColor: const Color(0xFF94A3B8),
          iconBgColor: const Color(0xFF0F172A),
          onTap: () {},
        ),
      ],
    );
  }
}

class _ArticleItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final VoidCallback onTap;
  final bool isLiveChat;

  const _ArticleItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.onTap,
    this.isLiveChat = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cinematicSurface.withOpacity(0.4) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? iconBgColor : iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (isLiveChat)
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Online',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                            Text(
                              ' - ${subtitle.split(' - ').last}',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white54 : Colors.black54,
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? Colors.white24 : Colors.black26,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
