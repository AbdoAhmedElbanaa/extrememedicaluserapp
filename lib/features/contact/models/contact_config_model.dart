class ContactConfigModel {
  final String status;
  final String responseTimeText;
  final String responseTime;
  final List<String> subjects;

  ContactConfigModel({
    required this.status,
    required this.responseTimeText,
    required this.responseTime,
    this.subjects = const [
      'Device Not Working',
      'Calibration Needed',
      'Data Sync Error',
      'Billing & Payments',
      'Software/Update Issue',
      'Other Query'
    ],
  });

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'responseTimeText': responseTimeText,
      'responseTime': responseTime,
      'subjects': subjects,
    };
  }

  factory ContactConfigModel.fromMap(Map<String, dynamic> map) {
    return ContactConfigModel(
      status: map['status'] ?? 'online',
      responseTimeText: map['responseTimeText'] ?? 'We typically reply in 2–4 hours',
      responseTime: map['responseTime'] ?? '2-4 business hours',
      subjects: map['subjects'] != null
          ? List<String>.from(map['subjects'] as List)
          : [
              'Device Not Working',
              'Calibration Needed',
              'Data Sync Error',
              'Billing & Payments',
              'Software/Update Issue',
              'Other Query'
            ],
    );
  }
}
