import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../theme/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';
import '../controllers/notifications_controller.dart';
import '../models/notification_model.dart';
import '../widgets/notification_tile.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : AppColors.foregroundLight,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.foregroundLight,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(() {
            if (controller.notifications.isEmpty) return const SizedBox();
            return IconButton(
              icon: Icon(
                Icons.mark_email_read_outlined,
                color: isDark ? Colors.white70 : AppColors.foregroundLight,
                size: 22,
              ),
              tooltip: 'Mark all as read',
              onPressed: () => _showMarkAllAsReadConfirm(context),
            );
          }),
          Obx(() {
            if (controller.notifications.isEmpty) return const SizedBox();
            return IconButton(
              icon: const Icon(
                Icons.delete_sweep_outlined,
                color: AppColors.errorRed,
                size: 22,
              ),
              tooltip: 'Clear all',
              onPressed: () => _showClearAllConfirm(context),
            );
          }),
        ],
      ),
      body: Obx(() {
        final list = controller.notifications;
        if (list.isEmpty) {
          return _buildEmptyState(isDark);
        }
        return _buildNotificationsList(context, list, isDark);
      }),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.05),
                    blurRadius: 40,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.notifications_off_outlined,
                color: AppColors.primary,
                size: 44,
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
            const SizedBox(height: 28),
            Text(
              'No notifications yet',
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.foregroundLight,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 8),
            Text(
              "You're all caught up! When you receive alerts or status updates, they'll appear here.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                fontSize: 14,
                height: 1.5,
              ),
            ).animate().fadeIn(delay: 350.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList(BuildContext context, List<NotificationModel> list, bool isDark) {
    // Group notifications by date
    final today = <NotificationModel>[];
    final yesterday = <NotificationModel>[];
    final older = <NotificationModel>[];

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final yesterdayStart = todayStart.subtract(const Duration(days: 1));

    for (final item in list) {
      if (item.receivedAt.isAfter(todayStart)) {
        today.add(item);
      } else if (item.receivedAt.isAfter(yesterdayStart)) {
        yesterday.add(item);
      } else {
        older.add(item);
      }
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: context.responsive(20, tablet: 80, desktop: 120),
        vertical: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (today.isNotEmpty) ...[
            _buildSectionHeader('Today', isDark),
            ...today.map((item) => _buildTile(item)),
            const SizedBox(height: 16),
          ],
          if (yesterday.isNotEmpty) ...[
            _buildSectionHeader('Yesterday', isDark),
            ...yesterday.map((item) => _buildTile(item)),
            const SizedBox(height: 16),
          ],
          if (older.isNotEmpty) ...[
            _buildSectionHeader('Older', isDark),
            ...older.map((item) => _buildTile(item)),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTile(NotificationModel item) {
    return NotificationTile(
      notification: item,
      onTap: () => controller.handleNotificationTap(item),
      onDelete: () => controller.deleteNotification(item.id),
    );
  }

  void _showMarkAllAsReadConfirm(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Mark all as read?'),
        content: const Text('Do you want to mark all received notifications as read?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.primary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              controller.markAllAsRead();
              Get.back();
            },
            child: const Text('Mark Read', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showClearAllConfirm(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Clear all notifications?'),
        content: const Text('This action will delete all notifications. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.primary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              controller.clearAll();
              Get.back();
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
