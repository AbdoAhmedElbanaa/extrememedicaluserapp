import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import 'package:extrememedicaluserapp/features/home/presentation/widgets/active_device_card.dart';
import 'package:extrememedicaluserapp/core/utils/responsive_layout.dart';

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

    final double viewportFraction = context.responsive(
      0.9, // Mobile
      tablet: 0.5, // Tablet
      desktop: 0.5, // Desktop
    );

    return Column(
      children: [
        LayoutBuilder(
            builder: (context, constraints) {
              return CarouselSlider.builder(
                carouselController: _carouselController,
                itemCount: 6,
                options: CarouselOptions(
                  height: context.responsive(250, tablet: 280, desktop: 300),
                  viewportFraction: viewportFraction,
                  enlargeCenterPage: !isWide,
                  enlargeFactor: 0.2,
                  enableInfiniteScroll: true,
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
                      horizontal: context.responsive(
                          8, tablet: 12, desktop: 16),
                    ),
                    child: const ActiveDeviceCard(),
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
              children: List.generate(6, (index) {
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
