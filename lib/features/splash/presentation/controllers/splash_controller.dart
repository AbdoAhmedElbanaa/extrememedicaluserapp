import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:extrememedicaluserapp/main.dart';

class SplashController extends GetxController {
  var version = '1.0.0'.obs;

  @override
  void onInit() {
    super.onInit();
    _getVersion();
    _navigateToHome();
  }

  void _getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version.value = packageInfo.version;
  }

  void _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    Get.offAll(() => const MyHomePage(title: 'Extreme Medical Home'));
  }
}
