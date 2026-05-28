import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import 'package:extrememedicaluserapp/features/home/presentation/widgets/active_device_card.dart';
import 'package:extrememedicaluserapp/core/utils/responsive_layout.dart';
import 'package:extrememedicaluserapp/features/auth/services/auth_service.dart';
import 'package:extrememedicaluserapp/features/devices/data/models/device_model.dart';
import 'package:extrememedicaluserapp/core/routes/app_routes.dart';

class DeviceSlider extends StatefulWidget {
  const DeviceSlider({super.key});

  @override
  State<DeviceSlider> createState() => _DeviceSliderState();
}

class _DeviceSliderState extends State<DeviceSlider> {
  int _currentIndex = 0;

  // Use CarouselSliderController for version 5.0.0
  final CarouselSliderController _carouselController = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    final bool isWide = context.isDesktopLayout || context.isTabletLayout;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authService = Get.find<AuthService>();

    final double viewportFraction = context.responsive(
      0.9, // Mobile
      tablet: 0.5, // Tablet
      desktop: 0.5, // Desktop
    );

    return Obx(() {
      final user = authService.currentUserModel.value;
      final device = user?.device;

      if (device == null) {
        return _buildEmptyState(isDark);
      }

      return Column(
        children: [
          LayoutBuilder(
              builder: (context, constraints) {
                return CarouselSlider.builder(
                  carouselController: _carouselController,
                  itemCount: 1, // Currently displaying the single device associated with the clinic
                  options: CarouselOptions(
                    height: context.responsive(340, tablet: 360, desktop: 380),
                    viewportFraction: viewportFraction,
                    enlargeCenterPage: !isWide,
                    enlargeFactor: 0.2,
                    enableInfiniteScroll: false,
                    autoPlay: false,
                    padEnds: !isWide,
                    clipBehavior: Clip.none,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                  itemBuilder: (context, index, realIndex) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.responsive(8, tablet: 12, desktop: 16),
                      ),
                      child: ActiveDeviceCard(
                        device: device,
                        onTap: () {
                          final deviceModel = DeviceModel(
                            id: device.deviceId ?? '1',
                            name: device.deviceName ?? 'Medical Device',
                            model: device.deviceVersion ?? 'N/A',
                            serialNumber: device.serialNo ?? 'N/A',
                            status: DeviceStatus.online,
                            lastSync: 'Just now',
                            batteryLevel: 95,
                            signalStrength: 90,
                            firmwareVersion: 'SW${device.swVer ?? 'N/A'} UI${device.uiVer ?? 'N/A'}',
                            icon: Icons.developer_board_rounded,
                            installingDate: device.installingDate,
                            endWarranty: device.endWarranty,
                            ntcVer: device.ntcVer,
                            pcbVer: device.pcbVer,
                            ssr: device.ssr,
                            swVer: device.swVer,
                            uiVer: device.uiVer,
                          );
                          Get.toNamed(
                            AppRoutes.deviceDetails,
                            arguments: deviceModel,
                          );
                        },
                      ),
                    );
                  },
                );
              }
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isWide) ...[
                _buildNavButton(Icons.arrow_back_ios_rounded, () =>
                    _carouselController.previousPage()),
                const SizedBox(width: 20),
              ],

              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(1, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _currentIndex == index ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: AppColors.primary.withValues(
                          alpha: _currentIndex == index ? 1 : 0.2),
                    ),
                  );
                }),
              ),

              if (isWide) ...[
                const SizedBox(width: 20),
                _buildNavButton(Icons.arrow_forward_ios_rounded, () =>
                    _carouselController.nextPage()),
              ],
            ],
          ),
        ],
      );
    });
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.devices_other_rounded,
            size: 48,
            color: isDark ? Colors.white30 : Colors.black38,
          ),
          const SizedBox(height: 12),
          Text(
            'No Device Connected',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'No active medical equipment connected to your clinic.',
            style: TextStyle(
              color: isDark ? Colors.white30 : Colors.black45,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onTap) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black
              .withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
    );
  }
}
