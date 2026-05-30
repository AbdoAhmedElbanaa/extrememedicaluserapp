import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import 'package:extrememedicaluserapp/features/auth/services/auth_service.dart';
import '../controllers/contact_controller.dart';
import '../widgets/contact_header.dart';
import '../widgets/active_ticket_alert.dart';

class ContactView extends GetView<ContactController> {
  const ContactView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                const ContactHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ActiveTicketAlert(),
                        const SizedBox(height: 10),
                        
                        // Subject Dropdown
                        _buildLabel('Subject'),
                        const SizedBox(height: 8),
                        _buildSubjectDropdown(isDark),
                        const SizedBox(height: 24),

                        // Priority Selector
                        _buildLabel('Priority'),
                        const SizedBox(height: 8),
                        _buildPrioritySelector(isDark),
                        const SizedBox(height: 24),

                        // Error Code (Optional)
                        _buildLabel('Error Code (Optional)'),
                        const SizedBox(height: 8),
                        _buildErrorCodeField(isDark),
                        const SizedBox(height: 24),

                        // Description
                        _buildLabel('Description'),
                        const SizedBox(height: 8),
                        _buildDescriptionField(isDark),
                        const SizedBox(height: 24),

                        // Attachments
                        _buildLabel('Attachments'),
                        const SizedBox(height: 8),
                        _buildAttachmentsSection(isDark, context),
                        const SizedBox(height: 24),

                        // Device Auto-Attached
                        _buildDeviceAttachedInfo(isDark),
                        const SizedBox(height: 32),

                        // Submit Button
                        _buildSubmitButton(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 13,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSubjectDropdown(bool isDark) {
    return Obx(() {
      if (controller.subjects.isEmpty) {
        return const SizedBox(
          height: 48,
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            ),
          ),
        );
      }

      final String currentVal = controller.selectedSubject.value.isNotEmpty &&
              controller.subjects.contains(controller.selectedSubject.value)
          ? controller.selectedSubject.value
          : controller.subjects.first;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cinematicSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
            width: 1.5,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: currentVal,
            dropdownColor: isDark ? AppColors.cinematicSurface : Colors.white,
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down_rounded, color: isDark ? Colors.white54 : Colors.black54),
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            items: controller.subjects.map((String sub) {
              return DropdownMenuItem<String>(
                value: sub,
                child: Text(sub),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) controller.changeSubject(val);
            },
          ),
        ),
      );
    });
  }

  Widget _buildPrioritySelector(bool isDark) {
    return Obx(() => Row(
      children: controller.priorities.map((prio) {
        final isSelected = controller.selectedPriority.value == prio;
        Color activeColor;
        switch (prio.toLowerCase()) {
          case 'low': activeColor = Colors.blue; break;
          case 'medium': activeColor = const Color(0xFFFF9F1C); break;
          case 'high': activeColor = Colors.orange; break;
          case 'critical': activeColor = Colors.red; break;
          default: activeColor = AppColors.primary;
        }

        return Expanded(
          child: GestureDetector(
            onTap: () => controller.changePriority(prio),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? activeColor.withValues(alpha: 0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? activeColor : (isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  prio,
                  style: TextStyle(
                    color: isSelected ? activeColor : (isDark ? Colors.white38 : Colors.black38),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    ));
  }

  Widget _buildErrorCodeField(bool isDark) {
    return TextField(
      controller: controller.errorCodeController,
      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 20),
        hintText: 'e.g. E102',
        hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
        filled: true,
        fillColor: isDark ? AppColors.cinematicSurface : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDescriptionField(bool isDark) {
    return TextField(
      controller: controller.descriptionController,
      maxLines: 5,
      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Describe the issue in detail — what happened, when it started, what you\'ve already tried...',
        hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
        filled: true,
        fillColor: isDark ? AppColors.cinematicSurface : Colors.white,
        contentPadding: const EdgeInsets.all(16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildAttachmentsSection(bool isDark, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          if (controller.isUploading.value) {
            return Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cinematicSurface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.cloud_upload_outlined, color: AppColors.primary),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Uploading attachment...',
                          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        '${controller.uploadProgress.value.toInt()}%',
                        style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: controller.uploadProgress.value / 100.0,
                    backgroundColor: isDark ? Colors.white10 : Colors.black12,
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),
        Row(
          children: [
            Expanded(child: _buildAttachmentButton(Icons.image_outlined, 'Photo', isDark)),
            const SizedBox(width: 8),
            Expanded(child: _buildAttachmentButton(Icons.videocam_outlined, 'Video', isDark)),
            const SizedBox(width: 8),
            Expanded(child: _buildAttachmentButton(Icons.attach_file_outlined, 'File', isDark)),
          ],
        ),
        Obx(() {
          if (controller.attachments.isEmpty) return const SizedBox.shrink();
          return Container(
            height: 90,
            margin: const EdgeInsets.only(top: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: controller.attachments.length,
              itemBuilder: (context, index) {
                final url = controller.attachments[index];
                return Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: url.startsWith('http') && url.contains('picsum')
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(11),
                                child: Image.network(url, width: 80, height: 80, fit: BoxFit.cover),
                              )
                            : Icon(
                                url.endsWith('.mp4') ? Icons.play_circle_outline_rounded : Icons.insert_drive_file_outlined,
                                color: isDark ? Colors.white54 : Colors.black54,
                                size: 28,
                              ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => controller.removeAttachment(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            child: const Icon(Icons.close_rounded, color: Colors.white, size: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAttachmentButton(IconData icon, String type, bool isDark) {
    return InkWell(
      onTap: () => controller.addAttachment(type),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cinematicSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isDark ? Colors.white30 : Colors.black38, size: 20),
            const SizedBox(height: 6),
            Text(
              type,
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black54,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceAttachedInfo(bool isDark) {
    final authService = Get.find<AuthService>();
    final user = authService.currentUserModel.value;
    final deviceName = user?.device?.deviceName ?? 'SmartThermo Pro';
    final serialNo = user?.device?.serialNo ?? 'SN-2024-001234';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cinematicSurface.withValues(alpha: 0.5) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.memory_rounded, color: AppColors.primary, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Device Info auto-attached',
                  style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  '$serialNo - $deviceName',
                  style: TextStyle(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.4),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.green, blurRadius: 4, spreadRadius: 1)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Obx(() {
      final isSubmitting = controller.isSubmitting.value;

      return SizedBox(
        width: double.infinity,
        height: 52,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.indigoPrimaryDark],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: isSubmitting ? null : () => controller.submitSupportRequest(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send_rounded, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Submit Support Request',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
          ),
        ),
      );
    });
  }
}
