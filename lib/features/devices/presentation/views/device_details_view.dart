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

class DeviceDetailsView extends StatelessWidget {
  const DeviceDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    // استلام البيانات أولاً لاستخدام المعرف الفريد كـ Tag
    final DeviceModel? device = (Get.arguments is DeviceModel) ? Get.arguments as DeviceModel : null;

    if (device == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.red, size: 50),
              const SizedBox(height: 16),
              const Text('Device data could not be loaded.'),
              TextButton(onPressed: () => Get.back(), child: const Text('Go Back')),
            ],
          ),
        ),
      );
    }

    // استخدام tag فريد (الرقم التسلسلي) لمنع تعارض الـ RefreshController
    final controller = Get.put(DeviceDetailsController(), tag: device.serialNumber);
    
    final DeviceModel activeDevice = device;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, activeDevice),
            const SizedBox(height: 10),
            
            // 2. بطاقة حالة الجهاز الاحترافية (تبقى ثابتة)
            DeviceStatusInfoCard(
              device: activeDevice,
              currentValue: '23.1°', 
              label: 'Current Temp',
            ),
            
            const SizedBox(height: 20),

            // 3. التنقل بين التبويبات (يبقى ثابتاً)
            Obx(() => DeviceTabNavigation(
              selectedIndex: controller.selectedTabIndex.value,
              onTabChanged: (index) => controller.changeTab(index),
            )),
            
            const SizedBox(height: 10),

            // 4. منطقة التحديث والمحتوى المتغير
            Expanded(
              child: SmartRefresher(
                key: Key('refresher_${activeDevice.serialNumber}'), // مفتاح فريد لمنع التعارض
                controller: controller.refreshController,
                onRefresh: controller.onRefresh,
                header: WaterDropMaterialHeader(
                  backgroundColor: AppColors.primary,
                  color: Colors.white,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Obx(() {
                        switch (controller.selectedTabIndex.value) {
                          case 0: // Overview
                            return Column(
                              children: [
                                DeviceInfoListCard(device: activeDevice),
                                const SizedBox(height: 25),
                                DeviceWarrantyCard(device: activeDevice),
                                const SizedBox(height: 25),
                                DeviceQuickActionsCard(
                                  onRestart: () => _showActionSnackbar('Restarting', activeDevice, isDark),
                                  onUpdate: () => _showActionSnackbar('Update', activeDevice, isDark),
                                  onSettings: () => _showActionSnackbar('Settings', activeDevice, isDark),
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
            ),
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
                color: isDark ? Colors.white : const Color(0xFF1E1B4B),
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
                    color: isDark ? Colors.white : const Color(0xFF1E1B4B),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${device.model} · ${device.serialNumber}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white.withValues(alpha: 0.4) : const Color(0xFF64748B),
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
              color: isDark ? AppColors.primary.withValues(alpha: 0.12) : const Color(0xFFEEF2FF),
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
                  color: isDark ? AppColors.primary : const Color(0xFF6366F1),
                ),
                const SizedBox(width: 8),
                Text(
                  'Manual',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.primary : const Color(0xFF6366F1),
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
