import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ProfileController extends GetxController {
  late RefreshController refreshController;
  
  // User data observables
  final userName = 'Ahmed Hassan'.obs;
  final userEmail = 'ahmed.hassan@example.com'.obs;
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
    darkModeEnabled.value = Get.isDarkMode;
    _getAppVersion();
  }

  Future<void> _getAppVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion.value = packageInfo.version;
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }

  Future<void> onRefresh() async {
    try {
      // Simulate API call to fetch latest user profile data
      await Future.delayed(const Duration(seconds: 1));
      refreshController.refreshCompleted();
    } catch (e) {
      refreshController.refreshFailed();
    }
  }

  void toggleNotifications(bool? value) {
    notificationsEnabled.value = value ?? !notificationsEnabled.value;
  }

  void updateName(String name) {
    userName.value = name;
  }
}
