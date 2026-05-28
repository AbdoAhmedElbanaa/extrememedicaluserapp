import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import 'package:extrememedicaluserapp/features/profile/presentation/controllers/profile_controller.dart';

class AccountInfoSection extends GetView<ProfileController> {
  const AccountInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final user = controller.userData.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'ACCOUNT INFORMATION',
              style: TextStyle(
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.cinematicSurface.withValues(alpha: 0.4)
                  : AppColors.surfaceLight.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark
                    ? AppColors.distinctBorderDark
                    : AppColors.distinctBorderLight,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                _buildInfoTile(
                  icon: Icons.person_outline_rounded,
                  iconColor: AppColors.indigoSoft,
                  title: 'Full Name',
                  value: controller.userName.value,
                  isDark: isDark,
                  showDivider: true,
                ),
                _buildInfoTile(
                  icon: Icons.email_outlined,
                  iconColor: AppColors.blueSoft,
                  title: 'Email',
                  value: controller.userEmail.value.isNotEmpty ? controller.userEmail.value : 'N/A',
                  isDark: isDark,
                  showDivider: true,
                ),
                _buildInfoTile(
                  icon: Icons.phone_outlined,
                  iconColor: AppColors.emeraldSoft,
                  title: 'Phone',
                  value: user?.phoneNumber ?? 'N/A',
                  isDark: isDark,
                  showDivider: true,
                ),
                _buildInfoTile(
                  icon: Icons.business_outlined,
                  iconColor: AppColors.purpleSoft,
                  title: 'Clinic',
                  value: user?.clinicName ?? 'N/A',
                  isDark: isDark,
                  showDivider: false,
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildInfoTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required bool isDark,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: iconColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
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
                        color: isDark ? Colors.white : AppColors
                            .foregroundLight,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: TextStyle(
                        color: isDark ? AppColors.textMutedDark : AppColors
                            .textMutedLight,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors
                    .black.withValues(alpha: 0.1),
                size: 14,
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            indent: 76,
            endIndent: 16,
            color: isDark ? AppColors.distinctBorderDark : AppColors
                .distinctBorderLight,
          ),
      ],
    );
  }
}
