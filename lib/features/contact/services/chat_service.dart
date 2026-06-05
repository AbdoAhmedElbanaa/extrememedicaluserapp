import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/chat_message_model.dart';

class ChatService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadChatMedia({
    required String ticketId,
    required String fileName,
    required String filePath,
  }) async {
    final ref = _storage
        .ref()
        .child('support_chats')
        .child(ticketId)
        .child('${DateTime.now().millisecondsSinceEpoch}_$fileName');
    final uploadTask = ref.putFile(File(filePath));
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Stream<List<ChatMessageModel>> watchMessages(String ticketId) {
    return _db.ref('contact_support/chats/$ticketId/messages').onValue.map((event) {
      final List<ChatMessageModel> list = [];
      final data = event.snapshot.value;
      if (data is Map) {
        data.forEach((key, val) {
          if (val != null) {
            list.add(ChatMessageModel.fromMap(Map<String, dynamic>.from(val as Map)));
          }
        });
      }
      list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return list;
    });
  }

  Future<void> sendMessage(String ticketId, ChatMessageModel message) async {
    final ref = _db.ref('contact_support/chats/$ticketId/messages').child(message.id);
    await ref.set(message.toMap());
  }

  Stream<String> watchTicketStatus(String ticketId) {
    return _db.ref('contact_support/tickets/$ticketId/status').onValue.map((event) {
      return event.snapshot.value?.toString() ?? 'IN REVIEW';
    });
  }
}
