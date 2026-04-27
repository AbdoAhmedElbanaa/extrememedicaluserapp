import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:extrememedicaluserapp/features/home/presentation/widgets/active_device_card.dart';

class DeviceSlider extends StatefulWidget {
  const DeviceSlider({super.key});

  @override
  State<DeviceSlider> createState() => _DeviceSliderState();
}

class _DeviceSliderState extends State<DeviceSlider> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 250, // Reduced to perfectly fit the card + shadow
            viewportFraction: 0.9,
            enlargeCenterPage: true,
            enlargeFactor: 0.2,
            autoPlay: false,
            clipBehavior: Clip.none, // Allow shadows to bleed out without overflow
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          items: const [
            ActiveDeviceCard(),
            ActiveDeviceCard(),
            ActiveDeviceCard(),
          ],
        ),
        const SizedBox(height: 12),
        // Custom Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _currentIndex == index ? 20 : 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: const Color(0xFF6366F1).withOpacity(_currentIndex == index ? 1 : 0.2),
              ),
            );
          }),
        ),
      ],
    );
  }
}
