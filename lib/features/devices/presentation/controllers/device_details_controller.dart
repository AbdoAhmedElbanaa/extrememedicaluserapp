import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class DeviceDetailsController extends GetxController {
  final RefreshController refreshController = RefreshController(initialRefresh: false);
  final RxInt selectedTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }

  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  Future<void> onRefresh() async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      refreshController.refreshCompleted();
    } catch (e) {
      refreshController.refreshFailed();
    }
  }
}
