import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:extrememedicaluserapp/core/utils/responsive_layout.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import 'package:extrememedicaluserapp/features/help/controllers/help_controller.dart';
import 'package:extrememedicaluserapp/features/help/widgets/help_header.dart';
import 'package:extrememedicaluserapp/features/help/widgets/help_search_bar.dart';
import 'package:extrememedicaluserapp/features/help/widgets/help_categories_grid.dart';
import 'package:extrememedicaluserapp/features/help/widgets/popular_articles_widget.dart';

class HelpView extends GetView<HelpController> {
  const HelpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: _buildMobileLayout(context),
          tablet: _buildTabletLayout(context),
          desktop: _buildDesktopLayout(context),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return _buildContent(context, isMobile: true);
  }

  Widget _buildTabletLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isCentered: false),
              const SizedBox(height: 24),
              const HelpSearchBar(),
              const SizedBox(height: 40),
              const HelpCategoriesGrid(),
              const SizedBox(height: 40),
              const PopularArticlesWidget(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          padding: const EdgeInsets.all(48.0),
          child: Column(
            children: [
              // Hero Section for Desktop
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(48),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.1),
                      AppColors.primary.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  children: [
                    _buildHeader(context, isCentered: true, isLarge: true),
                    const SizedBox(height: 32),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: const HelpSearchBar(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column: Categories
                  Expanded(
                    flex: 3,
                    child: const HelpCategoriesGrid(),
                  ),
                  const SizedBox(width: 48),
                  // Right Column: Popular Articles & Extra
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const PopularArticlesWidget(),
                        const SizedBox(height: 32),
                        _buildContactSupportCard(context),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, {required bool isMobile}) {
    final horizontalPadding = isMobile ? 16.0 : 32.0;
    final topPadding = MediaQuery.of(context).padding.top;

    return Obx(() {
      if (controller.isLoading.value && controller.helpTopics.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.isNotEmpty && controller.helpTopics.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.destructive),
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
          if (isMobile) _buildMobileHeader(context, horizontalPadding, topPadding),
          Expanded(
            child: SmartRefresher(
              controller: controller.refreshController,
              onRefresh: controller.onRefresh,
              header: const WaterDropMaterialHeader(
                backgroundColor: AppColors.primary,
                color: Colors.white,
              ),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding, vertical: 16.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const HelpCategoriesGrid(),
                        const SizedBox(height: 32),
                        const PopularArticlesWidget(),
                      ]),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildMobileHeader(
      BuildContext context, double horizontalPadding, double topPadding) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          horizontalPadding, topPadding + 10, horizontalPadding, 20),
      decoration: BoxDecoration(
        color: context.isDarkMode ? AppColors.backgroundDark : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: context.isDarkMode
                ? AppColors.distinctBorderDark
                : AppColors.distinctBorderLight,
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          const HelpSearchBar(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context,
      {bool isCentered = true, bool isLarge = false}) {
    return HelpHeader(
      isCentered: isCentered,
      isLarge: isLarge,
    );
  }

  Widget _buildContactSupportCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.headset_mic_rounded, color: Colors.white, size: 32),
          const SizedBox(height: 16),
          const Text(
            'Still need help?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Our support team is available 24/7 to assist you with any issues.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Contact Support'),
          ),
        ],
      ),
    );
  }
}
