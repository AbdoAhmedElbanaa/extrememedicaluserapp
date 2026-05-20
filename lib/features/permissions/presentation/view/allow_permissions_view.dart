import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import '../controllers/permissions_controller.dart';

class AllowPermissionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PermissionsController>(() => PermissionsController());
  }
}

class AllowPermissionsView extends GetView<PermissionsController> {
  const AllowPermissionsView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<PermissionsController>()) {
      Get.put(PermissionsController());
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.6),
            radius: 1.0,
            colors: isDark 
              ? [AppColors.indigoDeep, AppColors.backgroundDark]
              : [AppColors.splashGradientLight[1], AppColors.backgroundLight],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 30),
                
                // Top Icon Box
                _buildTopShield(isDark),

                const SizedBox(height: 30),

                // Main Title
                Text(
                  'Allow Permissions',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: isDark ? AppColors.foregroundDark : AppColors.foregroundLight,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 12),

                // Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'UserManual needs a few permissions to give you the best experience',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      height: 1.5,
                    ),
                  ),
                ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 40),

                // Permissions List
                Expanded(
                  child: ListView.separated(
                    itemCount: controller.permissionsList.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = controller.permissionsList[index];
                      return Obx(() {
                        final status = controller.permissionStatuses[item.permission] ?? PermissionStatus.denied;
                        return InkWell(
                          onTap: () => controller.requestSinglePermission(item.permission),
                          borderRadius: BorderRadius.circular(24),
                          overlayColor: WidgetStateProperty.all(AppColors.primary.withValues(alpha: 0.1)),
                          child: _buildPermissionCard(context, item, status, isDark),
                        );
                      });
                    },
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.05, end: 0),
                ),

                // Bottom Action Button
                _buildMainButton(context, isDark),

                const SizedBox(height: 20),

                // Skip Button
                TextButton(
                  onPressed: controller.skipPermissions,
                  child: Text(
                    'Maybe later',
                    style: TextStyle(
                      color: isDark ? AppColors.textMutedDark.withValues(alpha: 0.6) : AppColors.textMutedLight.withValues(alpha: 0.6),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopShield(bool isDark) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: isDark ? AppColors.deepNavy : AppColors.mutedLight,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? AppColors.deepNavyBorder : AppColors.borderLight, 
          width: 1.5
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.05),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.shield_outlined,
          color: AppColors.primary,
          size: 38,
        ),
      ),
    ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack);
  }

  Widget _buildPermissionCard(BuildContext context, dynamic item, PermissionStatus status, bool isDark) {
    bool isGranted = status.isGranted;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.deepNavyDarker : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cinematicSurface : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              item.icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: isDark ? AppColors.foregroundDark : AppColors.foregroundLight,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (item.isRequired)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.indigoDeep : AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Required',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.description,
                  style: TextStyle(
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // Circle Checkbox
          const SizedBox(width: 10),
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isGranted ? AppColors.success : (isDark ? AppColors.deepNavyBorder : AppColors.borderLight),
                width: 2,
              ),
              color: isGranted ? AppColors.success : Colors.transparent,
            ),
            child: isGranted 
              ? const Icon(Icons.check, size: 16, color: Colors.white) 
              : null,
          ),
        ],
      ),
    );
  }

  Widget _buildMainButton(BuildContext context, bool isDark) {
    return Obx(() {
      final allGranted = controller.permissionsList.every((item) {
        final status = controller.permissionStatuses[item.permission] ?? PermissionStatus.denied;
        return status.isGranted;
      });

      return Container(
        width: double.infinity,
        height: 65,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: allGranted
                ? [AppColors.success, AppColors.emeraldDark]
                : [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.8),
                    AppColors.bluePrimary,
                  ],
          ),
          boxShadow: [
            BoxShadow(
              color: (allGranted ? AppColors.success : AppColors.primary).withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: allGranted ? controller.goToNextScreen : controller.requestAllPermissions,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                allGranted ? 'All Done! Let\'s Start' : 'Allow All Permissions',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                allGranted ? Icons.check_circle_rounded : Icons.arrow_forward_ios_rounded,
                size: 20,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ).animate(target: allGranted ? 1 : 0).shimmer(duration: const Duration(seconds: 1));
    });
  }
}
