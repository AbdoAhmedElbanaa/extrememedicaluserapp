class TicketModel {
  final String id;
  final String subject;
  final String priority;
  final String? errorCode;
  final String description;
  final String status;
  final String deviceName;
  final String serialNo;
  final int timestamp;
  final String userId;
  final String clinicName;
  final List<String> attachments;
  final String? resolutionText;
  final int? resolvedAt;
  final bool isChat;

  TicketModel({
    required this.id,
    required this.subject,
    required this.priority,
    this.errorCode,
    required this.description,
    this.status = 'IN REVIEW',
    required this.deviceName,
    required this.serialNo,
    required this.timestamp,
    required this.userId,
    required this.clinicName,
    required this.attachments,
    this.resolutionText,
    this.resolvedAt,
    this.isChat = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'priority': priority,
      'errorCode': errorCode,
      'description': description,
      'status': status,
      'deviceName': deviceName,
      'serialNo': serialNo,
      'timestamp': timestamp,
      'userId': userId,
      'clinicName': clinicName,
      'attachments': attachments,
      'resolutionText': resolutionText,
      'resolvedAt': resolvedAt,
      'isChat': isChat,
    };
  }

  factory TicketModel.fromMap(Map<String, dynamic> map) {
    return TicketModel(
      id: map['id'] ?? '',
      subject: map['subject'] ?? '',
      priority: map['priority'] ?? 'Medium',
      errorCode: map['errorCode'],
      description: map['description'] ?? '',
      status: map['status'] ?? 'IN REVIEW',
      deviceName: map['deviceName'] ?? '',
      serialNo: map['serialNo'] ?? '',
      timestamp: map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      userId: map['userId'] ?? '',
      clinicName: map['clinicName'] ?? '',
      attachments: map['attachments'] != null ? List<String>.from(map['attachments'] as List) : [],
      resolutionText: map['resolutionText'],
      resolvedAt: map['resolvedAt'],
      isChat: map['isChat'] ?? false,
    );
  }
}
