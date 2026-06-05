import 'dart:io' show File;
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:extrememedicaluserapp/features/auth/services/auth_service.dart';
import 'package:extrememedicaluserapp/features/contact/models/ticket_model.dart';
import 'package:extrememedicaluserapp/features/contact/models/contact_config_model.dart';
import 'package:extrememedicaluserapp/features/contact/services/contact_service.dart';
import 'package:extrememedicaluserapp/core/routes/app_routes.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';

class ContactController extends GetxController {
  final ContactService _service = ContactService();
  final AuthService _authService = Get.find<AuthService>();

  // Config availability settings
  final Rxn<ContactConfigModel> config = Rxn<ContactConfigModel>();

  // Subscriptions & Tickets
  final RxList<TicketModel> userTickets = <TicketModel>[].obs;
  final Rxn<TicketModel> activeTicket = Rxn<TicketModel>();

  // Active Filter state
  final RxString activeFilter = 'All'.obs;

  // Filtered User Tickets Getter
  List<TicketModel> get filteredTickets {
    if (activeFilter.value == 'Open') {
      return userTickets.where((t) => t.status != 'RESOLVED' && t.status != 'CLOSED').toList();
    } else if (activeFilter.value == 'Closed') {
      return userTickets.where((t) => t.status == 'RESOLVED' || t.status == 'CLOSED').toList();
    }
    return userTickets;
  }

  // Active tickets counts
  int get openTicketsCount => userTickets.where((t) => t.status != 'RESOLVED' && t.status != 'CLOSED').length;
  int get closedTicketsCount => userTickets.where((t) => t.status == 'RESOLVED' || t.status == 'CLOSED').length;

  // Checks if user has an active ticket to prevent creating a new one
  bool get hasActiveTicket => openTicketsCount > 0;

  // Form Fields State
  final RxString selectedSubject = ''.obs;
  final RxString selectedPriority = 'Medium'.obs;
  final TextEditingController errorCodeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final RxList<String> attachments = <String>[].obs;
  final RxBool isChatRequest = false.obs;

  // Upload/Submit State
  final RxBool isUploading = false.obs;
  final RxDouble uploadProgress = 0.0.obs;
  final RxBool isSubmitting = false.obs;

  final RxList<String> subjects = <String>[].obs;

  final List<String> priorities = ['Low', 'Medium', 'High', 'Critical'];

  @override
  void onInit() {
    super.onInit();
    _bindStreams();
  }

  @override
  void onClose() {
    errorCodeController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  void _bindStreams() {
    // Watch Contact Availability Configuration
    config.bindStream(_service.watchContactConfig());

    // Sync subjects from config
    ever(config, (ContactConfigModel? cfg) {
      if (cfg != null) {
        subjects.assignAll(cfg.subjects);
        if (!subjects.contains(selectedSubject.value) && subjects.isNotEmpty) {
          selectedSubject.value = subjects.first;
        }
      }
    });

    // Watch Tickets for the current user
    final uid = _authService.currentUser?.uid;
    if (uid != null) {
      userTickets.bindStream(_service.watchTicketsForUser(uid));
      
      // Keep activeTicket updated
      ever(userTickets, (List<TicketModel> tickets) {
        final active = tickets.firstWhereOrNull((t) => t.status != 'RESOLVED');
        activeTicket.value = active;
      });
    }
  }

  void changeSubject(String value) {
    selectedSubject.value = value;
  }

  void changePriority(String value) {
    selectedPriority.value = value;
  }

  final ImagePicker _picker = ImagePicker();

  // Actual File Attachment
  void addAttachment(String type) async {
    if (type == 'Photo') {
      _showImageSourceDialog(isVideo: false);
    } else if (type == 'Video') {
      _showImageSourceDialog(isVideo: true);
    } else {
      _pickGeneralFile();
    }
  }

  Future<void> _showImageSourceDialog({required bool isVideo}) async {
    final isDark = Get.isDarkMode;
    
    await Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cinematicSurface : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
              width: 1.5,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isVideo ? 'Choose Video Source' : 'Choose Photo Source',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(
                  icon: isVideo ? Icons.videocam_rounded : Icons.camera_alt_rounded,
                  label: isVideo ? 'Record Video' : 'Take Photo',
                  onTap: () {
                    Get.back();
                    _pickMedia(isVideo: isVideo, fromCamera: true);
                  },
                  isDark: isDark,
                ),
                _buildSourceOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  onTap: () {
                    Get.back();
                    _pickMedia(isVideo: isVideo, fromCamera: false);
                  },
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickMedia({required bool isVideo, required bool fromCamera}) async {
    try {
      XFile? pickedFile;
      if (isVideo) {
        pickedFile = await _picker.pickVideo(
          source: fromCamera ? ImageSource.camera : ImageSource.gallery,
          maxDuration: const Duration(minutes: 5),
        );
      } else {
        pickedFile = await _picker.pickImage(
          source: fromCamera ? ImageSource.camera : ImageSource.gallery,
          imageQuality: 85,
        );
      }

      if (pickedFile != null) {
        final fileName = pickedFile.name;
        final fileBytes = await pickedFile.readAsBytes();
        await _uploadAndAddAttachment(fileName: fileName, filePath: pickedFile.path, fileBytes: fileBytes);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick media: $e');
    }
  }

  Future<void> _pickGeneralFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.any,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final fileName = file.name;
        final filePath = file.path;
        
        Uint8List? fileBytes = file.bytes;
        if (fileBytes == null && filePath != null) {
          fileBytes = await File(filePath).readAsBytes();
        }

        if (fileBytes != null) {
          await _uploadAndAddAttachment(fileName: fileName, filePath: filePath, fileBytes: fileBytes);
        } else {
          Get.snackbar('Error', 'Could not read file data.');
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick file: $e');
    }
  }

  Future<void> _uploadAndAddAttachment({
    required String fileName,
    required String? filePath,
    required Uint8List fileBytes,
  }) async {
    try {
      isUploading.value = true;
      uploadProgress.value = 0.0;

      final url = await _service.uploadAttachment(
        fileName: fileName,
        filePath: filePath,
        fileBytes: fileBytes,
        onProgress: (progress) {
          uploadProgress.value = progress;
        },
      );

      attachments.add(url);
      Get.snackbar(
        'Attachment Uploaded',
        'File uploaded successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.15),
        colorText: Colors.green,
      );
    } catch (e) {
      Get.snackbar('Upload Failed', 'Failed to upload attachment: $e');
    } finally {
      isUploading.value = false;
    }
  }

  void removeAttachment(int index) {
    if (index >= 0 && index < attachments.length) {
      attachments.removeAt(index);
    }
  }

  // Submit support ticket to RTDB
  Future<void> submitSupportRequest() async {
    if (hasActiveTicket) {
      Get.snackbar(
        'Submission Blocked',
        'You already have an active support request. Please resolve it or wait for support before opening another.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withValues(alpha: 0.15),
        colorText: Colors.orange,
      );
      return;
    }

    if (descriptionController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please describe your support request in detail.');
      return;
    }

    try {
      isSubmitting.value = true;

      // Current User context
      final user = _authService.currentUserModel.value;
      final userId = _authService.currentUser?.uid ?? 'anonymous';
      final clinicName = user?.clinicName ?? user?.email ?? 'Unknown Clinic';
      final deviceName = user?.device?.deviceName ?? 'SmartThermo Pro';
      final serialNo = user?.device?.serialNo ?? 'SN-2024-001234';

      // Generate Ticket ID like UM-91180
      final ticketNumber = Random().nextInt(90000) + 10000;
      final ticketId = 'UM-$ticketNumber';

      final newTicket = TicketModel(
        id: ticketId,
        subject: selectedSubject.value,
        priority: selectedPriority.value,
        errorCode: errorCodeController.text.trim().isNotEmpty ? errorCodeController.text.trim() : null,
        description: descriptionController.text.trim(),
        deviceName: deviceName,
        serialNo: serialNo,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        userId: userId,
        clinicName: clinicName,
        attachments: List<String>.from(attachments),
        status: 'IN REVIEW',
        isChat: isChatRequest.value,
      );

      await _service.submitTicket(newTicket);
      await _service.createTicketNotification(newTicket);

      // Reset form
      resetForm();

      // Go to confirmation page
      Get.offNamed(AppRoutes.ticketSubmitted, arguments: newTicket);
    } catch (e) {
      Get.snackbar('Submission Failed', 'Failed to send ticket: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  void resetForm() {
    selectedSubject.value = subjects.isNotEmpty ? subjects.first : '';
    selectedPriority.value = 'Medium';
    errorCodeController.clear();
    descriptionController.clear();
    attachments.clear();
    isChatRequest.value = false;
  }
}
