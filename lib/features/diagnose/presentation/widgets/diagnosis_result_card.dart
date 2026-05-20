import 'package:flutter/material.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import '../../data/models/diagnose_result_model.dart';

class DiagnosisResultCard extends StatelessWidget {
  final DiagnoseResultModel result;

  const DiagnosisResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cinematicSurface : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isDark ? AppColors.distinctBorderDark : AppColors
              .distinctBorderLight,
          width: 1.5,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: Column(
        children: [
          _buildScoreHeader(),
          const SizedBox(height: 24),
          Text(
            result.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            result.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: (isDark ? Colors.white : Colors.black).withValues(
                  alpha: 0.6),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 30),
          const Divider(height: 1),
          const SizedBox(height: 20),
          ...result.details.map((detail) => _buildDetailRow(detail, isDark)),
        ],
      ),
    );
  }

  Widget _buildScoreHeader() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(
            value: result.score,
            strokeWidth: 10,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            strokeCap: StrokeCap.round,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${(result.score * 100).toInt()}%",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const Text(
              "Health",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(DiagnoseDetail detail, bool isDark) {
    Color statusColor;
    IconData statusIcon;

    switch (detail.status) {
      case DiagnoseStatus.healthy:
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle_outline_rounded;
        break;
      case DiagnoseStatus.warning:
        statusColor = AppColors.warning;
        statusIcon = Icons.error_outline_rounded;
        break;
      case DiagnoseStatus.critical:
        statusColor = AppColors.errorRed;
        statusIcon = Icons.cancel_outlined;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline_rounded;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(statusIcon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              detail.label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          Text(
            detail.value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}
