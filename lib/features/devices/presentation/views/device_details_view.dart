import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../../theme/app_colors.dart';
import '../../data/models/device_model.dart';
import '../widgets/device_status_info_card.dart';
import '../widgets/device_quick_actions_card.dart';
import '../widgets/device_tab_navigation.dart';
import '../widgets/device_info_list_card.dart';
import '../widgets/device_warranty_card.dart';
import '../controllers/device_details_controller.dart';

import 'package:extrememedicaluserapp/core/utils/responsive_layout.dart';

class DeviceDetailsView extends StatelessWidget {
  const DeviceDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    // استلام البيانات أولاً لاستخدام المعرف الفريد كـ Tag
    final DeviceModel? device = (Get.arguments is DeviceModel) ? Get.arguments as DeviceModel : null;

    if (device == null) {
      return _buildErrorState();
    }

    // استخدام tag فريد (الرقم التسلسلي) لمنع تعارض الـ RefreshController
    final controller = Get.put(DeviceDetailsController(), tag: device.serialNumber);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(context, device, controller, isDark),
        tablet: _buildTabletLayout(context, device, controller, isDark),
        desktop: _buildDesktopLayout(context, device, controller, isDark),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, DeviceModel device, DeviceDetailsController controller, bool isDark) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(context, device),
          const SizedBox(height: 10),
          DeviceStatusInfoCard(
            device: device,
            currentValue: '23.1°', 
            label: 'Current Temp',
          ),
          const SizedBox(height: 20),
          Obx(() => DeviceTabNavigation(
            selectedIndex: controller.selectedTabIndex.value,
            onTabChanged: (index) => controller.changeTab(index),
          )),
          const SizedBox(height: 10),
          Expanded(
            child: _buildRefreshContent(device, controller, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, DeviceModel device, DeviceDetailsController controller, bool isDark) {
    return _buildWideLayout(context, device, controller, isDark, isDesktop: false);
  }

  Widget _buildDesktopLayout(BuildContext context, DeviceModel device, DeviceDetailsController controller, bool isDark) {
    return _buildWideLayout(context, device, controller, isDark, isDesktop: true);
  }

  Widget _buildWideLayout(BuildContext context, DeviceModel device, DeviceDetailsController controller, bool isDark, {required bool isDesktop}) {
    return Row(
      children: [
        // Left Column: Status & Info
        Container(
          width: isDesktop ? 400 : 320,
          height: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            border: Border(
              right: BorderSide(
                color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              _buildHeader(context, device),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: DeviceStatusInfoCard(
                  device: device,
                  currentValue: '23.1°', 
                  label: 'Current Temp',
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      DeviceInfoListCard(device: device),
                      const SizedBox(height: 24),
                      DeviceWarrantyCard(device: device),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Right Column: Tabs & Dynamic Content
        Expanded(
          child: Container(
            color: isDark ? AppColors.cinematicSurface.withValues(alpha: 0.2) : Colors.white,
            child: Column(
              children: [
                const SizedBox(height: 40),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Obx(() => DeviceTabNavigation(
                      selectedIndex: controller.selectedTabIndex.value,
                      onTabChanged: (index) => controller.changeTab(index),
                    )),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: _buildRefreshContent(device, controller, isDark, isWide: true),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRefreshContent(DeviceModel device, DeviceDetailsController controller, bool isDark, {bool isWide = false}) {
    return SmartRefresher(
      key: Key('refresher_${device.serialNumber}_${isWide ? "wide" : "mobile"}'),
      controller: isWide ? controller.refreshControllerWide : controller.refreshController,
      onRefresh: controller.onRefresh,
      header: const WaterDropMaterialHeader(
        backgroundColor: AppColors.primary,
        color: Colors.white,
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isWide ? 40 : 0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Obx(() {
                switch (controller.selectedTabIndex.value) {
                  case 0: // Overview
                    return Column(
                      children: [
                        if (!isWide) ...[
                          DeviceInfoListCard(device: device),
                          const SizedBox(height: 25),
                          DeviceWarrantyCard(device: device),
                          const SizedBox(height: 25),
                        ],
                        DeviceQuickActionsCard(
                          onRestart: () => _showActionSnackbar('Restarting', device, isDark),
                          onUpdate: () => _showActionSnackbar('Update', device, isDark),
                          onSettings: () => _showActionSnackbar('Settings', device, isDark),
                        ),
                        const SizedBox(height: 30),
                      ],
                    );
                  case 1: // Stats
                    return _buildStatsPlaceholder(isDark);
                  case 2: // Settings
                    return _buildSettingsPlaceholder(isDark);
                  default:
                    return const SizedBox();
                }
              }),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.errorRed, size: 50),
            const SizedBox(height: 16),
            const Text('Device data could not be loaded.'),
            TextButton(onPressed: () => Get.back(), child: const Text('Go Back')),
          ],
        ),
      ),
    );
  }

  void _showActionSnackbar(String title, DeviceModel device, bool isDark) {
    Get.snackbar(
      title,
      'Executing command for ${device.name}...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      colorText: isDark ? Colors.white : AppColors.primary,
      margin: const EdgeInsets.all(20),
      borderRadius: 15,
      duration: const Duration(seconds: 2),
    );
  }

  Widget _buildStatsPlaceholder(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.bar_chart_rounded, size: 64, color: AppColors.primary.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            'Analytics & History coming soon',
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsPlaceholder(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.settings_suggest_rounded, size: 64, color: AppColors.secondary.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            'Advanced Device Settings coming soon',
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DeviceModel device) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: isDark ? Border.all(color: Colors.white.withValues(alpha: 0.1)) : null,
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: isDark ? Colors.white : AppColors.deepNavy,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.deepNavy,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${device.model} · ${device.serialNumber}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white.withValues(alpha: 0.4) : AppColors.textMutedLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.primary.withValues(alpha: 0.12) : AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isDark ? AppColors.primary.withValues(alpha: 0.2) : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  size: 16,
                  color: isDark ? AppColors.primary : AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Manual',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.primary : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
