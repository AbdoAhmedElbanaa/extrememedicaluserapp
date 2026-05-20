import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import 'package:extrememedicaluserapp/core/utils/responsive_layout.dart';

class PopularArticlesWidget extends StatelessWidget {
  const PopularArticlesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final textColor = isDark ? AppColors.foregroundDark : AppColors
        .foregroundLight;

    final articles = [
      _ArticleData(
        title: 'Quick Start Guide',
        subtitle: 'Get up & running in 5 mins',
        icon: Icons.star_outline_rounded,
        iconColor: AppColors.indigoSoft,
        iconBgColor: AppColors.indigoMuted,
      ),
      _ArticleData(
        title: 'Device Won\'t Turn On?',
        subtitle: 'Most common fix',
        icon: Icons.bolt_rounded,
        iconColor: AppColors.amberSoft,
        iconBgColor: AppColors.amberMuted,
      ),
      _ArticleData(
        title: 'Live Chat Support',
        subtitle: 'Online - Avg. response 2 min',
        icon: Icons.chat_bubble_outline_rounded,
        iconColor: AppColors.blueSoft,
        iconBgColor: AppColors.blueMuted,
        isLiveChat: true,
      ),
      _ArticleData(
        title: 'My Support Requests',
        subtitle: 'View & track all your tickets',
        icon: Icons.history_rounded,
        iconColor: AppColors.slateSoft,
        iconBgColor: AppColors.slateMuted,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular Articles',
          style: Theme
              .of(context)
              .textTheme
              .titleLarge
              ?.copyWith(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        if (context.isMobileLayout)
          Column(
            children: articles
                .map((article) => _ArticleItem(data: article))
                .toList(),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: articles.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: context.isTabletLayout ? 2 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 90,
            ),
            itemBuilder: (context, index) =>
                _ArticleItem(data: articles[index]),
          ),
      ],
    );
  }
}

class _ArticleData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final bool isLiveChat;

  _ArticleData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    this.isLiveChat = false,
  });
}

class _ArticleItem extends StatelessWidget {
  final _ArticleData data;

  const _ArticleItem({required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      margin: context.isMobileLayout
          ? const EdgeInsets.only(bottom: 12)
          : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cinematicSurface.withValues(alpha: 0.4)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.distinctBorderDark : AppColors
              .distinctBorderLight,
          width: 1,
        ),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? data.iconBgColor : data.iconColor
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    data.icon,
                    color: data.iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        data.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (data.isLiveChat)
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Online',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          data.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
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
