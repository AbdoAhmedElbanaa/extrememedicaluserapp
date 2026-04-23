import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:extrememedicaluserapp/main.dart';
import 'package:extrememedicaluserapp/features/onboarding/presentation/views/onboarding_view.dart';

class SplashController extends GetxController {
  var version = '1.0.0'.obs;
  final storage = GetStorage();

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

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    
    bool onboardingSeen = storage.read('onboarding_seen') ?? false;

    if (onboardingSeen) {
      Get.offAll(() => const MyHomePage(title: 'Extreme Medical Home'));
    } else {
      Get.offAll(() => const OnboardingView());
    }
  }
}
