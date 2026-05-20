import 'package:get/get.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/users/screens/users_screen.dart';
import '../features/settings/screens/settings_screen.dart';

class AppRoutes {
  static const String initial = '/login';

  static final routes = [
    GetPage(
      name: '/login',
      page: () => LoginScreen(),
    ),
    GetPage(
      name: '/dashboard',
      page: () => const DashboardScreen(),
    ),
    GetPage(
      name: '/users',
      page: () => const UsersScreen(),
    ),
    GetPage(
      name: '/settings',
      page: () => const SettingsScreen(),
    ),
  ];
}
