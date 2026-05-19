import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:extrememedicaluserapp/core/utils/responsive_layout.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import 'package:extrememedicaluserapp/features/help/controllers/help_controller.dart';
import 'package:extrememedicaluserapp/features/help/widgets/help_category_card.dart';
import 'package:extrememedicaluserapp/features/help/widgets/help_header.dart';
import 'package:extrememedicaluserapp/features/help/widgets/help_search_bar.dart';
import 'package:extrememedicaluserapp/features/help/widgets/help_categories_grid.dart';
import 'package:extrememedicaluserapp/features/help/widgets/popular_articles_widget.dart';

class HelpView extends GetView<HelpController> {
  const HelpView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: _buildContent(context, isMobile: true),
          tablet: _buildTabletLayout(context),
          desktop: _buildDesktopLayout(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, {required bool isMobile}) {
    final horizontalPadding = isMobile ? 16.0 : 32.0;

    return Obx(() {
      if (controller.isLoading.value && controller.helpTopics.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.isNotEmpty && controller.helpTopics.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.destructive),
              const SizedBox(height: 16),
              Text(controller.errorMessage.value),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.fetchHelpTopics(),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          // 1. الجزء الثابت (Header + Search Bar)
          Container(
            padding: EdgeInsets.fromLTRB(horizontalPadding, 16.0, horizontalPadding, 16.0),
            decoration: BoxDecoration(
              color: context.isDarkMode 
                  ? AppColors.backgroundDark 
                  : AppColors.backgroundLight,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context),
                const SizedBox(height: 16),
                const HelpSearchBar(),
              ],
            ),
          ),

          // 2. الجزء القابل للتمرير (يبدأ من تحت البحث مباشرة)
          Expanded(
            child: SmartRefresher(
              controller: controller.refreshController,
              onRefresh: controller.onRefresh,
              header: const WaterDropMaterialHeader(
                backgroundColor: AppColors.primary,
                color: Colors.white,
                // الإزاحة هنا 0 لأننا داخل Expanded يبدأ من تحت الهيدر
                offset: 0, 
              ),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const HelpCategoriesGrid(),
                        const SizedBox(height: 32),
                        const PopularArticlesWidget(),
                      ]),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: _buildContent(context, isMobile: false),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: _buildHeader(context),
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              flex: 3,
              child: _buildContent(context, isMobile: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return const HelpHeader();
  }
}
