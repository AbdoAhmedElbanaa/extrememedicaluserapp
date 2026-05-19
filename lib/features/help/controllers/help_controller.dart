import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../models/help_topic.dart';
import '../services/help_service.dart';

class HelpController extends GetxController {
  final HelpService _helpService = HelpService();
  final RefreshController refreshController = RefreshController();
  
  final isLoading = true.obs;
  final helpTopics = <HelpTopic>[].obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHelpTopics();
  }

  Future<void> fetchHelpTopics({bool isRefresh = false}) async {
    try {
      if (!isRefresh) isLoading.value = true;
      errorMessage.value = '';
      final topics = await _helpService.getHelpTopics();
      helpTopics.assignAll(topics);
      if (isRefresh) refreshController.refreshCompleted();
    } catch (e) {
      errorMessage.value = 'Failed to load help topics. Please try again.';
      if (isRefresh) refreshController.refreshFailed();
    } finally {
      isLoading.value = false;
    }
  }

  void onRefresh() async {
    await fetchHelpTopics(isRefresh: true);
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }
}
