import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import 'package:extrememedicaluserapp/features/home/presentation/widgets/home_header.dart';
import 'package:extrememedicaluserapp/features/home/presentation/widgets/custom_bottom_nav.dart';
import 'package:extrememedicaluserapp/features/home/presentation/widgets/recent_activity_section.dart';
import 'package:extrememedicaluserapp/features/home/presentation/widgets/quick_actions_section.dart';
import 'package:extrememedicaluserapp/features/home/presentation/widgets/device_slider.dart';
import 'package:extrememedicaluserapp/features/devices/presentation/views/devices_view.dart';
import 'package:extrememedicaluserapp/features/help/views/help_view.dart';
import 'package:extrememedicaluserapp/features/profile/presentation/views/profile_view.dart';
import 'package:extrememedicaluserapp/core/utils/responsive_layout.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Row(
        children: [
          if (context.isDesktopLayout)
            _buildSideNavigationRail(isDark),
          
          Expanded(
            child: Stack(
              children: [
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
                            color: AppColors.primary.withValues(alpha: 0.15),
                          ),
                        ),
                      ),
                    ),
                  ),
                
                PageView(
                  controller: controller.pageController,
                  onPageChanged: (index) => controller.selectedIndex.value = index,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildHomeContent(context, isDark),
                    const DevicesView(),
                    const HelpView(),
                    const ProfileView(),
                  ],
                ),

                Obx(() {
                  final isHome = controller.selectedIndex.value == 0;
                  return AnimatedPositioned(
                    duration: 600.ms,
                    curve: Curves.easeInOutQuart,
                    top: isHome ? 0 : -120, // سلايد للأعلى عند الاختفاء
                    left: 0,
                    right: 0,
                    child: AnimatedOpacity(
                      duration: 400.ms,
                      opacity: isHome ? 1.0 : 0.0,
                      child: IgnorePointer(
                        ignoring: !isHome,
                        child: HomeHeader(isDark: isDark),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(isDark: isDark),
      extendBody: true,
    );
  }

  Widget _buildSideNavigationRail(bool isDark) {
    return Obx(() => NavigationRail(
      selectedIndex: controller.selectedIndex.value,
      onDestinationSelected: (index) => controller.changeIndex(index),
      labelType: NavigationRailLabelType.all,
      backgroundColor: isDark ? const Color(0xFF161531) : Colors.white,
      selectedIconTheme: const IconThemeData(color: AppColors.primary),
      unselectedIconTheme: IconThemeData(color: isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3)),
      destinations: const [
        NavigationRailDestination(icon: Icon(Icons.home_filled), label: Text('Home')),
        NavigationRailDestination(icon: Icon(Icons.layers_rounded), label: Text('Devices')),
        NavigationRailDestination(icon: Icon(Icons.help_center_rounded), label: Text('Help')),
        NavigationRailDestination(icon: Icon(Icons.person_rounded), label: Text('Profile')),
      ],
    ));
  }

  Widget _buildHomeContent(BuildContext context, bool isDark) {
    return SmartRefresher(
      controller: controller.refreshController,
      onRefresh: controller.onRefresh,
      header: WaterDropMaterialHeader(
        backgroundColor: AppColors.primary,
        color: Colors.white,
        offset: MediaQuery.of(context).padding.top + 100,
      ),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: Builder(
              builder: (context) {
                final topPadding = MediaQuery.of(context).padding.top;
                return SizedBox(height: topPadding + 175); 
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1400),
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsive(20, tablet: 40, desktop: 60),
                ),
                child: context.isDesktopLayout || context.isTabletLayout 
                  ? _buildWideLayout(context) 
                  : _buildMobileLayout(),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DeviceSlider()
            .animate()
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad),
        const SizedBox(height: 30),
        const QuickActionsSection()
            .animate()
            .fadeIn(delay: 200.ms, duration: 600.ms)
            .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad),
        const SizedBox(height: 30),
        const RecentActivitySection()
            .animate()
            .fadeIn(delay: 400.ms, duration: 600.ms)
            .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad),
      ],
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Column(
      children: [
        // Top Section: Prominent Slider
        const DeviceSlider()
            .animate()
            .fadeIn(duration: 600.ms)
            .scale(begin: const Offset(0.9, 0.9)),
        
        const SizedBox(height: 40),
        
        // Bottom Section: Two Columns for Actions and Activity
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column: Quick Actions
            Expanded(
              flex: 1,
              child: const QuickActionsSection()
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 600.ms)
                  .slideX(begin: -0.1, end: 0),
            ),
            const SizedBox(width: 40),
            // Right Column: Recent Activity
            Expanded(
              flex: 1,
              child: const RecentActivitySection()
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 600.ms)
                  .slideX(begin: 0.1, end: 0),
            ),
          ],
        ),
      ],
    );
  }
}
