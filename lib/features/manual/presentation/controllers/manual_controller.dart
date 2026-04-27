import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/manual_model.dart';
import '../../data/models/manual_step_model.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';

class ManualController extends GetxController {
  final RxList<ManualModel> manuals = <ManualModel>[].obs;
  final RxList<ManualStepModel> manualSteps = <ManualStepModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RefreshController refreshController = RefreshController(initialRefresh: false);

  @override
  void onInit() {
    super.onInit();
    _loadManuals();
    _loadSteps();
  }

  Future<void> onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    _loadManuals();
    _loadSteps();
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
    ];
  }

  void _loadSteps() {
    manualSteps.value = [
      ManualStepModel(
        stepNumber: 1,
        title: 'Unbox & Inspect',
        description: 'Remove the device from packaging. Check for visible damage. Verify all components: unit, power adapter, mounting bracket, and this manual are present.',
      ),
      ManualStepModel(
        stepNumber: 2,
        title: 'Choose Installation Location',
        description: 'Mount at least 1.5m from the floor. Avoid direct sunlight, heat sources, and moisture. Ensure 30cm clearance on all sides for proper airflow.',
        noteText: 'Optimal range: 18–24°C ambient temperature.',
        noteType: StepNoteType.info,
      ),
      ManualStepModel(
        stepNumber: 3,
        title: 'Mount the Bracket',
        description: 'Use the provided 4 × M4 screws and wall anchors. Ensure the surface can support 2.5kg. Use a spirit level to align the bracket horizontally.',
        noteText: 'Do not install near electrical panels or HVAC vents.',
        noteType: StepNoteType.warning,
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
