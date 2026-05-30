import 'package:get/get.dart';

class FaqModel {
  final String id;
  final String question;
  final String answer;
  final RxBool isExpanded;

  FaqModel({
    required this.id,
    required this.question,
    required this.answer,
    bool initialExpanded = false,
  }) : isExpanded = initialExpanded.obs;

  factory FaqModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return FaqModel(
      id: id,
      question: map['question']?.toString() ?? '',
      answer: map['answer']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'answer': answer,
    };
  }
}
