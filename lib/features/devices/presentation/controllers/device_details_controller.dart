import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../data/models/device_model.dart';
import 'devices_controller.dart';
import 'package:extrememedicaluserapp/features/auth/services/auth_service.dart';

class DeviceDetailsController extends GetxController {
  final RefreshController refreshController = RefreshController(initialRefresh: false);
  final RefreshController refreshControllerWide = RefreshController(initialRefresh: false);
  final RxInt selectedTabIndex = 0.obs;

  late Rxn<DeviceModel> deviceRx;

  void initDevice(DeviceModel initialDevice) {
    deviceRx = Rxn<DeviceModel>(initialDevice);
    
    // Listen to DevicesController updates to keep the device detail in sync
    final devicesController = Get.find<DevicesController>();
    ever(devicesController.allDevices, (devices) {
      final updatedDevice = devices.firstWhereOrNull((d) => d.serialNumber == initialDevice.serialNumber);
      if (updatedDevice != null) {
        deviceRx.value = updatedDevice;
      }
    });
  }

  @override
  void onClose() {
    refreshController.dispose();
    refreshControllerWide.dispose();
    super.onClose();
  }

  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  Future<void> onRefresh() async {
    try {
      final authService = Get.find<AuthService>();
      final user = authService.currentUser;
      if (user != null) {
        await authService.loadUserModel(user.uid);
      }
      if (refreshController.isRefresh) refreshController.refreshCompleted();
      if (refreshControllerWide.isRefresh) refreshControllerWide.refreshCompleted();
    } catch (e) {
      refreshController.refreshFailed();
      refreshControllerWide.refreshFailed();
    }
  }
}
