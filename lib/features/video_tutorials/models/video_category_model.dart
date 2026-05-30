class VideoCategoryModel {
  final String id;
  final String name;
  final int timestamp;

  VideoCategoryModel({
    required this.id,
    required this.name,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'timestamp': timestamp,
    };
  }

  factory VideoCategoryModel.fromMap(Map<String, dynamic> map) {
    return VideoCategoryModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      timestamp: map['timestamp'] ?? 0,
    );
  }
}
