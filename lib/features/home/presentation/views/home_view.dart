import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import 'package:extrememedicaluserapp/features/home/presentation/widgets/home_header.dart';
import 'package:extrememedicaluserapp/features/home/presentation/widgets/custom_bottom_nav.dart';
import 'package:extrememedicaluserapp/features/home/presentation/widgets/quick_actions_section.dart';
import 'package:extrememedicaluserapp/features/home/presentation/widgets/device_slider.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Stack(
        children: [
          // MAIN PAGE VIEWER FOR SMOOTH TRANSITION
          PageView(
            controller: controller.pageController,
            onPageChanged: (index) => controller.selectedIndex.value = index,
            physics: const NeverScrollableScrollPhysics(), // Only via BottomNav
            children: [
              _buildHomeContent(context, isDark),
              _buildPlaceholderPage('Devices'),
              _buildPlaceholderPage('Help'),
              _buildPlaceholderPage('Profile'),
            ],
          ),

          // Background Gradient for Cinematic Look (Behind fixed header)
          if (isDark)
            Positioned(
              top: -100,
              left: -50,
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.15),
                    ),
                  ),
                ),
              ),
            ),

          // FIXED HEADER WITH BLUR
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: HomeHeader(isDark: isDark),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(isDark: isDark),
      extendBody: true,
    );
  }

  Widget _buildHomeContent(BuildContext context, bool isDark) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Builder(
            builder: (context) {
              final topPadding = MediaQuery.of(context).padding.top;
              return SizedBox(height: topPadding + 165); 
            },
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                DeviceSlider(),
                SizedBox(height: 30),
                QuickActionsSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderPage(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction_rounded, size: 64, color: AppColors.primary.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            '$title Page Coming Soon',
            style: const TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
