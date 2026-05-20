import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';

class ScannerWidget extends StatelessWidget {
  const ScannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Inner Pulse
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.05),
            ),
          ).animate(onPlay: (c) => c.repeat())
              .scale(begin: const Offset(0.8, 0.8),
              end: const Offset(1.2, 1.2),
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut)
              .fadeOut(duration: const Duration(seconds: 2)),

          // Scanning Line
          Container(
            width: 240,
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.primary.withValues(alpha: 0.8),
                  Colors.transparent,
                ],
              ),
            ),
          ).animate(onPlay: (c) => c.repeat())
              .moveY(begin: -100,
              end: 100,
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeInOut),

          // Icons being scanned (simulated)
          ...List.generate(4, (index) {
            final icons = [
              Icons.bluetooth,
              Icons.wifi,
              Icons.battery_charging_full,
              Icons.memory
            ];
            final angles = [0.0, 1.57, 3.14, 4.71];
            return Transform.rotate(
              angle: angles[index],
              child: Transform.translate(
                offset: const Offset(0, -90),
                child: Icon(
                  icons[index],
                  color: AppColors.primary.withValues(alpha: 0.4),
                  size: 24,
                ),
              ),
            );
          }),

          // Center Icon
          const Icon(
            Icons.security_update_good_rounded,
            size: 60,
            color: AppColors.primary,
          ).animate(onPlay: (c) => c.repeat())
              .shimmer(duration: const Duration(seconds: 3)),
        ],
      ),
    );
  }
}
