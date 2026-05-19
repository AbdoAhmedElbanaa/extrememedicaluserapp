enum DiagnoseStatus { healthy, warning, critical, scanning }

class DiagnoseResultModel {
  final String title;
  final String description;
  final DiagnoseStatus status;
  final double score; // 0.0 to 1.0
  final List<DiagnoseDetail> details;
  final DateTime timestamp;

  DiagnoseResultModel({
    required this.title,
    required this.description,
    required this.status,
    required this.score,
    required this.details,
    required this.timestamp,
  });
}

class DiagnoseDetail {
  final String label;
  final String value;
  final DiagnoseStatus status;

  DiagnoseDetail({
    required this.label,
    required this.value,
    required this.status,
  });
}
