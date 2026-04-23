import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import '../../controllers/register_controller.dart';

class StepPhoneAuth extends GetView<RegisterController> {
  final bool isDark;
  const StepPhoneAuth({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputLabel('Phone Number'),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Country Code Selector
            Container(
              height: 65,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.cinematicSurface.withValues(alpha: 0.5)
                    : AppColors.inputBackgroundLight,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? AppColors.borderDark.withValues(alpha: 0.1) : AppColors.borderLight,
                ),
              ),
              child: Row(
                children: [
                  Obx(() => Text(
                    controller.selectedCountryName.value,
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black54,
                      fontSize: 12,
                    ),
                  )),
                  const SizedBox(width: 4),
                  Obx(() => Text(
                    controller.selectedCountryCode.value,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: isDark ? Colors.white38 : Colors.black38,
                    size: 18,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Phone Number Input
            Expanded(
              child: _buildTextField(
                controller: controller.phoneController,
                hint: '10 1234 5678',
                icon: Icons.phone_android_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Info Box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.primary.withValues(alpha: 0.7),
                size: 20,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'A 6-digit verification code will be sent to your phone number via SMS',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          color: isDark ? AppColors.foregroundDark.withValues(alpha: 0.8) : AppColors.foregroundLight,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(color: isDark ? AppColors.foregroundDark : Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark 
              ? AppColors.textMutedDark.withValues(alpha: 0.3) 
              : AppColors.textMutedLight.withValues(alpha: 0.3),
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight, size: 20),
        filled: true,
        fillColor: isDark ? AppColors.cinematicSurface.withValues(alpha: 0.5) : AppColors.inputBackgroundLight,
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark.withValues(alpha: 0.1) : AppColors.borderLight,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark.withValues(alpha: 0.1) : AppColors.borderLight,
          ),
        ),
      ),
    );
  }
}
