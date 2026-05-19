import 'package:get/get.dart';
import '../../data/models/diagnose_result_model.dart';
import 'dart:async';

class DiagnoseController extends GetxController {
  var isScanning = false.obs;
  var scanProgress = 0.0.obs;
  var currentScanPhase = "".obs;
  var diagnosisResult = Rxn<DiagnoseResultModel>();

  final List<String> _scanPhases = [
    "Initializing sensors...",
    "Establishing secure link...",
    "Scanning hardware components...",
    "Analyzing signal stability...",
    "Optimizing data packets...",
    "AI diagnosis in progress...",
    "Finalizing report..."
  ];

  Future<void> startDiagnosis() async {
    isScanning.value = true;
    scanProgress.value = 0.0;
    diagnosisResult.value = null;

    for (int i = 0; i < _scanPhases.length; i++) {
      currentScanPhase.value = _scanPhases[i];
      // Simulate work
      for(int step = 0; step < 10; step++) {
        await Future.delayed(const Duration(milliseconds: 150));
        scanProgress.value += (1.0 / (_scanPhases.length * 10));
      }
    }

    _completeDiagnosis();
  }

  void _completeDiagnosis() {
    isScanning.value = false;
    scanProgress.value = 1.0;
    
    // Mock Result
    diagnosisResult.value = DiagnoseResultModel(
      title: "System Optimized",
      description: "Smart scan completed. Your device and connection are performing at peak efficiency with minor battery optimization suggested.",
      status: DiagnoseStatus.healthy,
      score: 0.94,
      timestamp: DateTime.now(),
      details: [
        DiagnoseDetail(label: "Hardware Integrity", value: "98%", status: DiagnoseStatus.healthy),
        DiagnoseDetail(label: "Signal Strength", value: "Excellent", status: DiagnoseStatus.healthy),
        DiagnoseDetail(label: "Latency", value: "24ms", status: DiagnoseStatus.healthy),
        DiagnoseDetail(label: "Battery Health", value: "Needs Review", status: DiagnoseStatus.warning),
      ],
    );
  }

  void reset() {
    isScanning.value = false;
    scanProgress.value = 0.0;
    diagnosisResult.value = null;
  }
}
