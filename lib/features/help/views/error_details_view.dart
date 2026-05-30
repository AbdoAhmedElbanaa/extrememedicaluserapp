import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import '../models/error_code_model.dart';

class ErrorDetailsView extends StatelessWidget {
  const ErrorDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ErrorCodeModel? error = Get.arguments is ErrorCodeModel ? Get.arguments as ErrorCodeModel : null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (error == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.errorRed, size: 50),
              const SizedBox(height: 16),
              const Text('Error details could not be loaded.'),
              TextButton(onPressed: () => Get.back(), child: const Text('Go Back')),
            ],
          ),
        ),
      );
    }

    Color severityColor;
    switch (error.severity.toLowerCase()) {
      case 'critical':
        severityColor = AppColors.errorRed;
        break;
      case 'medium':
        severityColor = AppColors.warning;
        break;
      case 'low':
      default:
        severityColor = AppColors.success;
        break;
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildErrorCardHeader(error, isDark, severityColor),
                        const SizedBox(height: 24),
                        _buildPossibleCauses(error, isDark, severityColor),
                        const SizedBox(height: 24),
                        _buildStepByStepFix(error, isDark, severityColor),
                        const SizedBox(height: 24),
                        if (error.tutorialTitle != null) ...[
                          _buildTutorialCard(error, isDark),
                          const SizedBox(height: 24),
                        ],
                        _buildActionButtons(context, error, isDark, severityColor),
                        const SizedBox(height: 30),
                        _buildContactSupportLink(context, isDark),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HEADER ---
  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: isDark ? Border.all(color: Colors.white.withValues(alpha: 0.1)) : Border.all(color: AppColors.borderLight),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: isDark ? Colors.white : AppColors.deepNavy,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Error Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.deepNavy,
            ),
          ),
        ],
      ),
    );
  }

  // --- GLOWING ERROR CARD HEADER ---
  Widget _buildErrorCardHeader(ErrorCodeModel error, bool isDark, Color severityColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? severityColor.withValues(alpha: 0.06) : severityColor.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: severityColor.withValues(alpha: 0.25),
          width: 2,
        ),
        boxShadow: [
          if (isDark)
            BoxShadow(
              color: severityColor.withValues(alpha: 0.05),
              blurRadius: 25,
              spreadRadius: 2,
            )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Code Box
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: severityColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: severityColor.withValues(alpha: 0.3), width: 1.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded, size: 18, color: severityColor),
                    const SizedBox(height: 2),
                    Text(
                      error.code,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: severityColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Title & Severity Badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      error.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Severity badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: severityColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: severityColor.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(color: severityColor, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${error.severity.toUpperCase()} SEVERITY',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: severityColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            error.description,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            ),
          ),
        ],
      ),
    );
  }

  // --- POSSIBLE CAUSES ---
  Widget _buildPossibleCauses(ErrorCodeModel error, bool isDark, Color severityColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Possible Causes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.deepNavy,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.02) : AppColors.cardLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
            ),
          ),
          child: Column(
            children: List.generate(error.causes.length, (index) {
              return Padding(
                padding: EdgeInsets.only(bottom: index == error.causes.length - 1 ? 0 : 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(color: severityColor, shape: BoxShape.circle),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        error.causes[index],
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // --- STEP-BY-STEP FIX ---
  Widget _buildStepByStepFix(ErrorCodeModel error, bool isDark, Color severityColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step-by-Step Fix',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.deepNavy,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: List.generate(error.steps.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.02) : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
                        ),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        error.steps[index],
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.45,
                          color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // --- VIDEO TUTORIAL LAUNCHER ---
  Widget _buildTutorialCard(ErrorCodeModel error, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.indigoDeep : AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1.2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.snackbar(
              'Video Tutorial',
              'Playing guide: ${error.tutorialTitle}...',
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              colorText: isDark ? Colors.white : AppColors.primary,
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        error.tutorialTitle!,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Video guide for ${error.code} · ${error.tutorialDuration ?? "N/A"}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: isDark ? AppColors.textMutedDark.withValues(alpha: 0.5) : AppColors.textMutedLight.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- ACTION BUTTONS ROW ---
  Widget _buildActionButtons(BuildContext context, ErrorCodeModel error, bool isDark, Color severityColor) {
    return Row(
      children: [
        // Try Quick Fix
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                Get.snackbar(
                  'Quick Fix',
                  'Initiating remote reset for ${error.code}...',
                  backgroundColor: severityColor.withValues(alpha: 0.1),
                  colorText: isDark ? Colors.white : severityColor,
                );
              },
              icon: const Icon(Icons.bolt_rounded, color: Colors.white),
              label: const Text(
                'Try Quick Fix',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: severityColor,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Help button
        Expanded(
          flex: 1,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
              ),
            ),
            child: TextButton.icon(
              onPressed: () {
                Get.snackbar('Support', 'Connecting you with a support representative...');
              },
              icon: Icon(Icons.chat_bubble_outline_rounded, color: isDark ? Colors.white : AppColors.deepNavy),
              label: Text(
                'Help',
                style: TextStyle(color: isDark ? Colors.white : AppColors.deepNavy, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- CONTACT SUPPORT LINK ---
  Widget _buildContactSupportLink(BuildContext context, bool isDark) {
    return Center(
      child: GestureDetector(
        onTap: () {
          Get.snackbar('Support', 'Opening support tickets...');
        },
        child: RichText(
          text: TextSpan(
            text: 'Still not solved? ',
            style: TextStyle(color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight, fontSize: 13),
            children: [
              TextSpan(
                text: 'Contact Support →',
                style: TextStyle(
                  color: isDark ? AppColors.indigoSoft : AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
