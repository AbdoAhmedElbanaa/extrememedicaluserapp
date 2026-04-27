import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/features/home/data/models/quick_action_model.dart';

class HomeController extends GetxController {
  var selectedIndex = 0.obs;
  late PageController pageController;

  late final List<QuickActionModel> quickActions;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: selectedIndex.value);
    _initializeQuickActions();
  }

  void _initializeQuickActions() {
    quickActions = [
      QuickActionModel(
        title: 'Manual',
        icon: Icons.menu_book_rounded,
        color: const Color(0xFF818CF8),
        onTap: () => Get.snackbar('Manual', 'Opening user manual...', 
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.indigo.withOpacity(0.7), colorText: Colors.white),
      ),
      QuickActionModel(
        title: 'Diagnose',
        icon: Icons.analytics_rounded,
        color: const Color(0xFF34D399),
        onTap: () => Get.snackbar('Diagnose', 'Starting system diagnosis...', 
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.teal.withOpacity(0.7), colorText: Colors.white),
      ),
      QuickActionModel(
        title: 'Errors',
        icon: Icons.warning_amber_rounded,
        color: const Color(0xFFFBBF24),
        onTap: () => Get.snackbar('Errors', 'Checking for system errors...', 
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.amber.withOpacity(0.7), colorText: Colors.white),
      ),
      QuickActionModel(
        title: 'Support',
        icon: Icons.bolt_rounded,
        color: const Color(0xFFF472B6),
        onTap: () => Get.snackbar('Support', 'Connecting to support...', 
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.pink.withOpacity(0.7), colorText: Colors.white),
      ),
    ];
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
