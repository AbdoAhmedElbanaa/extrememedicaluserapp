import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/manual_model.dart';
import '../../data/models/manual_step_model.dart';
import '../../data/services/manual_service.dart';

import 'package:extrememedicaluserapp/theme/app_colors.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ManualController extends GetxController {
  final RxList<ManualModel> manuals = <ManualModel>[].obs;
  final RxList<ManualStepModel> manualSteps = <ManualStepModel>[].obs;
  final RxList<String> categories = <String>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = ''.obs;
  final RxBool isLoading = true.obs;
  final RefreshController refreshController = RefreshController(initialRefresh: false);

  final ManualService _service = ManualService();

  @override
  void onInit() {
    super.onInit();
    _loadManuals();
    loadStepsData();
  }

  Future<void> onRefresh() async {
    try {
      _loadManuals();
      await loadStepsData();
      refreshController.refreshCompleted();
    } catch (e) {
      refreshController.refreshFailed();
    }
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
        color: AppColors.primary,
      ),
      ManualModel(
        title: 'BPM Alpha Manual',
        deviceName: 'Blood Pressure Monitor',
        lastUpdated: 'Sep 05, 2023',
        fileSize: '2.8 MB',
        icon: Icons.monitor_heart_rounded,
        color: AppColors.pinkSoft,
      ),
    ];
  }

  Future<void> loadStepsData() async {
    try {
      isLoading.value = true;
      final steps = await _service.getManualSteps();
      manualSteps.assignAll(steps);

      // Extract unique categories
      final uniqueCats = steps.map((s) => s.category).toSet().toList();
      categories.assignAll(uniqueCats);

      // Check if selectedCategory is still valid, else set to first
      if (!categories.contains(selectedCategory.value)) {
        selectedCategory.value = categories.isNotEmpty ? categories.first : '';
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load user manual: $e');
    } finally {
      isLoading.value = false;
    }
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
