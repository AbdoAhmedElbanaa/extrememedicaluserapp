import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import 'package:extrememedicaluserapp/core/utils/responsive_layout.dart';
import 'package:extrememedicaluserapp/core/routes/app_routes.dart';
import '../controllers/knowledge_center_controller.dart';
import '../models/faq_model.dart';
import '../models/error_code_model.dart';
import '../models/diagnose_option_model.dart';

class KnowledgeCenterView extends GetView<KnowledgeCenterController> {
  const KnowledgeCenterView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: _buildMobileLayout(context, isDark),
          tablet: _buildTabletLayout(context, isDark),
          desktop: _buildDesktopLayout(context, isDark),
        ),
      ),
    );
  }

  // --- MOBILE LAYOUT ---
  Widget _buildMobileLayout(BuildContext context, bool isDark) {
    return Column(
      children: [
        _buildHeader(context, isDark, isMobile: true),
        _buildSearchBar(isDark),
        _buildTabs(isDark),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            return SmartRefresher(
              controller: controller.refreshController,
              onRefresh: controller.onRefresh,
              header: const WaterDropMaterialHeader(
                backgroundColor: AppColors.primary,
                color: Colors.white,
              ),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 10)),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    sliver: _buildContentForActiveTab(context, isDark),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  // --- TABLET LAYOUT ---
  Widget _buildTabletLayout(BuildContext context, bool isDark) {
    return _buildWideLayout(context, isDark);
  }

  // --- DESKTOP LAYOUT ---
  Widget _buildDesktopLayout(BuildContext context, bool isDark) {
    return _buildWideLayout(context, isDark);
  }

  // --- MASTER-DETAIL WIDE LAYOUT (TABLET & DESKTOP) ---
  Widget _buildWideLayout(BuildContext context, bool isDark) {
    return Column(
      children: [
        _buildHeader(context, isDark, isMobile: false),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Row(
            children: [
              Expanded(child: _buildSearchBar(isDark, horizontalPadding: 0)),
              const SizedBox(width: 20),
              SizedBox(width: 380, child: _buildTabs(isDark, horizontalPadding: 0)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Navigation / Content List
              Expanded(
                flex: 4,
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }
                  return SmartRefresher(
                    controller: controller.refreshController,
                    onRefresh: controller.onRefresh,
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 10.0),
                          sliver: _buildWideContentList(context, isDark),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 40)),
                      ],
                    ),
                  );
                }),
              ),
              // Vertical Divider
              Container(
                width: 1.5,
                height: double.infinity,
                color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
                margin: const EdgeInsets.symmetric(vertical: 16),
              ),
              // Right Column: Detailed View Pane
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 10, 32, 40),
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const SizedBox();
                    }
                    return _buildWideDetailPane(context, isDark);
                  }),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWideContentList(BuildContext context, bool isDark) {
    switch (controller.activeTabIndex.value) {
      case 0: // All
        return _buildWideAllTabList(context, isDark);
      case 1: // FAQs
        return _buildWideFaqsList(isDark);
      case 2: // Error Codes
        return _buildWideErrorsList(context, isDark);
      case 3: // Diagnose
        return _buildWideDiagnoseGrid(context, isDark);
      default:
        return const SliverToBoxAdapter(child: SizedBox());
    }
  }

  Widget _buildWideAllTabList(BuildContext context, bool isDark) {
    final hasFaqs = controller.filteredFaqs.isNotEmpty;
    final hasErrors = controller.filteredErrors.isNotEmpty;
    final hasDiagnose = controller.filteredDiagnoseOptions.isNotEmpty;

    if (!hasFaqs && !hasErrors && !hasDiagnose) {
      return _buildEmptySearchState(isDark);
    }

    return SliverList(
      delegate: SliverChildListDelegate([
        if (hasErrors) ...[
          _buildSectionHeader('ERROR CODES', isDark),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.filteredErrors.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final err = controller.filteredErrors[index];
              return Obx(() {
                final isSelected = controller.selectedError.value?.id == err.id;
                return _ErrorCodeWideTile(
                  errorCode: err,
                  isDark: isDark,
                  isSelected: isSelected,
                  onTap: () {
                    controller.selectedError.value = err;
                  },
                );
              });
            },
          ),
          const SizedBox(height: 24),
        ],
        if (hasDiagnose) ...[
          _buildSectionHeader('DIAGNOSTICS & TROUBLESHOOTING', isDark),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
            ),
            itemCount: controller.filteredDiagnoseOptions.length,
            itemBuilder: (context, index) {
              final opt = controller.filteredDiagnoseOptions[index];
              return Obx(() {
                final isSelected = controller.selectedDiagnose.value?.id == opt.id;
                return _DiagnoseWideCard(
                  option: opt,
                  isDark: isDark,
                  isSelected: isSelected,
                  onTap: () {
                    controller.selectedDiagnose.value = opt;
                  },
                );
              });
            },
          ),
          const SizedBox(height: 24),
        ],
        if (hasFaqs) ...[
          _buildSectionHeader('FREQUENTLY ASKED QUESTIONS', isDark),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.filteredFaqs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final faq = controller.filteredFaqs[index];
              return Obx(() {
                final isSelected = controller.selectedFaq.value?.id == faq.id;
                return _FaqWideTile(
                  faq: faq,
                  isDark: isDark,
                  isSelected: isSelected,
                  onTap: () {
                    controller.selectedFaq.value = faq;
                  },
                );
              });
            },
          ),
        ],
      ]),
    );
  }

  Widget _buildWideFaqsList(bool isDark) {
    if (controller.filteredFaqs.isEmpty) {
      return _buildEmptySearchState(isDark);
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final faq = controller.filteredFaqs[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Obx(() {
              final isSelected = controller.selectedFaq.value?.id == faq.id;
              return _FaqWideTile(
                faq: faq,
                isDark: isDark,
                isSelected: isSelected,
                onTap: () {
                  controller.selectedFaq.value = faq;
                },
              );
            }),
          );
        },
        childCount: controller.filteredFaqs.length,
      ),
    );
  }

  Widget _buildWideErrorsList(BuildContext context, bool isDark) {
    if (controller.filteredErrors.isEmpty) {
      return _buildEmptySearchState(isDark);
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final err = controller.filteredErrors[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Obx(() {
              final isSelected = controller.selectedError.value?.id == err.id;
              return _ErrorCodeWideTile(
                errorCode: err,
                isDark: isDark,
                isSelected: isSelected,
                onTap: () {
                  controller.selectedError.value = err;
                },
              );
            }),
          );
        },
        childCount: controller.filteredErrors.length,
      ),
    );
  }

  Widget _buildWideDiagnoseGrid(BuildContext context, bool isDark) {
    if (controller.filteredDiagnoseOptions.isEmpty) {
      return _buildEmptySearchState(isDark);
    }
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final opt = controller.filteredDiagnoseOptions[index];
          return Obx(() {
            final isSelected = controller.selectedDiagnose.value?.id == opt.id;
            return _DiagnoseWideCard(
              option: opt,
              isDark: isDark,
              isSelected: isSelected,
              onTap: () {
                controller.selectedDiagnose.value = opt;
              },
            );
          });
        },
        childCount: controller.filteredDiagnoseOptions.length,
      ),
    );
  }

  Widget _buildWideDetailPane(BuildContext context, bool isDark) {
    switch (controller.activeTabIndex.value) {
      case 0: // All
        // Try to show whichever type is selected or fallback
        final err = controller.selectedError.value;
        if (err != null) {
          return _buildWideErrorDetail(context, err, isDark);
        }
        final opt = controller.selectedDiagnose.value;
        if (opt != null) {
          return _buildWideDiagnoseDetail(context, opt, isDark);
        }
        final faq = controller.selectedFaq.value;
        if (faq != null) {
          return _buildWideFaqDetail(faq, isDark);
        }
        return _buildWideNoSelectionPlaceholder('Select an item from the list');
      case 1: // FAQs
        final faq = controller.selectedFaq.value;
        if (faq == null) {
          return _buildWideNoSelectionPlaceholder('Select an FAQ from the list');
        }
        return _buildWideFaqDetail(faq, isDark);
      case 2: // Error Codes
        final err = controller.selectedError.value;
        if (err == null) {
          return _buildWideNoSelectionPlaceholder('Select an Error Code from the list');
        }
        return _buildWideErrorDetail(context, err, isDark);
      case 3: // Diagnose
        final opt = controller.selectedDiagnose.value;
        if (opt == null) {
          return _buildWideNoSelectionPlaceholder('Select a Diagnostic type from the list');
        }
        return _buildWideDiagnoseDetail(context, opt, isDark);
      default:
        return const SizedBox();
    }
  }

  Widget _buildWideNoSelectionPlaceholder(String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline_rounded, size: 48, color: Colors.white24),
          const SizedBox(height: 16),
          Text(
            text,
            style: const TextStyle(fontSize: 15, color: Colors.white30, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildWideFaqDetail(FaqModel faq, bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FREQUENTLY ASKED QUESTION',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            faq.question,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.deepNavy,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.02) : AppColors.cardLight,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.question_answer_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'ANSWER',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  faq.answer,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWideErrorDetail(BuildContext context, ErrorCodeModel error, bool isDark) {
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

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? severityColor.withValues(alpha: 0.06) : severityColor.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: severityColor.withValues(alpha: 0.25),
                width: 2,
              ),
              boxShadow: [
                if (isDark)
                  BoxShadow(
                    color: severityColor.withValues(alpha: 0.05),
                    blurRadius: 25,
                  )
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        error.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
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
          ),
          const SizedBox(height: 24),
          Text(
            error.description,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
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
          const SizedBox(height: 24),
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
          const SizedBox(height: 24),
          if (error.tutorialTitle != null) ...[
            _buildWideTutorialCard(error, isDark),
            const SizedBox(height: 24),
          ],
          _buildWideActionButtons(context, error, isDark, severityColor),
        ],
      ),
    );
  }

  Widget _buildWideTutorialCard(ErrorCodeModel error, bool isDark) {
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

  Widget _buildWideActionButtons(BuildContext context, ErrorCodeModel error, bool isDark, Color severityColor) {
    return Row(
      children: [
        Expanded(
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
        Expanded(
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
                'Help & Support',
                style: TextStyle(color: isDark ? Colors.white : AppColors.deepNavy, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWideDiagnoseDetail(BuildContext context, DiagnoseOptionModel option, bool isDark) {
    final color = _parseColor(option.colorHex);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(_getIconData(option.iconName), color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            'TROUBLESHOOTING STEPS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: List.generate(option.steps.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        option.steps[index],
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.snackbar(
                      'Test Run',
                      'Simulating diagnostic check...',
                      backgroundColor: color.withValues(alpha: 0.1),
                      colorText: isDark ? Colors.white : color,
                    );
                  },
                  icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                  label: const Text('Run Live Diagnostics', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- HEADER WIDGET ---
  Widget _buildHeader(BuildContext context, bool isDark, {required bool isMobile}) {
    final padding = isMobile ? 24.0 : 32.0;
    return Padding(
      padding: EdgeInsets.fromLTRB(padding, 20, padding, 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Knowledge Center',
                style: TextStyle(
                  fontSize: isMobile ? 28 : 34,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.foregroundLight,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'FAQs · Errors · Diagnostics',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
                ),
              ),
              child: const Icon(Icons.close_rounded, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  // --- SEARCH BAR ---
  Widget _buildSearchBar(bool isDark, {double horizontalPadding = 24.0}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 10),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: isDark ? AppColors.deepNavy.withValues(alpha: 0.5) : AppColors.mutedLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
          ),
        ),
        child: TextField(
          onChanged: (val) => controller.setSearchQuery(val),
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: 'Search FAQs, error codes (e.g. E102)...',
            hintStyle: TextStyle(
              color: isDark ? Colors.white30 : Colors.black38,
              fontSize: 15,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Icon(
                Icons.search_rounded,
                color: isDark ? Colors.white30 : Colors.black38,
                size: 24,
              ),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  // --- TABS SELECTOR ---
  Widget _buildTabs(bool isDark, {double horizontalPadding = 24.0}) {
    final tabs = ['All', 'FAQs', 'Error Codes', 'Diagnose'];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 15),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cinematicSurface.withValues(alpha: 0.3) : AppColors.mutedLight.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
          ),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: List.generate(tabs.length, (index) {
            return Expanded(
              child: Obx(() {
                final isSelected = controller.activeTabIndex.value == index;
                return GestureDetector(
                  onTap: () => controller.changeTab(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? AppColors.primary.withValues(alpha: 0.2) : AppColors.primary)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: AppColors.primary.withValues(alpha: 0.5))
                          : null,
                    ),
                    child: Text(
                      tabs[index],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
        ),
      ),
    );
  }

  // --- CONTENT SWITCHER ---
  Widget _buildContentForActiveTab(BuildContext context, bool isDark) {
    switch (controller.activeTabIndex.value) {
      case 0: // All
        return _buildAllTab(context, isDark);
      case 1: // FAQs
        return _buildFaqsList(isDark);
      case 2: // Error Codes
        return _buildErrorsList(context, isDark);
      case 3: // Diagnose
        return _buildDiagnoseGrid(context, isDark);
      default:
        return const SliverToBoxAdapter(child: SizedBox());
    }
  }

  // --- ALL TAB ---
  Widget _buildAllTab(BuildContext context, bool isDark) {
    final hasFaqs = controller.filteredFaqs.isNotEmpty;
    final hasErrors = controller.filteredErrors.isNotEmpty;
    final hasDiagnose = controller.filteredDiagnoseOptions.isNotEmpty;

    if (!hasFaqs && !hasErrors && !hasDiagnose) {
      return _buildEmptySearchState(isDark);
    }

    return SliverList(
      delegate: SliverChildListDelegate([
        if (hasErrors) ...[
          _buildSectionHeader('ERROR CODES', isDark),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.filteredErrors.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _ErrorCodeCard(
                errorCode: controller.filteredErrors[index],
                isDark: isDark,
              );
            },
          ),
          const SizedBox(height: 24),
        ],
        if (hasDiagnose) ...[
          _buildSectionHeader('DIAGNOSTICS & TROUBLESHOOTING', isDark),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: context.responsive<int>(2, tablet: 3, desktop: 3),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            itemCount: controller.filteredDiagnoseOptions.length,
            itemBuilder: (context, index) {
              return _DiagnoseCard(
                option: controller.filteredDiagnoseOptions[index],
                isDark: isDark,
              );
            },
          ),
          const SizedBox(height: 24),
        ],
        if (hasFaqs) ...[
          _buildSectionHeader('FREQUENTLY ASKED QUESTIONS', isDark),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.filteredFaqs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _FaqAccordionItem(
                faq: controller.filteredFaqs[index],
                isDark: isDark,
              );
            },
          ),
        ],
      ]),
    );
  }

  // --- FAQS TAB ---
  Widget _buildFaqsList(bool isDark) {
    if (controller.filteredFaqs.isEmpty) {
      return _buildEmptySearchState(isDark);
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _FaqAccordionItem(
              faq: controller.filteredFaqs[index],
              isDark: isDark,
            ),
          );
        },
        childCount: controller.filteredFaqs.length,
      ),
    );
  }

  // --- ERRORS TAB ---
  Widget _buildErrorsList(BuildContext context, bool isDark) {
    if (controller.filteredErrors.isEmpty) {
      return _buildEmptySearchState(isDark);
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _ErrorCodeCard(
              errorCode: controller.filteredErrors[index],
              isDark: isDark,
            ),
          );
        },
        childCount: controller.filteredErrors.length,
      ),
    );
  }

  // --- DIAGNOSE TAB ---
  Widget _buildDiagnoseGrid(BuildContext context, bool isDark) {
    if (controller.filteredDiagnoseOptions.isEmpty) {
      return _buildEmptySearchState(isDark);
    }
    return SliverList(
      delegate: SliverChildListDelegate([
        // Diagnose Intro Block
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.primary.withValues(alpha: 0.08) : AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Interactive Diagnostic Tool',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.primary : AppColors.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Select your problem type and we\'ll guide you to a solution.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: context.responsive<int>(2, tablet: 3, desktop: 3),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
          ),
          itemCount: controller.filteredDiagnoseOptions.length,
          itemBuilder: (context, index) {
            return _DiagnoseCard(
              option: controller.filteredDiagnoseOptions[index],
              isDark: isDark,
            );
          },
        ),
      ]),
    );
  }

  // --- SECTION HEADER ---
  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
      ),
    );
  }

  // --- EMPTY SEARCH STATE ---
  Widget _buildEmptySearchState(bool isDark) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 56,
              color: isDark ? Colors.white12 : Colors.black12,
            ),
            const SizedBox(height: 16),
            Text(
              'No items match your search',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// WIDGET: FAQ ACCORDION ITEM
// ==========================================
class _FaqAccordionItem extends StatelessWidget {
  final FaqModel faq;
  final bool isDark;

  const _FaqAccordionItem({required this.faq, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isExpanded = faq.isExpanded.value;
      return GestureDetector(
        onTap: () => faq.isExpanded.value = !isExpanded,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: isExpanded ? 0.05 : 0.02)
                : AppColors.cardLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? (isExpanded ? AppColors.primary.withValues(alpha: 0.3) : AppColors.distinctBorderDark)
                  : (isExpanded ? AppColors.primary.withValues(alpha: 0.3) : AppColors.distinctBorderLight),
              width: 1.2,
            ),
            boxShadow: [
              if (!isDark && isExpanded)
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.primary.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.help_outline_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      faq.question,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    ),
                  ),
                ],
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox(width: double.infinity),
                secondChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 1.2,
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      faq.answer,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
                crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250),
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ==========================================
// WIDGET: ERROR CODE CARD
// ==========================================
class _ErrorCodeCard extends StatelessWidget {
  final ErrorCodeModel errorCode;
  final bool isDark;

  const _ErrorCodeCard({required this.errorCode, required this.isDark});

  @override
  Widget build(BuildContext context) {
    Color severityColor;
    switch (errorCode.severity.toLowerCase()) {
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

    return GestureDetector(
      onTap: () {
        Get.toNamed(
          AppRoutes.errorDetails,
          arguments: errorCode,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.02) : AppColors.cardLight,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: severityColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: severityColor.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
          ],
        ),
        child: Row(
          children: [
            // Glowing Left Code Container
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: severityColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: severityColor.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning_amber_rounded, size: 16, color: severityColor),
                  const SizedBox(height: 2),
                  Text(
                    errorCode.code,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: severityColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Title & Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          errorCode.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Severity badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: severityColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: severityColor.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          errorCode.severity.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: severityColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    errorCode.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: isDark ? AppColors.textMutedDark.withValues(alpha: 0.5) : AppColors.textMutedLight.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// WIDGET: DIAGNOSE GRID CARD
// ==========================================
class _DiagnoseCard extends StatelessWidget {
  final DiagnoseOptionModel option;
  final bool isDark;

  const _DiagnoseCard({required this.option, required this.isDark});

  Color _parseColor(String hex) {
    try {
      final value = hex.replaceAll('#', '');
      return Color(int.parse('FF$value', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  IconData _getIconData(String name) {
    switch (name.toLowerCase()) {
      case 'bolt':
      case 'lightning':
        return Icons.flash_on_rounded;
      case 'wifi':
      case 'connectivity':
        return Icons.wifi_rounded;
      case 'thermostat':
      case 'temperature':
        return Icons.thermostat_rounded;
      case 'battery':
      case 'power':
        return Icons.battery_charging_full_rounded;
      case 'sync':
        return Icons.sync_rounded;
      case 'warning':
      case 'alert':
      default:
        return Icons.warning_amber_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(option.colorHex);
    return GestureDetector(
      onTap: () {
        _showDiagnosticsBottomSheet(context);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? color.withValues(alpha: 0.05) : AppColors.cardLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: color.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIconData(option.iconName),
                color: color,
                size: 20,
              ),
            ),
            const Spacer(),
            Text(
              option.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showDiagnosticsBottomSheet(BuildContext context) {
    final color = _parseColor(option.colorHex);
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cinematicSurface : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
              width: 1.5,
            ),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(_getIconData(option.iconName), color: color, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          option.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'TROUBLESHOOTING STEPS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                ),
              ),
              const SizedBox(height: 16),
              Column(
                children: List.generate(option.steps.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            option.steps[index],
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        Get.snackbar(
                          'Test Run',
                          'Simulating diagnostic check...',
                          backgroundColor: color.withValues(alpha: 0.1),
                          colorText: isDark ? Colors.white : color,
                        );
                      },
                      icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                      label: const Text('Run Live Diagnostics', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
                      ),
                    ),
                    child: IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

// ==========================================
// WIDGET: WIDE FAQ TILE
// ==========================================
class _FaqWideTile extends StatelessWidget {
  final FaqModel faq;
  final bool isDark;
  final bool isSelected;
  final VoidCallback onTap;

  const _FaqWideTile({
    required this.faq,
    required this.isDark,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.primary.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.08))
              : (isDark ? Colors.white.withValues(alpha: 0.02) : AppColors.cardLight),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColors.primary.withValues(alpha: 0.2) 
                    : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.help_outline_rounded,
                size: 16,
                color: isSelected ? AppColors.primary : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                faq.question,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected 
                      ? (isDark ? Colors.white : AppColors.primary) 
                      : (isDark ? Colors.white70 : Colors.black87),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: isSelected ? AppColors.primary : (isDark ? Colors.white30 : Colors.black26),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// WIDGET: WIDE ERROR CODE TILE
// ==========================================
class _ErrorCodeWideTile extends StatelessWidget {
  final ErrorCodeModel errorCode;
  final bool isDark;
  final bool isSelected;
  final VoidCallback onTap;

  const _ErrorCodeWideTile({
    required this.errorCode,
    required this.isDark,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color severityColor;
    switch (errorCode.severity.toLowerCase()) {
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

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? severityColor.withValues(alpha: 0.1)
              : (isDark ? Colors.white.withValues(alpha: 0.02) : AppColors.cardLight),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? severityColor : severityColor.withValues(alpha: 0.25),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: severityColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: severityColor.withValues(alpha: 0.2), width: 1),
              ),
              child: Center(
                child: Text(
                  errorCode.code,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: severityColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    errorCode.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    errorCode.description,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: severityColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                errorCode.severity.toUpperCase(),
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: severityColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// WIDGET: WIDE DIAGNOSE CARD
// ==========================================
class _DiagnoseWideCard extends StatelessWidget {
  final DiagnoseOptionModel option;
  final bool isDark;
  final bool isSelected;
  final VoidCallback onTap;

  const _DiagnoseWideCard({
    required this.option,
    required this.isDark,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(option.colorHex);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.12)
              : (isDark ? color.withValues(alpha: 0.04) : AppColors.cardLight),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.25),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getIconData(option.iconName),
                    color: color,
                    size: 18,
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: color,
                    size: 18,
                  ),
              ],
            ),
            const Spacer(),
            Text(
              option.title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// UTILITY FUNCTIONS DEFINITIONS
// ==========================================
Color _parseColor(String hex) {
  try {
    final value = hex.replaceAll('#', '');
    return Color(int.parse('FF$value', radix: 16));
  } catch (_) {
    return AppColors.primary;
  }
}

IconData _getIconData(String name) {
  switch (name.toLowerCase()) {
    case 'bolt':
    case 'lightning':
      return Icons.flash_on_rounded;
    case 'wifi':
    case 'connectivity':
      return Icons.wifi_rounded;
    case 'thermostat':
    case 'temperature':
      return Icons.thermostat_rounded;
    case 'battery':
    case 'power':
      return Icons.battery_charging_full_rounded;
    case 'sync':
      return Icons.sync_rounded;
    case 'warning':
    case 'alert':
    default:
      return Icons.warning_amber_rounded;
  }
}

