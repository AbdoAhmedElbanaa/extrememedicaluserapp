import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../controllers/devices_controller.dart';
import '../widgets/devices_header.dart';
import '../widgets/device_card.dart';
import 'package:extrememedicaluserapp/core/utils/responsive_layout.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import '../widgets/add_device_sheet.dart';

class DevicesView extends GetView<DevicesController> {
  const DevicesView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;
    
    // حساب ارتفاع الهيدر الفعلي بدقة لضمان أن الـ Refresh يبدأ من نهايته
    // الهيدر يحتوي على (Title + Search + Chips + Paddings)
    final double headerHeight = topPadding + 225; 
    
    // المسافة الجمالية (Gap) بين الهيدر والبطاقات لإعطاء مظهر سينمائي
    const double cinematicGap = 20.0;

    return Scaffold(
      backgroundColor: Colors.transparent, // للسماح للتوهج الخلفي بالظهور
      body: Stack(
        children: [
          // 1. طبقة المحتوى ومنطقة التحديث (تغطي الشاشة كاملة)
          SmartRefresher(
            controller: controller.refreshController,
            onRefresh: controller.onRefresh,
            header: WaterDropMaterialHeader(
              backgroundColor: const Color(0xFF6366F1),
              color: Colors.white,
              // ✅ السر هنا: الأيقونة ستبدأ بالظهور بالضبط من تحت حافة الهيدر
              offset: headerHeight,
            ),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // إضافة مساحة فارغة في أعلى القائمة تعادل (ارتفاع الهيدر + الفراغ الجمالي)
                SliverToBoxAdapter(
                  child: SizedBox(height: headerHeight + cinematicGap),
                ),
                
                // عرض شبكة الأجهزة
                Obx(() {
                  if (controller.filteredDevices.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(isDark),
                    );
                  }
                  
                  final crossAxisCount = context.responsive(1, tablet: 2, desktop: 3).toInt();
                  
                  return SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.responsive(20, tablet: 30, desktop: 40),
                    ),
                    sliver: crossAxisCount == 1 
                      ? SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => DeviceCard(
                              device: controller.filteredDevices[index],
                              onTap: () {
                                Get.toNamed(
                                  '/device-details',
                                  arguments: controller.filteredDevices[index],
                                );
                              },
                            ),
                            childCount: controller.filteredDevices.length,
                          ),
                        )
                      : SliverGrid(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: context.responsive(1.4, tablet: 1.2, desktop: 1.3),
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => DeviceCard(
                              device: controller.filteredDevices[index],
                              onTap: () {
                                Get.toNamed(
                                  '/device-details',
                                  arguments: controller.filteredDevices[index],
                                );
                              },
                            ),
                            childCount: controller.filteredDevices.length,
                          ),
                        ),
                  );
                }),
                
                // مساحة أمان سفلية لضمان عدم التداخل مع الـ Bottom Navigation
                const SliverToBoxAdapter(
                  child: SizedBox(height: 120),
                ),
              ],
            ),
          ),

          // 2. الهيدر الزجاجي الثابت (Floating Header)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: DevicesHeader(),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(isDark),
    );
  }

  // بناء الزر العائم بتصميم Squircle سينمائي مع ظل مخصص
  Widget _buildFAB(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 120, right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          Get.bottomSheet(
            const AddDeviceSheet(),
            isScrollControlled: true,
            barrierColor: Colors.black.withValues(alpha: 0.5),
          );
        },
        backgroundColor: AppColors.primary,
        elevation: 0, // نلغي الـ elevation الافتراضي لنعتمد على الـ boxShadow الخاص بنا
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  // واجهة "لا توجد أجهزة" بتصميم متناسق مع النمط السينمائي
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.devices_other_rounded,
            size: 64,
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
          ),
          const SizedBox(height: 20),
          Text(
            'No devices found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white24 : Colors.black26,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
