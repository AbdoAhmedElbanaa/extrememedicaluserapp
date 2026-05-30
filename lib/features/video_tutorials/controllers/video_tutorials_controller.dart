import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/video_category_model.dart';
import '../models/video_tutorial_model.dart';
import '../services/video_tutorials_service.dart';

class VideoTutorialsController extends GetxController {
  final VideoTutorialsService _service = VideoTutorialsService();
  final GetStorage _storage = GetStorage();

  // Streams data
  final RxList<VideoCategoryModel> categories = <VideoCategoryModel>[].obs;
  final RxList<VideoTutorialModel> allVideos = <VideoTutorialModel>[].obs;

  // Filters state
  final RxString selectedCategoryId = 'All'.obs; // 'All' or Category ID
  final RxString searchQuery = ''.obs;

  // Bookmarks persistence
  final RxList<String> bookmarkedIds = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _bindStreams();
    _loadBookmarks();
  }

  void _bindStreams() {
    categories.bindStream(_service.watchCategories());
    allVideos.bindStream(_service.watchVideos());
  }

  void _loadBookmarks() {
    final List<dynamic>? saved = _storage.read<List<dynamic>>('bookmarked_tutorials');
    if (saved != null) {
      bookmarkedIds.assignAll(saved.map((id) => id.toString()).toList());
    }
  }

  void toggleBookmark(String id) {
    if (bookmarkedIds.contains(id)) {
      bookmarkedIds.remove(id);
    } else {
      bookmarkedIds.add(id);
    }
    _storage.write('bookmarked_tutorials', bookmarkedIds.toList());
  }

  bool isBookmarked(String id) {
    return bookmarkedIds.contains(id);
  }

  // Getters
  List<VideoTutorialModel> get featuredVideos {
    return allVideos.where((v) => v.isFeatured).toList();
  }

  List<VideoTutorialModel> get filteredVideos {
    List<VideoTutorialModel> list = allVideos;

    // Filter by Category
    if (selectedCategoryId.value != 'All') {
      list = list.where((v) => v.categoryId == selectedCategoryId.value).toList();
    }

    // Filter by Search Query
    if (searchQuery.value.trim().isNotEmpty) {
      final query = searchQuery.value.toLowerCase().trim();
      list = list.where((v) => 
        v.title.toLowerCase().contains(query) || 
        v.description.toLowerCase().contains(query) ||
        v.deviceName.toLowerCase().contains(query)
      ).toList();
    }

    return list;
  }
}
