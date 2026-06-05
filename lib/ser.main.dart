import 'package:extrememedicaluserapp/features/devices/presentation/views/device_details_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:device_preview/device_preview.dart';
import 'package:extrememedicaluserapp/core/services/firebase_service.dart';
import 'package:extrememedicaluserapp/features/auth/services/auth_service.dart';
import 'package:extrememedicaluserapp/features/auth/data/user_repository.dart';
import 'package:extrememedicaluserapp/theme/app_theme.dart';
import 'package:extrememedicaluserapp/features/splash/presentation/views/splash_view.dart';
import 'package:extrememedicaluserapp/features/splash/presentation/controllers/splash_controller.dart';
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
import 'package:extrememedicaluserapp/features/profile/presentation/controllers/profile_controller.dart';
import 'package:extrememedicaluserapp/features/settings/presentation/views/settings_view.dart';
import 'package:extrememedicaluserapp/features/settings/presentation/controllers/settings_controller.dart';
import 'package:extrememedicaluserapp/core/services/theme_service.dart';
import 'package:extrememedicaluserapp/core/routes/app_routes.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:toastification/toastification.dart';
import 'package:extrememedicaluserapp/features/help/views/knowledge_center_view.dart';
import 'package:extrememedicaluserapp/features/help/views/error_details_view.dart';
import 'package:extrememedicaluserapp/features/help/controllers/knowledge_center_controller.dart';
import 'package:extrememedicaluserapp/features/contact/views/contact_view.dart';
import 'package:extrememedicaluserapp/features/contact/views/ticket_submitted_view.dart';
import 'package:extrememedicaluserapp/features/contact/views/my_support_requests_view.dart';
import 'package:extrememedicaluserapp/features/contact/views/ticket_tracker_view.dart';
import 'package:extrememedicaluserapp/features/contact/controllers/contact_controller.dart';
import 'package:extrememedicaluserapp/features/video_tutorials/views/video_tutorials_view.dart';
import 'package:extrememedicaluserapp/features/video_tutorials/controllers/video_tutorials_controller.dart';
import 'package:extrememedicaluserapp/features/contact/views/chat_support_view.dart';
import 'package:extrememedicaluserapp/features/contact/controllers/chat_controller.dart';
import 'package:extrememedicaluserapp/features/contact/services/onesignal_service.dart';
import 'package:extrememedicaluserapp/features/notifications/services/notifications_service.dart';
import 'package:extrememedicaluserapp/features/notifications/controllers/notifications_controller.dart';
import 'package:extrememedicaluserapp/features/notifications/views/notifications_view.dart';

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
  Get.put(UserRepository(), permanent: true);
  Get.put(AuthService(), permanent: true);
  await Get.putAsync(() => NotificationsService().init());
  await OneSignalService.initializeDynamic();
  
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const MyApp(),
    ),
  );
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
          title: 'Extreme Medical - Preview',
          useInheritedMediaQuery: true, // Required for DevicePreview
          locale: DevicePreview.locale(context), // Required for DevicePreview
          builder: (context, child) {
            child = DevicePreview.appBuilder(context, child);
            return child;
          },
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeService().theme,
          initialRoute: AppRoutes.splash,
          getPages: [
            GetPage(
              name: AppRoutes.splash, 
              page: () => const SplashView(),
              binding: BindingsBuilder(() {
                Get.put(SplashController());
              }),
              transition: Transition.fadeIn,
            ),
            GetPage(
              name: AppRoutes.onboarding, 
              page: () => const OnboardingView(),
              transition: Transition.cupertino,
            ),
            GetPage(
              name: AppRoutes.permissions, 
              page: () => const AllowPermissionsView(),
              transition: Transition.rightToLeftWithFade,
            ),
            GetPage(
              name: AppRoutes.login, 
              page: () => const LoginView(),
              transition: Transition.downToUp,
            ),
            GetPage(
              name: AppRoutes.register, 
              page: () => const RegisterView(),
              transition: Transition.rightToLeftWithFade,
            ),
            GetPage(
              name: AppRoutes.home, 
              page: () => const HomeView(),
              binding: BindingsBuilder(() {
                Get.put(HomeController());
                Get.put(DevicesController());
                Get.put(HelpController());
                Get.put(ProfileController());
              }),
              transition: Transition.zoom,
            ),
            GetPage(
              name: AppRoutes.devices, 
              page: () => const DevicesView(),
              binding: BindingsBuilder(() {
                Get.put(DevicesController());
              }),
              transition: Transition.rightToLeftWithFade,
            ),
            GetPage(
              name: AppRoutes.deviceDetails, 
              page: () => const DeviceDetailsView(),
              transition: Transition.cupertino,
            ),
            GetPage(
              name: AppRoutes.help, 
              page: () => const HelpView(),
              binding: BindingsBuilder(() {
                Get.put(HelpController());
              }),
              transition: Transition.rightToLeftWithFade,
            ),
            GetPage(
              name: AppRoutes.settings, 
              page: () => const SettingsView(),
              binding: BindingsBuilder(() {
                Get.put(SettingsController());
              }),
              transition: Transition.rightToLeftWithFade,
            ),
            GetPage(
              name: AppRoutes.knowledgeCenter,
              page: () => const KnowledgeCenterView(),
              binding: BindingsBuilder(() {
                Get.put(KnowledgeCenterController());
              }),
              transition: Transition.rightToLeftWithFade,
            ),
            GetPage(
              name: AppRoutes.errorDetails,
              page: () => const ErrorDetailsView(),
              transition: Transition.cupertino,
            ),
            GetPage(
              name: AppRoutes.contactSupport,
              page: () => const ContactView(),
              binding: BindingsBuilder(() {
                Get.put(ContactController());
              }),
              transition: Transition.rightToLeftWithFade,
            ),
            GetPage(
              name: AppRoutes.ticketSubmitted,
              page: () => const TicketSubmittedView(),
              transition: Transition.fadeIn,
            ),
            GetPage(
              name: AppRoutes.mySupportRequests,
              page: () => const MySupportRequestsView(),
              binding: BindingsBuilder(() {
                Get.put(ContactController());
              }),
              transition: Transition.rightToLeftWithFade,
            ),
            GetPage(
              name: AppRoutes.ticketTracker,
              page: () => const TicketTrackerView(),
              binding: BindingsBuilder(() {
                Get.put(ContactController());
              }),
              transition: Transition.rightToLeftWithFade,
            ),
            GetPage(
              name: AppRoutes.videoTutorials,
              page: () => const VideoTutorialsView(),
              binding: BindingsBuilder(() {
                Get.put(VideoTutorialsController());
              }),
              transition: Transition.rightToLeftWithFade,
            ),
            GetPage(
              name: AppRoutes.chatSupport,
              page: () => const ChatSupportView(),
              binding: BindingsBuilder(() {
                Get.put(ChatController());
              }),
              transition: Transition.rightToLeftWithFade,
            ),
            GetPage(
              name: AppRoutes.notifications,
              page: () => const NotificationsView(),
              binding: BindingsBuilder(() {
                Get.put(NotificationsController());
              }),
              transition: Transition.rightToLeftWithFade,
            ),
          ],
        ),
      ),
    );
  }
}
