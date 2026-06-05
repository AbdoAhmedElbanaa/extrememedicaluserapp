import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../theme/app_colors.dart';
import '../models/notification_model.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Choose icon and color based on notification type
    IconData iconData = Icons.notifications_active_outlined;
    Color iconColor = AppColors.primary;
    
    final titleLower = notification.title.toLowerCase();
    final bodyLower = notification.body.toLowerCase();
    
    if (titleLower.contains('chat') || bodyLower.contains('chat')) {
      iconData = Icons.forum_rounded;
      iconColor = AppColors.secondary;
    } else if (titleLower.contains('ticket') || bodyLower.contains('ticket')) {
      iconData = Icons.assignment_outlined;
      iconColor = AppColors.success;
    } else if (titleLower.contains('resolve') || bodyLower.contains('resolve')) {
      iconData = Icons.check_circle_outline_rounded;
      iconColor = AppColors.skyBlue;
    }

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppColors.errorRed.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          Icons.delete_sweep_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: notification.isRead
              ? (isDark ? AppColors.cinematicSurface.withValues(alpha: 0.4) : Colors.white)
              : (isDark ? AppColors.indigoDeep.withValues(alpha: 0.25) : AppColors.primary.withValues(alpha: 0.04)),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: notification.isRead
                ? (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03))
                : (isDark ? AppColors.primary.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.1)),
            width: 1.2,
          ),
          boxShadow: [
            if (notification.isRead == false)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: isDark ? 0.08 : 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon container (squircle)
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: iconColor.withValues(alpha: 0.15),
                        width: 1.2,
                      ),
                    ),
                    child: Icon(
                      iconData,
                      color: iconColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Text Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  color: isDark ? Colors.white : AppColors.foregroundLight,
                                  fontSize: 14,
                                  fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatTime(notification.receivedAt),
                              style: TextStyle(
                                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          notification.body,
                          style: TextStyle(
                            color: isDark 
                                ? (notification.isRead ? Colors.white60 : Colors.white.withValues(alpha: 0.8)) 
                                : (notification.isRead ? Colors.black54 : Colors.black87),
                            fontSize: 13,
                            fontWeight: notification.isRead ? FontWeight.w400 : FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Unread Indicator Dot
                  if (!notification.isRead) ...[
                    const SizedBox(width: 12),
                    Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary,
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fade(duration: 250.ms).scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOut);
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}
