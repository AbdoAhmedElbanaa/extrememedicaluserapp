import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import '../controllers/register_controller.dart';
import 'register_steps/step_clinic_info.dart';
import 'register_steps/step_phone_auth.dart';
import 'register_steps/step_otp_verify.dart';
import 'register_steps/step_device_setup.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<RegisterController>()) {
      Get.put(RegisterController());
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.5),
            radius: 1.2,
            colors: isDark
                ? [AppColors.indigoDeep.withValues(alpha: 0.8), AppColors.backgroundDark]
                : [AppColors.splashGradientLight[1], AppColors.backgroundLight],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header & Stepper
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    _buildHeader(isDark),
                    const SizedBox(height: 30),
                    _buildStepper(isDark),
                  ],
                ),
              ),

              // Animated Content
              Expanded(
                child: Obx(() {
                  final step = controller.currentStep.value;
                  final isForward = controller.isForward.value;

                  return AnimatedSwitcher(
                    duration: 600.ms,
                    reverseDuration: 600.ms,
                    switchInCurve: Curves.easeInOutQuart,
                    switchOutCurve: Curves.easeInOutQuart,
                    layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
                      return Stack(
                        alignment: Alignment.topCenter,
                        children: <Widget>[
                          ...previousChildren,
                          if (currentChild != null) currentChild,
                        ],
                      );
                    },
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      final isCurrent = child.key == ValueKey<int>(step);

                      // Slide logic
                      Offset beginOffset;
                      if (isCurrent) {
                        beginOffset = isForward ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0);
                      } else {
                        beginOffset = isForward ? const Offset(-1.0, 0.0) : const Offset(1.0, 0.0);
                      }

                      Animation<Offset> slideAnimation = Tween<Offset>(
                        begin: beginOffset,
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeInOutQuart,
                      ));

                      // Scale & Fade
                      Animation<double> scaleAnimation = Tween<double>(
                        begin: 0.92,
                        end: 1.0,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeInOutQuart,
                      ));

                      return SlideTransition(
                        position: slideAnimation,
                        child: FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: scaleAnimation,
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: SingleChildScrollView(
                      key: ValueKey<int>(step),
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
                      child: Column(
                        children: [
                          _buildStepTitleAndSubtitle(step, isDark),
                          const SizedBox(height: 40),
                          _buildStepContent(step, isDark),
                          const SizedBox(height: 100), // Space for button
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      // Floating Bottom Button to keep it fixed and smooth
      bottomSheet: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.all(24.0),
        child: _buildActionButton(),
      ),
    );
  }

  Widget _buildStepTitleAndSubtitle(int step, bool isDark) {
    return Center(
      child: Column(
        children: [
          Text(
            _getStepTitle(step),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.foregroundDark : AppColors.foregroundLight,
              letterSpacing: 1,
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.3, end: 0),
          const SizedBox(height: 8),
          Text(
            _getStepSubtitle(step),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            ),
          ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                controller.previousStep();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Step ${controller.currentStep.value} of ${controller.totalSteps}',
              style: TextStyle(
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: const Text(
            'REGISTRATION',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    ));
  }

  Widget _buildStepper(bool isDark) {
    return Obx(() => SizedBox(
      height: 50,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Track
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 2,
              width: double.infinity,
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          
          // Progress Track
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: (controller.totalSteps > 1) 
                    ? (controller.currentStep.value - 1) / (controller.totalSteps - 1)
                    : 1.0,
                child: AnimatedContainer(
                  duration: 500.ms,
                  height: 2,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Steps Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(controller.totalSteps, (index) {
              int stepNum = index + 1;
              bool isActive = controller.currentStep.value == stepNum;
              bool isCompleted = controller.currentStep.value > stepNum;
              
              return _buildStepIndicator(stepNum, isActive, isCompleted, isDark);
            }),
          ),
        ],
      ),
    ));
  }

  Widget _buildStepIndicator(int step, bool isActive, bool isCompleted, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: 400.ms,
          curve: Curves.easeInOut,
          width: isActive ? 42 : 32,
          height: isActive ? 42 : 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive 
                ? Colors.transparent 
                : (isCompleted ? AppColors.primary : (isDark ? const Color(0xFF1E1D3A) : Colors.white)),
            gradient: isActive ? const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ) : null,
            border: Border.all(
              color: isActive ? Colors.transparent : (isCompleted ? AppColors.primary : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1))),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isActive ? AppColors.primary.withValues(alpha: 0.4) : Colors.transparent,
                blurRadius: isActive ? 12 : 0,
                spreadRadius: isActive ? 2 : 0,
              )
            ],
          ),
          child: Center(
            child: isCompleted 
                ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
                : Text(
                    '$step',
                    style: TextStyle(
                      color: isActive ? Colors.white : (isDark ? Colors.white38 : Colors.black38),
                      fontWeight: FontWeight.w900,
                      fontSize: isActive ? 16 : 14,
                    ),
                  ),
          ),
        ),
      ],
    ).animate(target: isActive ? 1 : 0).scale(
      begin: const Offset(1, 1),
      end: const Offset(1.1, 1.1),
      duration: 300.ms,
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 1: return 'Clinic Identity';
      case 2: return 'Secure Access';
      case 3: return 'Verification';
      case 4: return 'Smart Link';
      default: return '';
    }
  }

  String _getStepSubtitle(int step) {
    switch (step) {
      case 1: return 'Establish your medical profile';
      case 2: return 'Connect your phone for security';
      case 3: return 'Confirm your identity via OTP';
      case 4: return 'Pair your professional devices';
      default: return '';
    }
  }

  Widget _buildStepContent(int step, bool isDark) {
    switch (step) {
      case 1:
        return StepClinicInfo(isDark: isDark);
      case 2:
        return StepPhoneAuth(isDark: isDark);
      case 3:
        return StepOtpVerify(isDark: isDark);
      case 4:
        return StepDeviceSetup(isDark: isDark);
      default:
        return const SizedBox();
    }
  }

  Widget _buildActionButton() {
    return Obx(() => Container(
      width: double.infinity,
      height: 65,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          controller.nextStep();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              controller.currentStep.value == 2
                  ? 'Get OTP Code'
                  : (controller.currentStep.value == controller.totalSteps ? 'Finalize Setup' : 'Continue Next'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.arrow_forward_rounded, size: 20, color: Colors.white),
          ],
        ),
      ),
    ));
  }
}
