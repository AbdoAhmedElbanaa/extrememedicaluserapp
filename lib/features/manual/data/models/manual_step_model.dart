enum StepNoteType { info, warning, none }

class ManualStepModel {
  final String id;
  final int stepNumber;
  final String title;
  final String description;
  final String? noteText;
  final StepNoteType noteType;
  final String category;

  ManualStepModel({
    required this.id,
    required this.stepNumber,
    required this.title,
    required this.description,
    this.noteText,
    this.noteType = StepNoteType.none,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'stepNumber': stepNumber,
      'title': title,
      'description': description,
      'noteText': noteText,
      'noteType': noteType.name,
      'category': category,
    };
  }

  factory ManualStepModel.fromMap(Map<String, dynamic> map) {
    StepNoteType noteTypeVal = StepNoteType.none;
    if (map['noteType'] != null) {
      final str = map['noteType'].toString().toLowerCase();
      if (str == 'info') {
        noteTypeVal = StepNoteType.info;
      } else if (str == 'warning') {
        noteTypeVal = StepNoteType.warning;
      }
    }

    return ManualStepModel(
      id: map['id'] ?? '',
      stepNumber: map['stepNumber'] != null ? (map['stepNumber'] as num).toInt() : 1,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      noteText: map['noteText'],
      noteType: noteTypeVal,
      category: map['category'] ?? '',
    );
  }
}
