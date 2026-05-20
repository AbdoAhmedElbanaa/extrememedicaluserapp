import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/features/home/data/models/quick_action_model.dart';
import 'package:extrememedicaluserapp/features/home/data/models/recent_activity_model.dart';

import 'package:extrememedicaluserapp/features/diagnose/presentation/controllers/diagnose_controller.dart';
import 'package:extrememedicaluserapp/features/diagnose/presentation/views/diagnose_view.dart';
import 'package:extrememedicaluserapp/features/manual/presentation/views/manual_view.dart';
import 'package:extrememedicaluserapp/features/manual/presentation/controllers/manual_controller.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:extrememedicaluserapp/theme/app_colors.dart';
import 'package:extrememedicaluserapp/core/services/toast_service.dart';

class HomeController extends GetxController {
  var selectedIndex = 0.obs;
  late PageController pageController;
  final RefreshController refreshController = RefreshController(initialRefresh: false);

  late List<QuickActionModel> quickActions;
  late List<RecentActivityModel> recentActivities;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: selectedIndex.value);
    _initializeQuickActions();
    _initializeRecentActivities();
  }

  void _initializeQuickActions() {
    quickActions = [
      QuickActionModel(
        title: 'Manual',
        icon: Icons.menu_book_rounded,
        color: AppColors.indigoSoft,
        onTap: () {
          Get.put(ManualController());
          Get.to(() => const ManualView(), transition: Transition.rightToLeftWithFade);
        },
      ),
      QuickActionModel(
        title: 'Diagnose',
        icon: Icons.analytics_rounded,
        color: AppColors.emeraldSoft,
        onTap: () {
          Get.put(DiagnoseController());
          Get.to(() => const DiagnoseView(), transition: Transition.rightToLeftWithFade);
        },
      ),
      QuickActionModel(
        title: 'Errors',
        icon: Icons.warning_amber_rounded,
        color: AppColors.amberSoft,
        onTap: () => _showComingSoon('Errors'),
      ),
      QuickActionModel(
        title: 'Support',
        icon: Icons.bolt_rounded,
        color: AppColors.pinkSoft,
        onTap: () => _showComingSoon('Support'),
      ),
    ];
  }

  void _initializeRecentActivities() {
    recentActivities = [
      RecentActivityModel(
        title: 'Manual updated',
        subtitle: 'SmartThermo Pro',
        time: '2m ago',
        icon: Icons.check_circle_outline_rounded,
        status: ActivityStatus.success,
      ),
      RecentActivityModel(
        title: 'Maintenance due',
        subtitle: 'Check filter',
        time: '1h ago',
        icon: Icons.error_outline_rounded,
        status: ActivityStatus.warning,
      ),
      RecentActivityModel(
        title: 'Diagnostics run',
        subtitle: 'All systems OK',
        time: '3h ago',
        icon: Icons.analytics_outlined,
        status: ActivityStatus.info,
      ),
    ];
  }

  void _showComingSoon(String feature) {
    ToastService.show(
      title: feature,
      message: 'This feature is currently under development.',
      type: ToastType.info,
    );
  }

  Future<void> onRefresh() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    _initializeRecentActivities();
    update();
    refreshController.refreshCompleted();
    
    ToastService.show(
      title: 'Success',
      message: 'Data refreshed successfully',
      type: ToastType.success,
    );
  }

  void changeIndex(int index) {
    if (selectedIndex.value == index) return;
    
    selectedIndex.value = index;
    if (pageController.hasClients) {
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
