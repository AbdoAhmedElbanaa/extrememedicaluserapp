import 'package:firebase_database/firebase_database.dart';
import '../models/video_category_model.dart';
import '../models/video_tutorial_model.dart';

class VideoTutorialsService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  // Stream of Categories list
  Stream<List<VideoCategoryModel>> watchCategories() {
    return _db.ref('video_tutorials/categories').onValue.map((event) {
      final List<VideoCategoryModel> list = [];
      final data = event.snapshot.value;
      if (data is Map) {
        data.forEach((key, val) {
          if (val != null) {
            list.add(VideoCategoryModel.fromMap(Map<String, dynamic>.from(val as Map)));
          }
        });
      }
      list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return list;
    });
  }

  // Stream of Videos list
  Stream<List<VideoTutorialModel>> watchVideos() {
    return _db.ref('video_tutorials/videos').onValue.map((event) {
      final List<VideoTutorialModel> list = [];
      final data = event.snapshot.value;
      if (data is Map) {
        data.forEach((key, val) {
          if (val != null) {
            list.add(VideoTutorialModel.fromMap(Map<String, dynamic>.from(val as Map)));
          }
        });
      }
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    });
  }
}
