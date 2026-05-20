import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../data/models/device_model.dart';

class DevicesController extends GetxController {
  final RefreshController refreshController = RefreshController(initialRefresh: false);
  final RefreshController refreshControllerWide = RefreshController(initialRefresh: false);

  // Observables
  final RxList<DeviceModel> allDevices = <DeviceModel>[].obs;
  final RxList<DeviceModel> filteredDevices = <DeviceModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockDevices();
  }

  @override
  void onClose() {
    refreshController.dispose();
    refreshControllerWide.dispose();
    super.onClose();
  }

  Future<void> onRefresh() async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      _loadMockDevices();
      if (refreshController.isRefresh) refreshController.refreshCompleted();
      if (refreshControllerWide.isRefresh) refreshControllerWide.refreshCompleted();
    } catch (e) {
      refreshController.refreshFailed();
      refreshControllerWide.refreshFailed();
    }
  }

  void _loadMockDevices() {
    allDevices.assignAll([
      DeviceModel(
        id: '1',
        name: 'SmartThermo Pro',
        model: 'ST-2024-X',
        serialNumber: 'SN-2024-001234',
        status: DeviceStatus.online,
        lastSync: 'Just now',
        batteryLevel: 78,
        signalStrength: 92,
        firmwareVersion: 'v2.4.1',
        icon: Icons.thermostat_rounded,
      ),
      DeviceModel(
        id: '2',
        name: 'AirControl Hub',
        model: 'AC-2023-Pro',
        serialNumber: 'SN-2023-007891',
        status: DeviceStatus.warning,
        lastSync: '14 min ago',
        batteryLevel: 22,
        signalStrength: 64,
        firmwareVersion: 'v1.9.3',
        icon: Icons.air_rounded,
      ),
      DeviceModel(
        id: '3',
        name: 'Heart Rate Pro',
        model: 'HR-2024-Plus',
        serialNumber: 'SN-2024-009922',
        status: DeviceStatus.online,
        lastSync: '2 min ago',
        batteryLevel: 95,
        signalStrength: 88,
        firmwareVersion: 'v2.0.5',
        icon: Icons.favorite_rounded,
      ),
    ]);
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
