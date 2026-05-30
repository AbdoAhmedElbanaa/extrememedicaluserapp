class ErrorCodeModel {
  final String id;
  final String code;
  final String title;
  final String description;
  final String severity; // 'low', 'medium', 'critical'
  final List<String> causes;
  final List<String> steps;
  final String? tutorialTitle;
  final String? tutorialDuration;

  ErrorCodeModel({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.severity,
    required this.causes,
    required this.steps,
    this.tutorialTitle,
    this.tutorialDuration,
  });

  factory ErrorCodeModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return ErrorCodeModel(
      id: id,
      code: map['code']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      severity: map['severity']?.toString() ?? 'medium',
      causes: List<String>.from(map['causes'] ?? []),
      steps: List<String>.from(map['steps'] ?? []),
      tutorialTitle: map['tutorialTitle']?.toString(),
      tutorialDuration: map['tutorialDuration']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'title': title,
      'description': description,
      'severity': severity,
      'causes': causes,
      'steps': steps,
      'tutorialTitle': tutorialTitle,
      'tutorialDuration': tutorialDuration,
    };
  }
}
