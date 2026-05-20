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
      body: Column(
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
                    padding: EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: context.responsive(
                        20,
                        tablet: 50,
                        desktop: 100,
                      ),
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
                        // Extra space for BottomNav
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
