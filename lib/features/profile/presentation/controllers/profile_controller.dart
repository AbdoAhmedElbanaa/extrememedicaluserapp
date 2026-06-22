import 'package:extrememedicaluserapp/features/auth/services/auth_service.dart';
import 'package:extrememedicaluserapp/features/auth/data/models/user_model.dart';
import 'package:extrememedicaluserapp/features/contact/services/onesignal_service.dart';
import 'package:extrememedicaluserapp/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ProfileController extends GetxController {
  late RefreshController refreshController;
  late RefreshController refreshControllerWide;
  
  final _authService = Get.find<AuthService>();
  
  // User data observables
  var userData = Rxn<UserModel>();
  final userName = 'User'.obs;
  final userEmail = ''.obs;
  final userAvatar = ''.obs; 
  
  // Settings observables
  final notificationsEnabled = true.obs;
  final darkModeEnabled = false.obs; 

  // Version info
  final appVersion = '1.0.0'.obs;

  @override
  void onInit() {
    super.onInit();
    refreshController = RefreshController(initialRefresh: false);
    refreshControllerWide = RefreshController(initialRefresh: false);
    darkModeEnabled.value = Get.isDarkMode;
    _getAppVersion();
    _loadUserData();
  }

  void _loadUserData() {
    // Listen to changes in the AuthService's currentUserModel
    ever(_authService.currentUserModel, (userModel) {
      userData.value = userModel;
      if (userModel != null) {
        userName.value = "${userModel.firstName} ${userModel.lastName}";
        userEmail.value = userModel.email ?? _authService.currentUser?.email ?? _authService.currentUser?.phoneNumber ?? '';
      }
    });

    // Load initial values
    final initialUser = _authService.currentUserModel.value;
    userData.value = initialUser;
    if (initialUser != null) {
      userName.value = "${initialUser.firstName} ${initialUser.lastName}";
      userEmail.value = initialUser.email ?? _authService.currentUser?.email ?? _authService.currentUser?.phoneNumber ?? '';
    } else {
      final user = _authService.currentUser;
      if (user != null) {
        userEmail.value = user.email ?? user.phoneNumber ?? '';
      }
    }
  }

  Future<void> _getAppVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion.value = packageInfo.version;
  }

  @override
  void onClose() {
    refreshController.dispose();
    refreshControllerWide.dispose();
    super.onClose();
  }

  Future<void> onRefresh() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        await _authService.loadUserModel(user.uid);
      }
      if (refreshController.isRefresh) refreshController.refreshCompleted();
      if (refreshControllerWide.isRefresh) refreshControllerWide.refreshCompleted();
    } catch (e) {
      refreshController.refreshFailed();
      refreshControllerWide.refreshFailed();
    }
  }

  void toggleNotifications(bool? value) {
    notificationsEnabled.value = value ?? !notificationsEnabled.value;
  }

  void updateName(String name) {
    userName.value = name;
  }

  // Handle user logout with confirmation
  Future<void> handleLogout() async {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout? You will need to login again to access your account.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back(); // Close dialog
              
              try {
                // Show loading indicator
                Get.dialog(
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                  barrierDismissible: false,
                );

                // Sign out from Firebase and OneSignal
                await _authService.signOut();
                OneSignalService.logoutUser();

                // Close loading dialog
                Get.back();

                // Navigate to login page and clear navigation stack
                Get.offAllNamed(AppRoutes.login);

                // Show success message
                Get.snackbar(
                  'Success',
                  'You have been logged out successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                );
              } catch (e) {
                Get.back(); // Close loading dialog if still open
                Get.snackbar(
                  'Error',
                  'Failed to logout: $e',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
