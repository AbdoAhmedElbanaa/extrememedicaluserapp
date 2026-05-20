import 'package:extrememedicaluserapp/features/permissions/presentation/view/allow_permissions_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:extrememedicaluserapp/features/onboarding/data/models/onboarding_model.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final storage = GetStorage();
  
  var currentPage = 0.obs;
  bool get isLastPage => currentPage.value == onboardingPages.length - 1;

  final List<OnboardingModel> onboardingPages = [
    OnboardingModel(
      title: 'Expert Medical Guidance',
      description: 'Access comprehensive manuals and expert advice for all your medical equipment and procedures.',
      icon: Icons.medical_services_rounded,
      gradientColors: [AppColors.primary, AppColors.secondary],
    ),
    OnboardingModel(
      title: 'Visual Training Center',
      description: 'Learn with high-quality visual content and interactive guides designed by medical professionals.',
      imagePath: 'https://images.unsplash.com/photo-1576091160550-2173dba999ef?q=80&w=2070&auto=format&fit=crop', // Professional medical image
      isImagePage: true,
      gradientColors: [AppColors.skyBlue, AppColors.tealAccent],
    ),
    OnboardingModel(
      title: 'Smart Diagnostics',
      description: 'Intelligent troubleshooting and step-by-step solutions at your fingertips, anytime, anywhere.',
      icon: Icons.psychology_rounded,
      gradientColors: [AppColors.secondary, AppColors.brightPink],
    ),
    OnboardingModel(
      title: 'Seamless Integration',
      description: 'Connect with healthcare professionals and keep your manual library updated automatically.',
      icon: Icons.sync_rounded,
      gradientColors: [AppColors.brightPink, AppColors.primary],
    ),
  ];

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (isLastPage) {
      completeOnboarding();
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void skip() {
    completeOnboarding();
  }

  void completeOnboarding() {
    storage.write('onboarding_seen', true);
    Get.off(() => const AllowPermissionsView());
  }
}
