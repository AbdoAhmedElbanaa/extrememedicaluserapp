import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:extrememedicaluserapp/features/auth/services/auth_service.dart';
import '../models/chat_message_model.dart';
import '../models/ticket_model.dart';
import '../services/chat_service.dart';

class ChatController extends GetxController {
  final ChatService _service = ChatService();
  final AuthService _authService = Get.find<AuthService>();

  late final TicketModel ticket;
  final RxList<ChatMessageModel> messages = <ChatMessageModel>[].obs;
  final RxString ticketStatus = 'IN REVIEW'.obs;

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final RxBool isSending = false.obs;
  final RxString currentInputText = ''.obs;

  // Media & Recording fields
  final AudioRecorder recorder = AudioRecorder();
  final RxBool isRecording = false.obs;
  final RxString recordingPath = ''.obs;
  final ImagePicker _picker = ImagePicker();

  bool get isClosed => ticketStatus.value == 'RESOLVED' || ticketStatus.value == 'CLOSED';

  @override
  void onInit() {
    super.onInit();
    messageController.addListener(() {
      currentInputText.value = messageController.text;
    });
    final args = Get.arguments;
    if (args is TicketModel) {
      ticket = args;
      ticketStatus.value = ticket.status;
      _bindStreams();
    } else {
      // Fallback if args not provided properly (should not happen in prod)
      Get.back();
      Get.snackbar('Error', 'Invalid Ticket Details');
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    recorder.dispose();
    super.onClose();
  }

  void _bindStreams() {
    messages.bindStream(_service.watchMessages(ticket.id));
    ticketStatus.bindStream(_service.watchTicketStatus(ticket.id));

    // Auto scroll when new messages arrive
    ever(messages, (_) {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  Future<void> sendChatMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty || isClosed) return;

    try {
      isSending.value = true;
      final userId = _authService.currentUser?.uid ?? 'anonymous';
      
      final user = _authService.currentUserModel.value;
      final senderName = user != null ? '${user.firstName} ${user.lastName}' : 'Clinic User';

      final msgId = 'MSG-${DateTime.now().millisecondsSinceEpoch}';
      final newMessage = ChatMessageModel(
        id: msgId,
        senderId: userId,
        senderName: senderName,
        message: text,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        isSystem: false,
      );

      messageController.clear();
      await _service.sendMessage(ticket.id, newMessage);
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message: $e');
    } finally {
      isSending.value = false;
    }
  }

  Future<void> startRecording() async {
    if (isClosed) return;
    try {
      if (await recorder.hasPermission()) {
        final tempDir = await getTemporaryDirectory();
        final path = '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
        isRecording.value = true;
        recordingPath.value = path;
      } else {
        Get.snackbar('Permission Denied', 'Microphone permission is required to record audio.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to start recording: $e');
    }
  }

  Future<void> stopAndSendRecording() async {
    if (!isRecording.value || isClosed) return;
    try {
      final path = await recorder.stop();
      isRecording.value = false;
      if (path != null) {
        isSending.value = true;
        final downloadUrl = await _service.uploadChatMedia(
          ticketId: ticket.id,
          fileName: 'audio_msg_${DateTime.now().millisecondsSinceEpoch}.m4a',
          filePath: path,
        );

        final userId = _authService.currentUser?.uid ?? 'anonymous';
        final user = _authService.currentUserModel.value;
        final senderName = user != null ? '${user.firstName} ${user.lastName}' : 'Clinic User';
        final msgId = 'MSG-${DateTime.now().millisecondsSinceEpoch}';

        final newMessage = ChatMessageModel(
          id: msgId,
          senderId: userId,
          senderName: senderName,
          message: 'Voice message',
          timestamp: DateTime.now().millisecondsSinceEpoch,
          isSystem: false,
          type: 'audio',
          mediaUrl: downloadUrl,
        );

        await _service.sendMessage(ticket.id, newMessage);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to save recording: $e');
    } finally {
      isSending.value = false;
    }
  }

  Future<void> cancelRecording() async {
    try {
      await recorder.stop();
      isRecording.value = false;
    } catch (e) {
      debugPrint('Error cancelling recording: $e');
    }
  }

  Future<void> pickAndSendMedia(String type) async {
    if (isClosed) return;
    try {
      XFile? pickedFile;
      if (type == 'Photo') {
        pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      } else if (type == 'Video') {
        pickedFile = await _picker.pickVideo(source: ImageSource.gallery, maxDuration: const Duration(minutes: 3));
      }

      if (pickedFile != null) {
        isSending.value = true;
        
        final fileName = pickedFile.name;
        final downloadUrl = await _service.uploadChatMedia(
          ticketId: ticket.id,
          fileName: fileName,
          filePath: pickedFile.path,
        );

        final userId = _authService.currentUser?.uid ?? 'anonymous';
        final user = _authService.currentUserModel.value;
        final senderName = user != null ? '${user.firstName} ${user.lastName}' : 'Clinic User';
        final msgId = 'MSG-${DateTime.now().millisecondsSinceEpoch}';

        final newMessage = ChatMessageModel(
          id: msgId,
          senderId: userId,
          senderName: senderName,
          message: type == 'Photo' ? 'Sent an image' : 'Sent a video',
          timestamp: DateTime.now().millisecondsSinceEpoch,
          isSystem: false,
          type: type == 'Photo' ? 'image' : 'video',
          mediaUrl: downloadUrl,
        );

        await _service.sendMessage(ticket.id, newMessage);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload media: $e');
    } finally {
      isSending.value = false;
    }
  }
}
