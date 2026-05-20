import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import 'package:extrememedicaluserapp/core/utils/responsive_layout.dart';
import '../controllers/settings_controller.dart';
import '../widgets/theme_mode_selector.dart';
import '../widgets/settings_list.dart';
import '../widgets/account_settings_section.dart';
import '../widgets/security_settings_section.dart';
import '../widgets/notifications_settings_section.dart';
import '../widgets/devices_sync_settings_section.dart';
import '../widgets/appearance_settings_section.dart';
import '../widgets/language_region_settings_section.dart';
import '../widgets/subscription_billing_settings_section.dart';
import '../widgets/about_settings_section.dart';
import '../widgets/reset_settings_section.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(context, isDark, controller),
        tablet: _buildWideLayout(context, isDark, controller, isTablet: true),
        desktop: _buildWideLayout(context, isDark, controller, isTablet: false),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, bool isDark, SettingsController controller) {
    return Column(
      children: [
        _buildHeader(context, isDark),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: const Column(
              children: [
                ThemeModeSelector(),
                SizedBox(height: 24),
                SettingsList(),
                SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWideLayout(BuildContext context, bool isDark, SettingsController controller, {required bool isTablet}) {
    final sidebarWidth = isTablet ? 300.0 : 350.0;
    
    return Row(
      children: [
        // Sidebar
        Container(
          width: sidebarWidth,
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            border: Border(
              right: BorderSide(
                color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              _buildHeader(context, isDark, isWide: true),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: ThemeModeSelector(),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _buildSidebarList(isDark, controller),
              ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: Container(
            color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            child: Column(
              children: [
                _buildContentHeader(isDark, controller),
                Expanded(
                  child: Obx(() => _buildSelectedSection(controller.selectedCategoryIndex.value)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentHeader(bool isDark, SettingsController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      alignment: Alignment.centerLeft,
      child: Obx(() {
        final title = _getCategoryTitle(controller.selectedCategoryIndex.value);
        final isTablet = MediaQuery.of(Get.context!).size.width < 1100;
        return Text(
          title,
          style: TextStyle(
            fontSize: isTablet ? 24 : 32,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.foregroundLight,
          ),
        );
      }),
    );
  }

  String _getCategoryTitle(int index) {
    switch (index) {
      case 0: return 'Account';
      case 1: return 'Security';
      case 2: return 'Notifications';
      case 3: return 'Devices & Sync';
      case 4: return 'Appearance';
      case 5: return 'Language & Region';
      case 6: return 'Subscription & Billing';
      case 7: return 'About';
      case 8: return 'Reset Settings';
      default: return 'Settings';
    }
  }

  Widget _buildSidebarList(bool isDark, SettingsController controller) {
    final categories = [
      {'title': 'Account', 'icon': Icons.person_outline_rounded},
      {'title': 'Security', 'icon': Icons.security_outlined},
      {'title': 'Notifications', 'icon': Icons.notifications_none_rounded},
      {'title': 'Devices & Sync', 'icon': Icons.sync_rounded},
      {'title': 'Appearance', 'icon': Icons.palette_outlined},
      {'title': 'Language & Region', 'icon': Icons.language_rounded},
      {'title': 'Subscription & Billing', 'icon': Icons.account_balance_wallet_outlined},
      {'title': 'About', 'icon': Icons.info_outline_rounded},
      {'title': 'Reset Settings', 'icon': Icons.restore_rounded},
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return Obx(() {
          final isSelected = controller.selectedCategoryIndex.value == index;
          final item = categories[index];
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => controller.selectedCategoryIndex.value = index,
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.primary.withValues(alpha: 0.1) 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      color: isSelected ? AppColors.primary : (isDark ? Colors.white70 : Colors.black54),
                      size: 22,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      item['title'] as String,
                      style: TextStyle(
                        color: isSelected ? AppColors.primary : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    if (isSelected) ...[
                      const Spacer(),
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildSelectedSection(int index) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _getSectionWidget(index),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _getSectionWidget(int index) {
    switch (index) {
      case 0: return const AccountSettingsSection();
      case 1: return const SecuritySettingsSection();
      case 2: return const NotificationsSettingsSection();
      case 3: return const DevicesSyncSettingsSection();
      case 4: return const AppearanceSettingsSection();
      case 5: return const LanguageRegionSettingsSection();
      case 6: return const SubscriptionBillingSettingsSection();
      case 7: return const AboutSettingsSection();
      case 8: return const ResetSettingsSection();
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildHeader(BuildContext context, bool isDark, {bool isWide = false}) {
    final topPadding = MediaQuery.of(context).padding.top;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: topPadding + 10,
            bottom: 20,
            left: isWide ? 24 : context.responsive(20, tablet: 50, desktop: 80),
            right: isWide ? 24 : context.responsive(20, tablet: 50, desktop: 80),
          ),
          decoration: BoxDecoration(
            color: isDark 
                ? AppColors.backgroundDark.withValues(alpha: 0.7) 
                : AppColors.backgroundLight.withValues(alpha: 0.7),
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              _buildBackButton(isDark),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settings',
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.foregroundLight,
                        fontSize: isWide ? 22 : 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Manage preferences',
                      style: TextStyle(
                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(bool isDark) {
    return GestureDetector(
      onTap: () => Get.back(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.05) 
              : AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
            width: 1,
          ),
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: isDark ? Colors.white70 : AppColors.primary,
        ),
      ),
    );
  }
}
