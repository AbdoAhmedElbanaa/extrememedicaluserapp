import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import '../../controllers/register_controller.dart';

class StepClinicInfo extends GetView<RegisterController> {
  final bool isDark;
  const StepClinicInfo({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputLabel('Clinic Name'),
        _buildTextField(
          controller: controller.clinicNameController,
          hint: 'e.g. Bright Smile Clinic',
          icon: Icons.business_rounded,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputLabel('First Name'),
                  _buildTextField(
                    controller: controller.firstNameController,
                    hint: 'Ahmed',
                    icon: Icons.person_outline_rounded,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputLabel('Last Name'),
                  _buildTextField(
                    controller: controller.lastNameController,
                    hint: 'Hassan',
                    icon: Icons.person_outline_rounded,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildInputLabel('Clinic Address'),
        _buildTextField(
          controller: controller.clinicAddressController,
          hint: '123 Medical Street, Cairo',
          icon: Icons.location_on_outlined,
        ),
        const SizedBox(height: 12),
        
        // Google Map Section
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                Obx(() => GoogleMap(
                  onMapCreated: controller.onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: controller.selectedLocation.value,
                    zoom: 13,
                  ),
                  markers: controller.markers,
                  onCameraMove: controller.onCameraMove,
                  onCameraIdle: controller.onCameraIdle,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapType: MapType.normal,
                )),
                
                // My Location Button
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton.small(
                    onPressed: controller.getCurrentLocation,
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.my_location, color: Colors.white),
                  ),
                ),
                
                // Loading Overlay
                Obx(() => controller.isMapLoading.value 
                  ? Container(
                      color: Colors.black26,
                      child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                    )
                  : const SizedBox.shrink()),
              ],
            ),
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
