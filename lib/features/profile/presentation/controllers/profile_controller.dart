import 'package:extrememedicaluserapp/features/auth/services/auth_service.dart';
import 'package:extrememedicaluserapp/features/auth/data/user_repository.dart';
import 'package:extrememedicaluserapp/features/auth/data/models/user_model.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ProfileController extends GetxController {
  late RefreshController refreshController;
  late RefreshController refreshControllerWide;
  
  final _authService = Get.find<AuthService>();
  final _userRepo = Get.find<UserRepository>();
  
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

  Future<void> _loadUserData() async {
    final user = _authService.currentUser;
    if (user != null) {
      userEmail.value = user.email ?? user.phoneNumber ?? '';
      userData.value = await _userRepo.getUser(user.uid);
      if (userData.value != null) {
        userName.value = "${userData.value!.firstName} ${userData.value!.lastName}";
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
      // Simulate API call to fetch latest user profile data
      await Future.delayed(const Duration(seconds: 1));
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
}
