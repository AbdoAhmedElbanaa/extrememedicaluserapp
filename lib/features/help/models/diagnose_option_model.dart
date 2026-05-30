class DiagnoseOptionModel {
  final String id;
  final String title;
  final String iconName;
  final String colorHex;
  final String description;
  final List<String> steps;

  DiagnoseOptionModel({
    required this.id,
    required this.title,
    required this.iconName,
    required this.colorHex,
    required this.description,
    required this.steps,
  });

  factory DiagnoseOptionModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return DiagnoseOptionModel(
      id: id,
      title: map['title']?.toString() ?? '',
      iconName: map['iconName']?.toString() ?? 'warning',
      colorHex: map['colorHex']?.toString() ?? '#6366f1',
      description: map['description']?.toString() ?? '',
      steps: List<String>.from(map['steps'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'iconName': iconName,
      'colorHex': colorHex,
      'description': description,
      'steps': steps,
    };
  }
}
