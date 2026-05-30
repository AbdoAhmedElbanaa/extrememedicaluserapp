import 'dart:ui' show ImageFilter;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import 'package:extrememedicaluserapp/core/utils/responsive_layout.dart';
import '../controllers/video_tutorials_controller.dart';
import '../models/video_tutorial_model.dart';
import 'video_player_view.dart';

class VideoTutorialsView extends GetView<VideoTutorialsController> {
  const VideoTutorialsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
      body: Stack(
        children: [
          // Background Base Color
          Positioned.fill(
            child: Container(
              color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
            ),
          ),
          // Glow effect top-right (premium look)
          if (isDark)
            Positioned(
              top: -120,
              right: -120,
              width: 380,
              height: 380,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.12),
                ),
              ),
            ),
          // Glow effect bottom-left
          if (isDark)
            Positioned(
              bottom: -100,
              left: -100,
              width: 300,
              height: 300,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withValues(alpha: 0.08),
                ),
              ),
            ),
          // Backdrop Blur overlay
          if (isDark)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),
          // Main content
          SafeArea(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    _buildHeader(isDark),
                    const SizedBox(height: 16),

                    // Search input
                    _buildSearchBar(isDark),
                    const SizedBox(height: 20),

                    // Horizontal Categories Scroll Tab
                    _buildCategoryTabs(isDark),
                    const SizedBox(height: 24),

                    // Main Scrollable Area
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Featured Section (Moving Carousel Slider)
                            _buildFeaturedSection(isDark),
                            const SizedBox(height: 32),

                            // All Videos Heading Row
                            _buildAllVideosHeading(isDark),
                            const SizedBox(height: 16),

                            // Grid of Videos
                            _buildVideosGrid(context, isDark),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // Back Button
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cinematicSurface : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.chevron_left_rounded,
                  color: isDark ? Colors.white : Colors.black87,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Title & Subtitle
            Obx(() {
              final count = controller.filteredVideos.length;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Video Tutorials',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$count videos available',
                    style: TextStyle(
                      color: isDark ? Colors.white30 : Colors.black38,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
        // HD Pill Button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cinematicSurface : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
              width: 1.2,
            ),
          ),
          child: Text(
            'HD',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cinematicSurface.withValues(alpha: 0.5) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.distinctBorderDark.withValues(alpha: 0.3) : AppColors.distinctBorderLight,
          width: 1,
        ),
      ),
      child: TextField(
        onChanged: (val) => controller.searchQuery.value = val,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search tutorials...',
          hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black38, fontSize: 14),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isDark ? Colors.white30 : Colors.black38,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(bool isDark) {
    return Obx(() {
      final selectedId = controller.selectedCategoryId.value;
      
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            // "All" tab
            _buildTabItem(label: 'All', id: 'All', isSelected: selectedId == 'All', isDark: isDark),
            const SizedBox(width: 8),
            // Dynamic categories from Firebase
            ...controller.categories.map((cat) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: _buildTabItem(
                  label: cat.name,
                  id: cat.id,
                  isSelected: selectedId == cat.id,
                  isDark: isDark,
                ),
              );
            }),
          ],
        ),
      );
    });
  }

  Widget _buildTabItem({
    required String label,
    required String id,
    required bool isSelected,
    required bool isDark,
  }) {
    final activeColor = AppColors.primary;
    
    return GestureDetector(
      onTap: () => controller.selectedCategoryId.value = id,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.15)
              : (isDark ? AppColors.cinematicSurface.withValues(alpha: 0.4) : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? activeColor
                : (isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? activeColor
                : (isDark ? Colors.white54 : Colors.black54),
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Featured',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Carousel Slider
        Obx(() {
          final list = controller.featuredVideos;
          if (list.isEmpty) {
            return Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? AppColors.cinematicSurface.withValues(alpha: 0.4) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
                ),
              ),
              child: const Center(
                child: Text(
                  'No featured videos available',
                  style: TextStyle(color: Colors.white30, fontSize: 13),
                ),
              ),
            );
          }

          return CarouselSlider.builder(
            itemCount: list.length,
            options: CarouselOptions(
              height: 220,
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              autoPlay: list.length > 1,
              autoPlayInterval: const Duration(seconds: 4),
              enableInfiniteScroll: list.length > 1,
            ),
            itemBuilder: (context, index, realIndex) {
              final video = list[index];
              return _buildFeaturedCard(context, video, isDark);
            },
          );
        }),
      ],
    );
  }

  Widget _buildFeaturedCard(BuildContext context, VideoTutorialModel video, bool isDark) {
    // Get category name
    final categoryName = controller.categories
        .firstWhereOrNull((c) => c.id == video.categoryId)?.name ?? 'SETUP';

    return GestureDetector(
      onTap: () => _playVideo(context, video),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
            width: 1,
          ),
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF161531), const Color(0xFF0F0E24)]
                : [Colors.white, Colors.grey.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Center Play button overlay
              Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 12,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),

              // Rocket Mock icon to mimic the screenshot
              Positioned(
                top: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: Image.asset(
                    'assets/images/rocket_illustration.png', // Fallback or transparent container if asset does not exist
                    height: 50,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.rocket_launch_rounded, color: AppColors.primary, size: 28),
                      );
                    },
                  ),
                ),
              ),

              // Category tag (Top-Left)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    categoryName.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ),

              // Duration Tag (Bottom-Right)
              Positioned(
                bottom: 86,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time_rounded, color: Colors.white70, size: 10),
                      const SizedBox(width: 4),
                      Text(
                        video.duration,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom details banner
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.4)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              video.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Bookmark Button
                          Obx(() {
                            final isSaved = controller.isBookmarked(video.id);
                            return GestureDetector(
                              onTap: () => controller.toggleBookmark(video.id),
                              child: Icon(
                                isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                                color: isSaved ? AppColors.primary : Colors.white70,
                                size: 20,
                              ),
                            );
                          })
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_formatViews(video.views)} views  •  ${video.deviceName}',
                        style: const TextStyle(
                          color: Colors.white30,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAllVideosHeading(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'All Videos',
              style: TextStyle(
                color: isDark ? Colors.white70 : AppColors.foregroundLight,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Obx(() {
          final count = controller.filteredVideos.length;
          return Text(
            '$count videos',
            style: TextStyle(
              color: isDark ? Colors.white30 : Colors.black38,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildVideosGrid(BuildContext context, bool isDark) {
    return Obx(() {
      final list = controller.filteredVideos;
      if (list.isEmpty) {
        return Container(
          height: 150,
          width: double.infinity,
          alignment: Alignment.center,
          child: Text(
            'No matching video guides found',
            style: TextStyle(color: isDark ? Colors.white30 : Colors.black38, fontSize: 13),
          ),
        );
      }

      // 2 columns, responsive to tablet and desktop
      final crossAxisCount = context.responsive<int>(2, tablet: 3, desktop: 4);
      // We adjust childAspectRatio based on size to ensure details fit nicely
      final double childAspectRatio = context.responsive<double>(0.86, tablet: 0.9, desktop: 0.95);

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: list.length,
        itemBuilder: (context, index) {
          return _buildVideoGridItem(context, list[index], isDark);
        },
      );
    });
  }

  Widget _buildVideoGridItem(BuildContext context, VideoTutorialModel video, bool isDark) {
    // Get category name
    final categoryName = controller.categories
        .firstWhereOrNull((c) => c.id == video.categoryId)?.name ?? 'SETUP';

    // Accent theme coloring mapped to category names (red, green, blue)
    Color themeColor;
    if (categoryName.toLowerCase().contains('error') || categoryName.toLowerCase().contains('fix')) {
      themeColor = AppColors.errorRed;
    } else if (categoryName.toLowerCase().contains('maintenance')) {
      themeColor = AppColors.success;
    } else {
      themeColor = AppColors.primary;
    }

    return GestureDetector(
      onTap: () => _playVideo(context, video),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: themeColor.withValues(alpha: 0.2),
            width: 1.5,
          ),
          gradient: LinearGradient(
            colors: isDark
                ? [themeColor.withValues(alpha: 0.08), const Color(0xFF0F0E24)]
                : [themeColor.withValues(alpha: 0.03), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top thumbnail portion
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Play icon overlay
                    Center(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 1),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),

                    // Category Tag inside
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: themeColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: themeColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          categoryName.toUpperCase(),
                          style: TextStyle(
                            color: themeColor,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),

                    // Duration Tag
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          video.duration,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // Centered category mock graphic
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Icon(
                          categoryName.toLowerCase().contains('maintenance')
                              ? Icons.build_outlined
                              : (categoryName.toLowerCase().contains('error')
                                  ? Icons.warning_amber_rounded
                                  : Icons.rocket_launch_outlined),
                          color: themeColor.withValues(alpha: 0.3),
                          size: 32,
                        ),
                      ),
                    )
                  ],
                ),
              ),

              // Bottom details portion
              Container(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            video.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Bookmark Toggle
                        Obx(() {
                          final isSaved = controller.isBookmarked(video.id);
                          return GestureDetector(
                            onTap: () => controller.toggleBookmark(video.id),
                            child: Icon(
                              isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                              color: isSaved ? themeColor : (isDark ? Colors.white30 : Colors.black26),
                              size: 16,
                            ),
                          );
                        })
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_formatViews(video.views)} views  •  ${video.deviceName}',
                      style: TextStyle(
                        color: isDark ? Colors.white30 : Colors.black38,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _playVideo(BuildContext context, VideoTutorialModel video) {
    // Open Video Player View
    Get.to(
      () => VideoPlayerView(
        videoUrl: video.resolvedUrl,
        title: video.title,
        description: video.description,
      ),
      transition: Transition.fadeIn,
    );
  }

  String _formatViews(int views) {
    if (views >= 1000) {
      double kViews = views / 1000;
      return '${kViews.toStringAsFixed(1)}K';
    }
    return views.toString();
  }
}
