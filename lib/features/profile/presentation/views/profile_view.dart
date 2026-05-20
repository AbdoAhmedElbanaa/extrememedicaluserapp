import 'package:extrememedicaluserapp/core/utils/responsive_layout.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../controllers/profile_controller.dart';
import '../widgets/profile_header.dart';
import '../widgets/account_info_section.dart';
import '../widgets/security_section.dart';
import '../widgets/preferences_section.dart';
import '../widgets/support_legal_section.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 1100) {
            return _buildDesktopLayout(context);
          } else if (constraints.maxWidth >= 600) {
            return _buildTabletLayout(context);
          } else {
            return _buildMobileLayout(context);
          }
        },
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        const ProfileHeader(),
        Expanded(
          child: SmartRefresher(
            controller: controller.refreshController,
            onRefresh: controller.onRefresh,
            header: WaterDropMaterialHeader(
              backgroundColor: AppColors.primary,
              color: Colors.white,
            ),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 20,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const AccountInfoSection(),
                      const SizedBox(height: 24),
                      const SecuritySection(),
                      const SizedBox(height: 24),
                      const PreferencesSection(),
                      const SizedBox(height: 24),
                      const SupportLegalSection(),
                      const SizedBox(height: 120),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return _buildWideLayout(context, isDesktop: false);
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return _buildWideLayout(context, isDesktop: true);
  }

  Widget _buildWideLayout(BuildContext context, {required bool isDesktop}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double sidePadding = isDesktop ? 60 : 30;

    return Row(
      children: [
        // Left Sidebar: Profile Header
        SizedBox(
          width: isDesktop ? 400 : 320,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
                  width: 1,
                ),
              ),
            ),
            child: const ProfileHeader(),
          ),
        ),
        
        // Right Content: Profile Sections
        Expanded(
          child: Container(
            color: isDark 
                ? AppColors.backgroundDark.withValues(alpha: 0.3) 
                : AppColors.backgroundLight.withValues(alpha: 0.3),
            child: SmartRefresher(
              controller: controller.refreshControllerWide,
              onRefresh: controller.onRefresh,
              header: WaterDropMaterialHeader(
                backgroundColor: AppColors.primary,
                color: Colors.white,
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: sidePadding,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionGrid(context, isDesktop),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionGrid(BuildContext context, bool isDesktop) {
    final useTwoColumns = context.screenWidth > 900;

    if (!useTwoColumns) {
      return Column(
        children: [
          const AccountInfoSection(),
          const SizedBox(height: 24),
          const SecuritySection(),
          const SizedBox(height: 24),
          const PreferencesSection(),
          const SizedBox(height: 24),
          const SupportLegalSection(),
        ],
      );
    }

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: const AccountInfoSection()),
            const SizedBox(width: 24),
            Expanded(child: const SecuritySection()),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: const PreferencesSection()),
            const SizedBox(width: 24),
            Expanded(child: const SupportLegalSection()),
          ],
        ),
      ],
    );
  }
}
