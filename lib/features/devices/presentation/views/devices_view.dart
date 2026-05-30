import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:extrememedicaluserapp/core/routes/app_routes.dart';
import '../controllers/devices_controller.dart';
import '../widgets/devices_header.dart';
import '../widgets/device_card.dart';
import 'package:extrememedicaluserapp/core/utils/responsive_layout.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import '../widgets/add_device_sheet.dart';

class DevicesView extends GetView<DevicesController> {
  const DevicesView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(context, isDark),
        tablet: _buildTabletLayout(context, isDark),
        desktop: _buildDesktopLayout(context, isDark),
      ),
      floatingActionButton: ResponsiveLayout.isMobile(context)
          ? _buildFAB(isDark)
          : const SizedBox.shrink(),
    );
  }

  Widget _buildMobileLayout(BuildContext context, bool isDark) {
    return Column(
      children: [
        const DevicesHeader(),
        Expanded(
          child: SmartRefresher(
            controller: controller.refreshController,
            onRefresh: controller.onRefresh,
            header: const WaterDropMaterialHeader(
              backgroundColor: AppColors.primary,
              color: Colors.white,
            ),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                const SliverToBoxAdapter(
                  child: SizedBox(height: 15),
                ),
                _buildDeviceGrid(context),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 120),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context, bool isDark) {
    return _buildWideLayout(context, isDark, isDesktop: false);
  }

  Widget _buildDesktopLayout(BuildContext context, bool isDark) {
    return _buildWideLayout(context, isDark, isDesktop: true);
  }

  Widget _buildWideLayout(BuildContext context, bool isDark,
      {required bool isDesktop}) {
    return Row(
      children: [
        // Sidebar Header for Wide Screens
        Container(
          width: isDesktop ? 350 : 300,
          height: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? AppColors.backgroundDark : AppColors
                .backgroundLight,
            border: Border(
              right: BorderSide(
                color: isDark ? AppColors.distinctBorderDark : AppColors
                    .distinctBorderLight,
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              Expanded(child: DevicesHeader(isSidebar: true)),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: _buildAddDeviceButton(isDark),
              ),
            ],
          ),
        ),

        // Main Content Area
        Expanded(
          child: SmartRefresher(
            controller: controller.refreshControllerWide,
            onRefresh: controller.onRefresh,
            header: const WaterDropMaterialHeader(
              backgroundColor: AppColors.primary,
              color: Colors.white,
            ),
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
                _buildDeviceGrid(context),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceGrid(BuildContext context) {
    return Obx(() {
      if (controller.filteredDevices.isEmpty) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: _buildEmptyState(Theme
              .of(context)
              .brightness == Brightness.dark),
        );
      }

      final crossAxisCount = context.responsive<int>(1, tablet: 2, desktop: 3);

      return SliverPadding(
        padding: EdgeInsets.symmetric(
          horizontal: context.responsive<double>(20, tablet: 30, desktop: 40),
        ),
        sliver: crossAxisCount == 1
            ? SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) =>
                DeviceCard(
                  device: controller.filteredDevices[index],
                  onTap: () {
                    Get.toNamed(
                      AppRoutes.deviceDetails,
                      arguments: controller.filteredDevices[index],
                    );
                  },
                ),
            childCount: controller.filteredDevices.length,
          ),
        )
            : SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: context.responsive<double>(
                1.4, tablet: 0.85, desktop: 0.95),
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          delegate: SliverChildBuilderDelegate(
                (context, index) =>
                DeviceCard(
                  device: controller.filteredDevices[index],
                  onTap: () {
                    Get.toNamed(
                      AppRoutes.deviceDetails,
                      arguments: controller.filteredDevices[index],
                    );
                  },
                ),
            childCount: controller.filteredDevices.length,
          ),
        ),
      );
    });
  }

  Widget _buildAddDeviceButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: () {
          Get.bottomSheet(
            const AddDeviceSheet(),
            isScrollControlled: true,
          );
        },
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Add New Device',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
      ),
    );
  }

  // بناء الزر العائم بتصميم Squircle سينمائي مع ظل مخصص
  Widget _buildFAB(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 120, right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          Get.bottomSheet(
            const AddDeviceSheet(),
            isScrollControlled: true,
            barrierColor: Colors.black.withValues(alpha: 0.5),
          );
        },
        backgroundColor: AppColors.primary,
        elevation: 0,
        // نلغي الـ elevation الافتراضي لنعتمد على الـ boxShadow الخاص بنا
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  // واجهة "لا توجد أجهزة" بتصميم متناسق مع النمط السينمائي
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.devices_other_rounded,
            size: 64,
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black
                .withValues(alpha: 0.05),
          ),
          const SizedBox(height: 20),
          Text(
            'No devices found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white24 : Colors.black26,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
