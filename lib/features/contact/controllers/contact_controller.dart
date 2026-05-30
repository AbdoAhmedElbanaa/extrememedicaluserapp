import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/features/auth/services/auth_service.dart';
import 'package:extrememedicaluserapp/features/contact/models/ticket_model.dart';
import 'package:extrememedicaluserapp/features/contact/models/contact_config_model.dart';
import 'package:extrememedicaluserapp/features/contact/services/contact_service.dart';
import 'package:extrememedicaluserapp/core/routes/app_routes.dart';

class ContactController extends GetxController {
  final ContactService _service = ContactService();
  final AuthService _authService = Get.find<AuthService>();

  // Config availability settings
  final Rxn<ContactConfigModel> config = Rxn<ContactConfigModel>();

  // Subscriptions & Tickets
  final RxList<TicketModel> userTickets = <TicketModel>[].obs;
  final Rxn<TicketModel> activeTicket = Rxn<TicketModel>();

  // Form Fields State
  final RxString selectedSubject = ''.obs;
  final RxString selectedPriority = 'Medium'.obs;
  final TextEditingController errorCodeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final RxList<String> attachments = <String>[].obs;

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

  // Simulate File Attachment with progress dialog
  void addAttachment(String type) async {
    isUploading.value = true;
    uploadProgress.value = 0.0;

    // Simulate progress upload
    for (int i = 0; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      uploadProgress.value = i * 10.0;
    }

    // Generate simulated file URL
    final randomVal = Random().nextInt(100000);
    String fileName;
    if (type == 'Photo') {
      fileName = 'https://picsum.photos/seed/$randomVal/600/400';
    } else if (type == 'Video') {
      fileName = 'https://www.w3schools.com/html/mov_bbb.mp4';
    } else {
      fileName = 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';
    }

    attachments.add(fileName);
    isUploading.value = false;
    Get.snackbar(
      'Attachment Added',
      'Simulated $type upload completed successfully.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withValues(alpha: 0.15),
      colorText: Colors.green,
    );
  }

  void removeAttachment(int index) {
    if (index >= 0 && index < attachments.length) {
      attachments.removeAt(index);
    }
  }

  // Submit support ticket to RTDB
  Future<void> submitSupportRequest() async {
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
      );

      await _service.submitTicket(newTicket);

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
  }
}
