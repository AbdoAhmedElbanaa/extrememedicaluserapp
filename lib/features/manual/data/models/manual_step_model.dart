enum StepNoteType { info, warning, none }

class ManualStepModel {
  final int stepNumber;
  final String title;
  final String description;
  final String? noteText;
  final StepNoteType noteType;
  final String category;

  ManualStepModel({
    required this.stepNumber,
    required this.title,
    required this.description,
    this.noteText,
    this.noteType = StepNoteType.none,
    required this.category,
  });
}
