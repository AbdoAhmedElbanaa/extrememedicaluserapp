import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../data/models/device_model.dart';
import 'package:extrememedicaluserapp/features/auth/services/auth_service.dart';
import 'package:extrememedicaluserapp/features/auth/data/models/user_model.dart';

class DevicesController extends GetxController {
  final RefreshController refreshController = RefreshController(initialRefresh: false);
  final RefreshController refreshControllerWide = RefreshController(initialRefresh: false);

  // Observables
  final RxList<DeviceModel> allDevices = <DeviceModel>[].obs;
  final RxList<DeviceModel> filteredDevices = <DeviceModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'All'.obs;

  final _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    // Listen to changes in currentUserModel to load/update device list
    ever(_authService.currentUserModel, (userModel) {
      _loadDevicesFromUser(userModel);
    });
    // Initial load
    _loadDevicesFromUser(_authService.currentUserModel.value);
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
      _loadDevicesFromUser(_authService.currentUserModel.value);
      if (refreshController.isRefresh) refreshController.refreshCompleted();
      if (refreshControllerWide.isRefresh) refreshControllerWide.refreshCompleted();
    } catch (e) {
      refreshController.refreshFailed();
      refreshControllerWide.refreshFailed();
    }
  }

  void _loadDevicesFromUser(UserModel? user) {
    if (user != null && user.device != null) {
      final userDevice = user.device!;
      final deviceModel = DeviceModel(
        id: userDevice.deviceId ?? '1',
        name: userDevice.deviceName ?? 'Medical Device',
        model: userDevice.deviceVersion ?? 'N/A',
        serialNumber: userDevice.serialNo ?? 'N/A',
        status: DeviceStatus.online,
        lastSync: 'Just now',
        batteryLevel: 95,
        signalStrength: 90,
        firmwareVersion: 'SW${userDevice.swVer ?? 'N/A'} UI${userDevice.uiVer ?? 'N/A'}',
        icon: Icons.developer_board_rounded,
        installingDate: userDevice.installingDate,
        endWarranty: userDevice.endWarranty,
        ntcVer: userDevice.ntcVer,
        pcbVer: userDevice.pcbVer,
        ssr: userDevice.ssr,
        swVer: userDevice.swVer,
        uiVer: userDevice.uiVer,
      );
      allDevices.assignAll([deviceModel]);
    } else {
      allDevices.clear();
    }
    applyFilter(selectedFilter.value);
  }

  void applyFilter(String filter) {
    selectedFilter.value = filter;
    _updateFilteredList();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    _updateFilteredList();
  }

  void _updateFilteredList() {
    var list = allDevices.where((device) {
      final matchesSearch =
          device.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
              device.serialNumber
                  .toLowerCase()
                  .contains(searchQuery.value.toLowerCase());

      bool matchesFilter = true;
      if (selectedFilter.value == 'Online') {
        matchesFilter = device.status == DeviceStatus.online;
      } else if (selectedFilter.value == 'Warning') {
        matchesFilter = device.status == DeviceStatus.warning;
      } else if (selectedFilter.value == 'Offline') {
        matchesFilter = device.status == DeviceStatus.offline;
      }

      return matchesSearch && matchesFilter;
    }).toList();

    filteredDevices.assignAll(list);
  }

  int getCount(String filter) {
    if (filter == 'All') return allDevices.length;
    if (filter == 'Online') {
      return allDevices.where((d) => d.status == DeviceStatus.online).length;
    }
    if (filter == 'Warning') {
      return allDevices.where((d) => d.status == DeviceStatus.warning).length;
    }
    if (filter == 'Offline') {
      return allDevices.where((d) => d.status == DeviceStatus.offline).length;
    }
    return 0;
  }

  int get onlineCount => getCount('Online');
  int get warningCount => getCount('Warning');
}
