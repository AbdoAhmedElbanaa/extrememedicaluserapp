import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import 'package:extrememedicaluserapp/core/utils/responsive_layout.dart';
import '../controllers/contact_controller.dart';

class ContactHeader extends GetView<ContactController> {
  const ContactHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final config = controller.config.value;
      final isOnline = config?.status == 'online';
      final responseTimeText = config?.responseTimeText ?? 'We typically reply in 2–4 hours';

      return Container(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          children: [
            InkWell(
              onTap: () => Get.back(),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cinematicSurface : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
                  ),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: isDark ? Colors.white : Colors.black,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Support',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: context.responsive(22, tablet: 26, desktop: 30),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    responseTimeText,
                    style: TextStyle(
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.4),
                      fontSize: context.responsive(12, tablet: 13, desktop: 15),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: (isOnline ? Colors.green : Colors.grey).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (isOnline ? Colors.green : Colors.grey).withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isOnline ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      color: isOnline ? Colors.green : Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
