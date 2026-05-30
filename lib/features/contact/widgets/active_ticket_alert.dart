import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/core/routes/app_routes.dart';
import '../controllers/contact_controller.dart';

class ActiveTicketAlert extends GetView<ContactController> {
  const ActiveTicketAlert({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final active = controller.activeTicket.value;
      if (active == null) return const SizedBox.shrink();

      return GestureDetector(
        onTap: () => Get.toNamed(AppRoutes.ticketSubmitted, arguments: active),
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFF9F1C).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFFF9F1C).withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFFF9F1C),
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'You have an active support request',
                      style: TextStyle(
                        color: Color(0xFFFF9F1C),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${active.id} · Tap to view',
                      style: TextStyle(
                        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.4),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: const Color(0xFFFF9F1C).withValues(alpha: 0.6),
                  size: 14,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
