import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import '../../controllers/register_controller.dart';
import 'package:pinput/pinput.dart';

class StepOtpVerify extends GetView<RegisterController> {
  final bool isDark;
  const StepOtpVerify({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    // Start timer when this step is built if not already running
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.startTimer();
    });

    final defaultPinTheme = PinTheme(
      width: 50,
      height: 60,
      textStyle: TextStyle(
        fontSize: 22,
        color: isDark ? AppColors.foregroundDark : AppColors.foregroundLight,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.cinematicSurface.withValues(alpha: 0.8) 
            : AppColors.inputBackgroundLight,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.05) 
              : AppColors.borderLight,
          width: 1,
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 2),
      color: isDark ? AppColors.cinematicSurface : AppColors.inputBackgroundLight,
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: isDark ? AppColors.cinematicSurface : AppColors.inputBackgroundLight,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Text(
          'Verify OTP',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: isDark ? AppColors.foregroundDark : AppColors.foregroundLight,
            letterSpacing: 1,
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.3, end: 0),
        
        const SizedBox(height: 12),
        
        Obx(() => RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              height: 1.5,
            ),
            children: [
              const TextSpan(text: 'Enter the 6-digit code sent to your phone\n'),
              TextSpan(
                text: '${controller.selectedCountryCode.value} ${controller.phoneController.text}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        )).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.3, end: 0),
        
        const SizedBox(height: 40),
        
        Pinput(
          length: 6,
          controller: controller.otpController,
          defaultPinTheme: defaultPinTheme,
          focusedPinTheme: focusedPinTheme,
          submittedPinTheme: submittedPinTheme,
          separatorBuilder: (index) => const SizedBox(width: 8),
          hapticFeedbackType: HapticFeedbackType.lightImpact,
          onCompleted: (pin) => debugPrint(pin),
          cursor: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 9),
                width: 22,
                height: 1,
                color: AppColors.primary,
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.9, 0.9)),
        
        const SizedBox(height: 32),
        
        Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              controller.canResend.value ? "Didn't receive code? " : "Resend code in ",
              style: TextStyle(
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                fontSize: 14,
              ),
            ),
            if (controller.canResend.value)
              GestureDetector(
                onTap: () => controller.startTimer(),
                child: const Text(
                  "Resend",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              )
            else
              Text(
                controller.formattedTimer,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        )).animate().fadeIn(delay: 400.ms),
      ],
    );
  }
}
