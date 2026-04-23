import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import '../../controllers/register_controller.dart';

class StepDeviceSetup extends GetView<RegisterController> {
  final bool isDark;
  const StepDeviceSetup({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputLabel('Serial Number (SN)'),
        _buildTextField(
          controller: controller.serialNumberController,
          hint: 'e.g. SN-2024-001234',
          icon: Icons.qr_code_scanner_rounded,
        ),
        
        const SizedBox(height: 20),
        
        _buildInputLabel('Device Model'),
        _buildTextField(
          controller: controller.deviceModelController,
          hint: 'e.g. SmartThermo Pro X',
          icon: Icons.devices_rounded,
        ),

        const SizedBox(height: 20),

        _buildInputLabel('Device Name'),
        _buildTextField(
          controller: controller.deviceNameController,
          hint: 'e.g. Reception Thermostat',
          icon: Icons.edit_note_rounded,
        ),

        const SizedBox(height: 20),

        _buildInputLabel('Additional Info'),
        _buildTextField(
          controller: controller.additionalInfoController,
          hint: '# Notes, location, etc.',
          icon: Icons.description_outlined,
          maxLines: 3,
        ),
      ],
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
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
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: isDark ? AppColors.foregroundDark : AppColors.foregroundLight),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark 
              ? AppColors.textMutedDark.withValues(alpha: 0.5) 
              : AppColors.textMutedLight.withValues(alpha: 0.5),
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: AppColors.primary.withValues(alpha: 0.6), size: 20),
        filled: true,
        fillColor: isDark ? AppColors.cinematicSurface.withValues(alpha: 0.4) : AppColors.inputBackgroundLight,
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isDark ? AppColors.primary.withValues(alpha: 0.15) : AppColors.borderLight.withValues(alpha: 0.5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isDark ? AppColors.primary.withValues(alpha: 0.15) : AppColors.borderLight.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
