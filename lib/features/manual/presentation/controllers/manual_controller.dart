import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/manual_model.dart';
import '../../data/models/manual_step_model.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';

class ManualController extends GetxController {
  final RxList<ManualModel> manuals = <ManualModel>[].obs;
  final RxList<ManualStepModel> manualSteps = <ManualStepModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'Installation'.obs;
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

  void changeCategory(String category) {
    selectedCategory.value = category;
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
      // Installation Steps
      ManualStepModel(
        stepNumber: 1,
        title: 'Unbox & Inspect',
        description: 'Remove the device from packaging. Check for visible damage. Verify all components: unit, power adapter, mounting bracket, and this manual are present.',
        category: 'Installation',
      ),
      ManualStepModel(
        stepNumber: 2,
        title: 'Choose Installation Location',
        description: 'Mount at least 1.5m from the floor. Avoid direct sunlight, heat sources, and moisture. Ensure 30cm clearance on all sides for proper airflow.',
        noteText: 'Optimal range: 18–24°C ambient temperature.',
        noteType: StepNoteType.info,
        category: 'Installation',
      ),
      ManualStepModel(
        stepNumber: 3,
        title: 'Mount the Bracket',
        description: 'Use the provided 4 × M4 screws and wall anchors. Ensure the surface can support 2.5kg. Use a spirit level to align the bracket horizontally.',
        noteText: 'Do not install near electrical panels or HVAC vents.',
        noteType: StepNoteType.warning,
        category: 'Installation',
      ),
      
      // Setup Steps
      ManualStepModel(
        stepNumber: 1,
        title: 'Power On Device',
        description: 'Connect the power adapter to the device and plug it into a wall outlet. Press the power button for 3 seconds until the display lights up.',
        category: 'Setup',
      ),
      ManualStepModel(
        stepNumber: 2,
        title: 'Connect to Wi-Fi',
        description: 'Open the Extreme Medical app on your phone. Go to "Add Device" and follow the instructions to connect the device to your 2.4GHz Wi-Fi network.',
        noteText: 'The device only supports 2.4GHz networks.',
        noteType: StepNoteType.info,
        category: 'Setup',
      ),

      // Maintenance Steps
      ManualStepModel(
        stepNumber: 1,
        title: 'Cleaning the Sensor',
        description: 'Use a soft, dry cloth to wipe the sensor lens once a month. Do not use abrasive cleaners or liquids.',
        category: 'Maintenance',
      ),

      // Safety Steps
      ManualStepModel(
        stepNumber: 1,
        title: 'Electrical Safety',
        description: 'Do not use the device with a damaged power cord. Always unplug the device before cleaning or performing maintenance.',
        noteType: StepNoteType.warning,
        noteText: 'Risk of electric shock if handled improperly.',
        category: 'Safety',
      ),
    ];
  }

  List<ManualStepModel> get filteredSteps {
    return manualSteps.where((step) => step.category == selectedCategory.value).toList();
  }

  List<ManualModel> get filteredManuals {
    if (searchQuery.isEmpty) return manuals;
    return manuals.where((m) => 
      m.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
      m.deviceName.toLowerCase().contains(searchQuery.value.toLowerCase())
    ).toList();
  }
}
