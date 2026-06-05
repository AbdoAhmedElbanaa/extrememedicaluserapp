import 'package:extrememedicaluserapp/features/auth/services/auth_service.dart';
import 'package:extrememedicaluserapp/core/routes/app_routes.dart';
import 'package:extrememedicaluserapp/features/profile/presentation/controllers/profile_controller.dart';
import 'package:extrememedicaluserapp/core/utils/responsive_layout.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/features/notifications/services/notifications_service.dart';

import '../controllers/home_controller.dart';

class UserProfilePopup extends StatelessWidget {
  const UserProfilePopup({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final homeController = Get.find<HomeController>();
    final profileController = Get.isRegistered<ProfileController>() 
        ? Get.find<ProfileController>() 
        : Get.put(ProfileController());

    return Stack(
      children: [
        // Barrier for closing on outside tap
        Positioned.fill(
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(color: Colors.black.withValues(alpha: 0.4)),
          ),
        ),

        // Popup Content
        Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: context.responsive(
                MediaQuery.of(context).size.width * 0.9,
                tablet: 400,
                desktop: 400,
              ),
              constraints: const BoxConstraints(maxHeight: 700),
              margin: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cinematicSurface : Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: isDark
                      ? AppColors.distinctBorderDark
                      : AppColors.distinctBorderLight,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Section (Profile Info)
                  _buildHeader(isDark, profileController),

                  Divider(
                    height: 1,
                    thickness: 1,
                    color: isDark
                        ? Colors.white10
                        : Colors.black.withValues(alpha: 0.05),
                  ),

                  // Menu Items
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        children: [
                          _buildMenuItem(
                            Icons.person_outline_rounded,
                            'View Profile',
                            isDark,
                            onTap: () {
                              Get.back(); // Close popup
                              homeController.changeIndex(
                                3,
                              ); // Switch to Profile tab
                            },
                          ),
                          _buildMenuItem(
                            Icons.settings_outlined,
                            'Account Settings',
                            isDark,
                          ),
                          _buildMenuItem(
                            Icons.layers_outlined,
                            'My Devices',
                            isDark,
                            onTap: () {
                              Get.back();
                              homeController.changeIndex(
                                1,
                              ); // Switch to Devices tab
                            },
                          ),
                          Obx(() {
                            final count = Get.isRegistered<NotificationsService>()
                                ? NotificationsService.to.unreadCount.value
                                : 0;
                            return _buildMenuItem(
                              Icons.notifications_none_rounded,
                              'Notifications',
                              isDark,
                              hasUpdate: count > 0,
                              onTap: () {
                                Get.back(); // Close popup
                                Get.toNamed(AppRoutes.notifications);
                              },
                            );
                          }),
                          _buildMenuItem(
                            Icons.security_outlined,
                            'Security',
                            isDark,
                          ),
                          _buildMenuItem(
                            Icons.credit_card_outlined,
                            'Billing & Subscription',
                            isDark,
                          ),
                          _buildMenuItem(
                            Icons.help_outline_rounded,
                            'Help Center',
                            isDark,
                            onTap: () {
                              Get.back();
                              homeController.changeIndex(
                                2,
                              ); // Switch to Help tab
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Sign Out Section
                  _buildSignOutButton(isDark),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(bool isDark, ProfileController profileController) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Avatar with Glow
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.indigoPrimaryDark],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Obx(() => Text(
                profileController.userName.value.isNotEmpty 
                    ? profileController.userName.value.substring(0, 1).toUpperCase() 
                    : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              )),
            ),
          ),
          const SizedBox(width: 16),
          // Name & Email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => Text(
                      profileController.userName.value,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Icon(
                        Icons.close_rounded,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.3)
                            : Colors.black26,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                Obx(() => Text(
                  profileController.userEmail.value,
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.4)
                        : Colors.black45,
                    fontSize: 14,
                  ),
                )),
                const SizedBox(height: 10),
                // Premium Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.success,
                        radius: 3,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Premium Active',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    bool isDark, {
    bool hasUpdate = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.deepNavy
                      : AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isDark ? Colors.white70 : AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.9)
                        : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (hasUpdate)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.warning,
                    shape: BoxShape.circle,
                  ),
                ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.black12,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignOutButton(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: InkWell(
        onTap: () async {
          await Get.find<AuthService>().signOut();
          Get.offAllNamed(AppRoutes.login);
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.errorRed.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.errorRed.withValues(alpha: 0.1),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: AppColors.errorRed, size: 20),
              SizedBox(width: 12),
              Text(
                'Sign Out',
                style: TextStyle(
                  color: AppColors.errorRed,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
