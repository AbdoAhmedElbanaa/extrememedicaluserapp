import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import 'package:extrememedicaluserapp/core/utils/responsive_layout.dart';
import '../controllers/manual_controller.dart';
import '../../data/models/manual_step_model.dart';
import '../widgets/manual_header.dart';

class ManualView extends GetView<ManualController> {
  const ManualView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0C21) : AppColors.backgroundLight,
      body: Stack(
        children: [
          // Background Glow for cinematic feel
          if (isDark)
            Positioned(
              top: -100,
              right: -50,
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF6366F1).withOpacity(0.12),
                    ),
                  ),
                ),
              ),
            ),

          Column(
            children: [
              const ManualHeader(),
              Expanded(
                child: SmartRefresher(
                  controller: controller.refreshController,
                  onRefresh: controller.onRefresh,
                  header: WaterDropMaterialHeader(
                    backgroundColor: AppColors.primary,
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          Obx(() => SliverPadding(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.responsive(20, tablet: 40, desktop: 60),
                              vertical: 20,
                            ),
                            sliver: context.isMobileLayout
                                ? _buildMobileList(context, isDark)
                                : _buildWideGrid(context, isDark),
                          )),
                          SliverPadding(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.responsive(20, tablet: 40, desktop: 60),
                            ),
                            sliver: SliverToBoxAdapter(
                              child: _buildSupportCard(isDark),
                            ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 120)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileList(BuildContext context, bool isDark) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return _buildStepCard(controller.manualSteps[index], isDark, context);
        },
        childCount: controller.manualSteps.length,
      ),
    );
  }

  Widget _buildWideGrid(BuildContext context, bool isDark) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        // Make height dynamic based on content or use a reasonable fixed height
        mainAxisExtent: context.responsive(320, tablet: 340, desktop: 360),
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return _buildStepCard(controller.manualSteps[index], isDark, context);
        },
        childCount: controller.manualSteps.length,
      ),
    );
  }

  Widget _buildStepCard(ManualStepModel step, bool isDark, BuildContext context) {
    final bool isWide = !context.isMobileLayout;
    
    return Container(
      margin: EdgeInsets.only(bottom: isWide ? 0 : 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161531) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
          width: 1.2,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Step Number + Title
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${step.stepNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  step.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Description
          Expanded(
            flex: isWide ? 1 : 0,
            child: Text(
              step.description,
              maxLines: isWide ? 4 : null,
              overflow: isWide ? TextOverflow.ellipsis : TextOverflow.visible,
              style: TextStyle(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
          
          // Optional Note (Info or Warning)
          if (step.noteText != null) ...[
            const SizedBox(height: 16),
            _buildNoteBox(step.noteText!, step.noteType, isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildNoteBox(String text, StepNoteType type, bool isDark) {
    final Color bgColor = type == StepNoteType.warning 
        ? const Color(0xFFFEF3C7).withOpacity(isDark ? 0.05 : 0.5)
        : const Color(0xFFE0E7FF).withOpacity(isDark ? 0.05 : 0.5);
    
    final Color borderColor = type == StepNoteType.warning
        ? const Color(0xFFF59E0B).withOpacity(0.3)
        : const Color(0xFF6366F1).withOpacity(0.3);

    final Color iconColor = type == StepNoteType.warning ? const Color(0xFFF59E0B) : const Color(0xFF6366F1);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            type == StepNoteType.warning ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
            color: iconColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.white.withOpacity(0.8) : Colors.black.withOpacity(0.7),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161531).withOpacity(0.4) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
          width: 1.5,
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Icon(
            Icons.menu_book_rounded,
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.3),
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            'Need more help? ',
            style: TextStyle(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.4),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            'Contact Support',
            style: TextStyle(
              color: const Color(0xFF6366F1).withOpacity(0.8),
              fontSize: 15,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }
}
