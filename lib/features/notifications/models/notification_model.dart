class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime receivedAt;
  final bool isRead;
  final String? route;
  final String? ticketId;
  final Map<String, dynamic> payload;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.receivedAt,
    this.isRead = false,
    this.route,
    this.ticketId,
    this.payload = const {},
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? receivedAt,
    bool? isRead,
    String? route,
    String? ticketId,
    Map<String, dynamic>? payload,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      receivedAt: receivedAt ?? this.receivedAt,
      isRead: isRead ?? this.isRead,
      route: route ?? this.route,
      ticketId: ticketId ?? this.ticketId,
      payload: payload ?? this.payload,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'receivedAt': receivedAt.toIso8601String(),
      'isRead': isRead,
      'route': route,
      'ticketId': ticketId,
      'payload': payload,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      receivedAt: map['receivedAt'] != null 
          ? DateTime.parse(map['receivedAt']) 
          : DateTime.now(),
      isRead: map['isRead'] ?? false,
      route: map['route'],
      ticketId: map['ticketId'],
      payload: Map<String, dynamic>.from(map['payload'] ?? {}),
    );
  }
}
