import 'package:extrememedicaluserapp/core/services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_helper.dart';

class HeaderWidget extends StatelessWidget {
  final String title;

  const HeaderWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveHelper.isDesktop(context);
    final bool isMobile = ResponsiveHelper.isMobile(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        isMobile ? MediaQuery.of(context).padding.top + 10 : 16,
        16,
        isDesktop ? 0 : 10,
      ),
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0D0C21) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withAlpha(15)
                : Colors.black.withAlpha(10),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 60 : 20),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            if (!isDesktop)
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: Icon(
                    Icons.menu_rounded,
                    color: isDark ? Colors.white : Colors.black87,
                    size: 24,
                  ),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                title.split('/').last.trim(),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),

            const Spacer(),

            // 1. Language Picker
            PopupMenuButton<String>(
              offset: const Offset(0, 55),
              position: PopupMenuPosition.under,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
              elevation: 10,
              onSelected: (lang) {
                if (lang == 'ar') {
                  Get.updateLocale(const Locale('ar', 'EG'));
                } else {
                  Get.updateLocale(const Locale('en', 'US'));
                }
              },
              itemBuilder: (context) => [
                _buildPopupItem('English', '🇺🇸', 'en', isDark),
                _buildPopupItem('العربية', '🇪🇬', 'ar', isDark),
              ],
              child: _HeaderActionCircle(
                icon: Icons.language_rounded,
                isDark: isDark,
              ),
            ),

            const SizedBox(width: 8),

            // 2. Theme Toggle
            _HeaderActionCircle(
              icon: isDark
                  ? Icons.wb_sunny_outlined
                  : Icons.nightlight_round_outlined,
              isDark: isDark,
              onTap: () => ThemeService().switchTheme(),
            ),

            const SizedBox(width: 8),

            // 3. Notification Menu
            PopupMenuButton(
              offset: const Offset(0, 55),
              position: PopupMenuPosition.under,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
              elevation: 10,
              itemBuilder: (context) => [
                PopupMenuItem(
                  enabled: false,
                  child: SizedBox(
                    width: 280,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Notifications',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                'Clear all',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 1),
                      ],
                    ),
                  ),
                ),
                _buildNotificationItem(
                  'System Update',
                  'New features added to dashboard.',
                  'Just now',
                  Icons.auto_awesome_rounded,
                  isDark,
                ),
                _buildNotificationItem(
                  'Security Alert',
                  'New login detected from Cairo.',
                  '2h ago',
                  Icons.security_rounded,
                  isDark,
                  color: AppColors.error,
                ),
                PopupMenuItem(
                  child: Center(
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        'View All',
                        style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black45,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              child: _HeaderActionCircle(
                icon: Icons.notifications_none_rounded,
                isDark: isDark,
                hasBadge: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupItem(
    String title,
    String flag,
    String value,
    bool isDark,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem _buildNotificationItem(
    String title,
    String desc,
    String time,
    IconData icon,
    bool isDark, {
    Color? color,
  }) {
    return PopupMenuItem(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (color ?? AppColors.primary).withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color ?? AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    desc,
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black54,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    time,
                    style: TextStyle(
                      color: isDark ? Colors.white30 : Colors.black26,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderActionCircle extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDark;
  final bool hasBadge;

  const _HeaderActionCircle({
    required this.icon,
    this.onTap,
    required this.isDark,
    this.hasBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark
              ? Colors.white.withAlpha(12)
              : Colors.black.withAlpha(8),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isDark ? Colors.white.withAlpha(220) : Colors.black87,
            ),
            if (hasBadge)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF0D0C21) : Colors.white,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
