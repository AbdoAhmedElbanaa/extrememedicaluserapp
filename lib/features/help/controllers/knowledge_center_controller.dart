import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../models/faq_model.dart';
import '../models/error_code_model.dart';
import '../models/diagnose_option_model.dart';
import '../services/knowledge_center_service.dart';

class KnowledgeCenterController extends GetxController {
  final KnowledgeCenterService _service = KnowledgeCenterService();
  final RefreshController refreshController = RefreshController();

  // State Observables
  final RxInt activeTabIndex = 0.obs; // 0: All, 1: FAQs, 2: Error Codes, 3: Diagnose
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = true.obs;

  // Master Lists
  final RxList<FaqModel> allFaqs = <FaqModel>[].obs;
  final RxList<ErrorCodeModel> allErrors = <ErrorCodeModel>[].obs;
  final RxList<DiagnoseOptionModel> allDiagnoseOptions = <DiagnoseOptionModel>[].obs;

  // Filtered Lists
  final RxList<FaqModel> filteredFaqs = <FaqModel>[].obs;
  final RxList<ErrorCodeModel> filteredErrors = <ErrorCodeModel>[].obs;
  final RxList<DiagnoseOptionModel> filteredDiagnoseOptions = <DiagnoseOptionModel>[].obs;

  // Selected items for Master-Detail views (Tablet/Desktop)
  final Rxn<FaqModel> selectedFaq = Rxn<FaqModel>();
  final Rxn<ErrorCodeModel> selectedError = Rxn<ErrorCodeModel>();
  final Rxn<DiagnoseOptionModel> selectedDiagnose = Rxn<DiagnoseOptionModel>();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is int) {
      activeTabIndex.value = args;
    }
    loadAllData();
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }

  Future<void> loadAllData() async {
    try {
      isLoading.value = true;
      final faqs = await _service.getFaqs();
      final errors = await _service.getErrorCodes();
      final options = await _service.getDiagnoseOptions();

      allFaqs.assignAll(faqs);
      allErrors.assignAll(errors);
      allDiagnoseOptions.assignAll(options);

      if (faqs.isNotEmpty) selectedFaq.value = faqs.first;
      if (errors.isNotEmpty) selectedError.value = errors.first;
      if (options.isNotEmpty) selectedDiagnose.value = options.first;

      applyFilters();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load knowledge center data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onRefresh() async {
    try {
      final faqs = await _service.getFaqs();
      final errors = await _service.getErrorCodes();
      final options = await _service.getDiagnoseOptions();

      allFaqs.assignAll(faqs);
      allErrors.assignAll(errors);
      allDiagnoseOptions.assignAll(options);

      if (faqs.isNotEmpty && (selectedFaq.value == null || !faqs.any((f) => f.id == selectedFaq.value?.id))) {
        selectedFaq.value = faqs.first;
      }
      if (errors.isNotEmpty && (selectedError.value == null || !errors.any((e) => e.id == selectedError.value?.id))) {
        selectedError.value = errors.first;
      }
      if (options.isNotEmpty && (selectedDiagnose.value == null || !options.any((o) => o.id == selectedDiagnose.value?.id))) {
        selectedDiagnose.value = options.first;
      }

      applyFilters();
      refreshController.refreshCompleted();
    } catch (e) {
      refreshController.refreshFailed();
    }
  }

  void changeTab(int index) {
    activeTabIndex.value = index;
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void applyFilters() {
    final query = searchQuery.value.toLowerCase().trim();
    if (query.isEmpty) {
      filteredFaqs.assignAll(allFaqs);
      filteredErrors.assignAll(allErrors);
      filteredDiagnoseOptions.assignAll(allDiagnoseOptions);
      return;
    }

    // Filter FAQs
    filteredFaqs.assignAll(allFaqs.where((faq) =>
        faq.question.toLowerCase().contains(query) ||
        faq.answer.toLowerCase().contains(query)));

    // Filter Errors
    filteredErrors.assignAll(allErrors.where((err) =>
        err.code.toLowerCase().contains(query) ||
        err.title.toLowerCase().contains(query) ||
        err.description.toLowerCase().contains(query)));

    // Filter Diagnose Options
    filteredDiagnoseOptions.assignAll(allDiagnoseOptions.where((opt) =>
        opt.title.toLowerCase().contains(query) ||
        opt.description.toLowerCase().contains(query)));
  }
}
