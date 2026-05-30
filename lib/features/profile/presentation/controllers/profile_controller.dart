import 'package:extrememedicaluserapp/features/auth/services/auth_service.dart';
import 'package:extrememedicaluserapp/features/auth/data/models/user_model.dart';
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
}
