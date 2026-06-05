import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import '../controllers/settings_controller.dart';
import 'settings_expandable_tile.dart';
import 'settings_sub_tile.dart';

class NotificationsSettingsSection extends GetView<SettingsController> {
  const NotificationsSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SettingsExpandableTile(
      icon: Icons.notifications_none_rounded,
      iconColor: AppColors.amberSoft,
      title: 'Notifications',
      canExpand: isMobile,
      initiallyExpanded: !isMobile,
      showHeader: isMobile,
      children: [
        Obx(() => SettingsSubTile(
          icon: Icons.notifications_none_rounded,
          iconColor: AppColors.amberSoft,
          title: 'Push Notifications',
          subtitle: 'Alerts on your device',
          trailing: Switch.adaptive(
            value: controller.pushEnabled.value,
            onChanged: (v) => controller.togglePushNotifications(v),
            activeTrackColor: AppColors.amberSoft,
          ),
        )),
        
        // Push notification options shown conditionally
        Obx(() {
          if (!controller.pushEnabled.value) return const SizedBox.shrink();
          return Column(
            children: [
              Obx(() => SettingsSubTile(
                icon: Icons.chat_bubble_outline_rounded,
                iconColor: AppColors.primary,
                title: 'Chat Alerts',
                subtitle: 'Get notified of support responses',
                trailing: Switch.adaptive(
                  value: controller.chatAlertsEnabled.value,
                  onChanged: (v) => controller.toggleChatAlerts(v),
                  activeTrackColor: AppColors.primary,
                ),
              )),
              Obx(() => SettingsSubTile(
                icon: Icons.assignment_outlined,
                iconColor: AppColors.secondary,
                title: 'Ticket Progress',
                subtitle: 'Notify on ticket status updates',
                trailing: Switch.adaptive(
                  value: controller.ticketAlertsEnabled.value,
                  onChanged: (v) => controller.toggleTicketAlerts(v),
                  activeTrackColor: AppColors.secondary,
                ),
              )),
              Obx(() => SettingsSubTile(
                icon: Icons.warning_amber_rounded,
                iconColor: AppColors.errorRed,
                title: 'Critical Device Alerts',
                subtitle: 'Notify on hardware errors',
                trailing: Switch.adaptive(
                  value: controller.errorAlertsEnabled.value,
                  onChanged: (v) => controller.toggleErrorAlerts(v),
                  activeTrackColor: AppColors.errorRed,
                ),
              )),
            ],
          );
        }),

        Obx(() => SettingsSubTile(
          icon: Icons.mail_outline_rounded,
          iconColor: AppColors.blueSoft,
          title: 'Email Notifications',
          subtitle: 'Summary emails',
          trailing: Switch.adaptive(
            value: controller.emailEnabled.value,
            onChanged: (v) => controller.toggleEmailNotifications(v),
            activeTrackColor: AppColors.blueSoft,
          ),
        )),
        SettingsSubTile(
          icon: Icons.schedule_rounded,
          iconColor: AppColors.purpleSoft,
          title: 'Notification Schedule',
          subtitle: 'Quiet hours & timing',
          showDivider: false,
          onTap: () {},
        ),

        // Premium OneSignal status/Player ID widget
        Obx(() {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final isSubscribed = controller.onesignalSubscribed.value;
          final playerId = controller.onesignalPlayerId.value;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark 
                  ? AppColors.cardDark.withValues(alpha: 0.5) 
                  : AppColors.cardLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Push Integration',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.foregroundLight,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSubscribed 
                            ? AppColors.success.withValues(alpha: 0.15) 
                            : AppColors.destructive.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 6,
                            color: isSubscribed ? AppColors.success : AppColors.destructive,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isSubscribed ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isSubscribed ? AppColors.success : AppColors.destructive,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Your Device Subscription ID:',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black.withValues(alpha: 0.3) : AppColors.inputBackgroundLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          playerId.isNotEmpty ? playerId : 'Loading Device ID...',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                            color: isDark ? Colors.white70 : AppColors.foregroundLight,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        Icons.copy_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      onPressed: playerId.isNotEmpty 
                          ? () {
                              Clipboard.setData(ClipboardData(text: playerId));
                              Get.snackbar(
                                'Copied',
                                'Subscription ID copied to clipboard.',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                colorText: AppColors.primary,
                              );
                            }
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
