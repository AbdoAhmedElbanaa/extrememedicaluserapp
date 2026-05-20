import 'package:get/get.dart';

class SettingsController extends GetxController {
  final RxBool notificationsEnabled = true.obs;
  final RxString appVersion = '1.0.0'.obs;

  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
  }
}
