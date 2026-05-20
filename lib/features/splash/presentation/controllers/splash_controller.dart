import 'package:extrememedicaluserapp/features/auth/services/auth_service.dart';
import 'package:extrememedicaluserapp/features/auth/presentation/views/login_view.dart';
import 'package:extrememedicaluserapp/features/permissions/presentation/view/allow_permissions_view.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:extrememedicaluserapp/features/home/presentation/views/home_view.dart';
import 'package:extrememedicaluserapp/features/home/presentation/controllers/home_controller.dart';
import 'package:extrememedicaluserapp/features/onboarding/presentation/views/onboarding_view.dart';

class SplashController extends GetxController {
  var version = '1.0.0'.obs;
  final storage = GetStorage();
  final _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    _getVersion();
    _navigateToNext();
  }

  void _getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version.value = packageInfo.version;
  }

  Future<bool> _checkPermissions() async {
    final permissions = [
      Permission.notification,
      Permission.camera,
      Permission.storage,
      Permission.nearbyWifiDevices,
      Permission.ignoreBatteryOptimizations,
    ];

    for (var p in permissions) {
      if (!(await p.isGranted)) {
        return false;
      }
    }
    return true;
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    
    bool onboardingSeen = storage.read('onboarding_seen') ?? false;
    bool allPermissionsGranted = storage.read('all_permissions_granted') ?? false;

    if (!onboardingSeen) {
      Get.offAll(() => const OnboardingView());
      return;
    }

    // Check if permissions were already granted or need checking
    if (!allPermissionsGranted) {
      bool permissionsReallyGranted = await _checkPermissions();
      if (!permissionsReallyGranted) {
        Get.offAll(() => const AllowPermissionsView());
        return;
      }
      storage.write('all_permissions_granted', true);
    }

    // After permissions are confirmed, check login status
    bool isLoggedIn = _authService.currentUser != null;

    if (isLoggedIn) {
      if (!Get.isRegistered<HomeController>()) {
        Get.put(HomeController());
      }
      Get.offAll(() => const HomeView());
    } else {
      Get.offAll(() => const LoginView());
    }
  }
}
