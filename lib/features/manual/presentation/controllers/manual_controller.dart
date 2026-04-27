import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/manual_model.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';

class ManualController extends GetxController {
  final RxList<ManualModel> manuals = <ManualModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RefreshController refreshController = RefreshController(initialRefresh: false);

  @override
  void onInit() {
    super.onInit();
    _loadManuals();
  }

  Future<void> onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    _loadManuals();
    refreshController.refreshCompleted();
  }

  void _loadManuals() {
    manuals.value = [
      ManualModel(
        title: 'SmartThermo Pro Guide',
        deviceName: 'Thermometer ST-200',
        lastUpdated: 'Oct 12, 2023',
        fileSize: '4.2 MB',
        icon: Icons.thermostat_rounded,
        color: const Color(0xFF6366F1),
      ),
      ManualModel(
        title: 'BPM Alpha Manual',
        deviceName: 'Blood Pressure Monitor',
        lastUpdated: 'Sep 05, 2023',
        fileSize: '2.8 MB',
        icon: Icons.monitor_heart_rounded,
        color: const Color(0xFFF472B6),
      ),
      ManualModel(
        title: 'GlucoTrack X User Manual',
        deviceName: 'Glucose Meter',
        lastUpdated: 'Jan 20, 2024',
        fileSize: '5.1 MB',
        icon: Icons.bloodtype_rounded,
        color: const Color(0xFF34D399),
      ),
      ManualModel(
        title: 'OxyFlow Setup Guide',
        deviceName: 'Pulse Oximeter',
        lastUpdated: 'Dec 15, 2023',
        fileSize: '1.5 MB',
        icon: Icons.air_rounded,
        color: const Color(0xFFFBBF24),
      ),
    ];
  }

  List<ManualModel> get filteredManuals {
    if (searchQuery.isEmpty) return manuals;
    return manuals.where((m) => 
      m.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
      m.deviceName.toLowerCase().contains(searchQuery.value.toLowerCase())
    ).toList();
  }
}
