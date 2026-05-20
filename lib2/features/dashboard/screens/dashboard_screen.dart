import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/widgets/admin_layout.dart';
import '../controllers/dashboard_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(DashboardController());
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return AdminLayout(
      title: 'Dashboard',
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Dashboard is now empty and ready for new content
            Icon(
              Icons.dashboard_outlined,
              size: 100,
              color: isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(5),
            ),
            const SizedBox(height: 16),
            Text(
              'Dashboard Content Coming Soon',
              style: TextStyle(
                color: isDark ? Colors.white.withAlpha(30) : Colors.black.withAlpha(20),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
