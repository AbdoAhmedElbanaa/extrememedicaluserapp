class ChatMessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final int timestamp;
  final bool isSystem;
  final String type; // 'text' | 'image' | 'video' | 'audio'
  final String? mediaUrl;

  ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    this.isSystem = false,
    this.type = 'text',
    this.mediaUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'timestamp': timestamp,
      'isSystem': isSystem,
      'type': type,
      'mediaUrl': mediaUrl,
    };
  }

  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      message: map['message'] ?? '',
      timestamp: map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      isSystem: map['isSystem'] ?? false,
      type: map['type'] ?? 'text',
      mediaUrl: map['mediaUrl'],
    );
  }
}
