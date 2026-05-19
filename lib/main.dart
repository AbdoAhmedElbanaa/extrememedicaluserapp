import 'package:extrememedicaluserapp/features/devices/presentation/views/device_details_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:extrememedicaluserapp/core/services/firebase_service.dart';
import 'package:extrememedicaluserapp/theme/app_theme.dart';
import 'package:extrememedicaluserapp/features/splash/presentation/views/splash_view.dart';
import 'package:extrememedicaluserapp/features/onboarding/presentation/views/onboarding_view.dart';
import 'package:extrememedicaluserapp/features/permissions/presentation/view/allow_permissions_view.dart';
import 'package:extrememedicaluserapp/features/auth/presentation/views/login_view.dart';
import 'package:extrememedicaluserapp/features/auth/presentation/views/register_view.dart';
import 'package:extrememedicaluserapp/features/home/presentation/views/home_view.dart';
import 'package:extrememedicaluserapp/features/home/presentation/controllers/home_controller.dart';
import 'package:extrememedicaluserapp/features/devices/presentation/views/devices_view.dart';
import 'package:extrememedicaluserapp/features/devices/presentation/controllers/devices_controller.dart';
import 'package:extrememedicaluserapp/features/help/views/help_view.dart';
import 'package:extrememedicaluserapp/features/help/controllers/help_controller.dart';
import 'package:extrememedicaluserapp/core/services/theme_service.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:toastification/toastification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  await GetStorage.init();
  await Get.putAsync(() => FirebaseService().init());
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshConfiguration(
      headerBuilder: () => const WaterDropHeader(),
      footerBuilder: () => const ClassicFooter(),
      headerTriggerDistance: 80.0,
      springDescription: const SpringDescription(stiffness: 170, damping: 16, mass: 1.9),
      maxOverScrollExtent: 100,
      maxUnderScrollExtent: 0,
      enableScrollWhenRefreshCompleted: true,
      enableLoadingWhenFailed: true,
      child: ToastificationWrapper(
        config: const ToastificationConfig(
          animationDuration: Duration(milliseconds: 300),
          alignment: Alignment.topCenter,
        ),
        child: GetMaterialApp(
          title: 'Extreme Medical',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeService().theme,
          initialRoute: '/',
          getPages: [
            GetPage(
              name: '/', 
              page: () => const SplashView(),
              transition: Transition.fadeIn,
            ),
            GetPage(
              name: '/onboarding', 
              page: () => const OnboardingView(),
              transition: Transition.cupertino,
            ),
            GetPage(
              name: '/permissions', 
              page: () => const AllowPermissionsView(),
              transition: Transition.rightToLeftWithFade,
            ),
            GetPage(
              name: '/login', 
              page: () => const LoginView(),
              transition: Transition.downToUp,
            ),
            GetPage(
              name: '/register', 
              page: () => const RegisterView(),
              transition: Transition.rightToLeftWithFade,
            ),
            GetPage(
              name: '/home', 
              page: () => const HomeView(),
              binding: BindingsBuilder(() {
                Get.put(HomeController());
                Get.put(DevicesController());
                Get.put(HelpController());
              }),
              transition: Transition.zoom,
            ),
            GetPage(
              name: '/devices', 
              page: () => const DevicesView(),
              binding: BindingsBuilder(() {
                Get.put(DevicesController());
              }),
              transition: Transition.rightToLeftWithFade,
            ),
            GetPage(
              name: '/device-details', 
              page: () => const DeviceDetailsView(),
              transition: Transition.cupertino,
            ),
            GetPage(
              name: '/help', 
              page: () => const HelpView(),
              binding: BindingsBuilder(() {
                Get.put(HelpController());
              }),
              transition: Transition.rightToLeftWithFade,
            ),
          ],
        ),
      ),
    );
  }
}
