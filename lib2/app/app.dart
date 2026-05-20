import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/core/services/theme_service.dart';
import 'routes.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/controllers/auth_controller.dart';
import '../shared/widgets/loading_widget.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject AuthController here
    final authController = Get.put(AuthController());

    return GetMaterialApp(
      title: 'Extreme Medical Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeService().theme,
      initialRoute: '/login', // Fallback
      getPages: AppRoutes.routes,
    );
  }
}
