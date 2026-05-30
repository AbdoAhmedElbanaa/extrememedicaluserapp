import 'package:get/get.dart';

class VideoTutorialModel {
  final String id;
  final String title;
  final String description;
  final String url;
  final String duration;
  final String categoryId;
  final int views;
  final String deviceName;
  final bool isFeatured;
  final int timestamp;

  VideoTutorialModel({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.duration,
    required this.categoryId,
    required this.views,
    required this.deviceName,
    required this.isFeatured,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'url': url,
      'duration': duration,
      'categoryId': categoryId,
      'views': views,
      'deviceName': deviceName,
      'isFeatured': isFeatured,
      'timestamp': timestamp,
    };
  }

  factory VideoTutorialModel.fromMap(Map<String, dynamic> map) {
    return VideoTutorialModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      url: map['url'] ?? '',
      duration: map['duration'] ?? '0:00',
      categoryId: map['categoryId'] ?? '',
      views: map['views'] ?? 0,
      deviceName: map['deviceName'] ?? '',
      isFeatured: map['isFeatured'] ?? false,
      timestamp: map['timestamp'] ?? 0,
    );
  }

  // Resolve video URL path
  String get resolvedUrl {
    if (url.startsWith('uploads/')) {
      // For development, localhost points to host on iOS/Web/Desktop
      // and 10.0.2.2 points to host on Android Emulator.
      final String host = GetPlatform.isAndroid ? '10.0.2.2' : 'localhost';
      return 'http://$host:8000/$url';
    }
    return url;
  }
}
