import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import 'package:extrememedicaluserapp/core/utils/responsive_layout.dart';
import '../controllers/diagnose_controller.dart';
import '../../data/models/diagnose_result_model.dart';
import '../widgets/scanner_widget.dart';
import '../widgets/diagnosis_result_card.dart';

class DiagnoseView extends GetView<DiagnoseController> {
  const DiagnoseView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0C21) : AppColors.backgroundLight,
      body: Stack(
        children: [
          // Background Glows
          if (isDark) ...[
            Positioned(
              top: -100,
              left: -50,
              child: _buildGlow(const Color(0xFF6366F1).withOpacity(0.08)),
            ),
            Positioned(
              bottom: -100,
              right: -50,
              child: _buildGlow(const Color(0xFFA855F7).withOpacity(0.08)),
            ),
          ],

          SafeArea(
            child: Column(
              children: [
                _buildHeader(context, isDark),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.all(context.responsive(20, tablet: 40)),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Obx(() {
                          if (controller.isScanning.value) {
                            return _buildScanningUI(isDark);
                          } else if (controller.diagnosisResult.value != null) {
                            return _buildResultsUI(isDark);
                          } else {
                            return _buildInitialUI(isDark, context);
                          }
                        }),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlow(Color color) {
    return Container(
      width: 400,
      height: 400,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 100,
            spreadRadius: 50,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(Icons.arrow_back_ios_new_rounded, 
              color: isDark ? Colors.white : Colors.black, size: 20),
          ),
          const SizedBox(width: 8),
          Text(
            "Smart Diagnose",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialUI(bool isDark, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Icon(
          Icons.biotech_rounded,
          size: 80,
          color: const Color(0xFF6366F1).withOpacity(0.8),
        ).animate(onPlay: (controller) => controller.repeat())
         .shimmer(duration: const Duration(seconds: 2), color: Colors.white24),
        const SizedBox(height: 30),
        Text(
          "Ready to Scan",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Our AI will analyze your device connectivity,\nsensors, and system health in real-time.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 50),
        _buildStartButton(),
      ],
    ).animate().fadeIn(duration: const Duration(milliseconds: 600)).slideY(begin: 0.1, end: 0);
  }

  Widget _buildStartButton() {
    return InkWell(
      onTap: () => controller.startDiagnosis(),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.radar_rounded, color: Colors.white),
            SizedBox(width: 12),
            Text(
              "Run Deep Analysis",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningUI(bool isDark) {
    return Column(
      children: [
        const ScannerWidget(),
        const SizedBox(height: 40),
        Obx(() => Text(
          controller.currentScanPhase.value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        )),
        const SizedBox(height: 20),
        Obx(() => Container(
          width: 300,
          height: 8,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: LinearProgressIndicator(
            value: controller.scanProgress.value,
            backgroundColor: Colors.transparent,
            valueColor: const AlwaysStoppedAnimation(Color(0xFF6366F1)),
          ),
        )),
        const SizedBox(height: 12),
        Obx(() => Text(
          "${(controller.scanProgress.value * 100).toInt()}%",
          style: const TextStyle(
            color: Color(0xFF6366F1),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        )),
      ],
    );
  }

  Widget _buildResultsUI(bool isDark) {
    final result = controller.diagnosisResult.value!;
    return Column(
      children: [
        DiagnosisResultCard(result: result),
        const SizedBox(height: 30),
        _buildActionButtons(isDark),
      ],
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildActionButtons(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => controller.reset(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              side: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
              shape: RoundedRectangle_circular(20),
            ),
            child: Text("Scan Again", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              backgroundColor: const Color(0xFF6366F1),
              shape: RoundedRectangle_circular(20),
            ),
            child: const Text("Done", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  RoundedRectangleBorder RoundedRectangle_circular(double radius) => 
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
}
