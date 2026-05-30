import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/ticket_model.dart';
import '../models/contact_config_model.dart';

class ContactService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadAttachment({
    required String fileName,
    required String? filePath,
    required Uint8List fileBytes,
    required Function(double progress) onProgress,
  }) async {
    final ref = _storage.ref().child('support_attachments').child(
        '${DateTime.now().millisecondsSinceEpoch}_$fileName');
    
    UploadTask uploadTask;
    if (kIsWeb) {
      uploadTask = ref.putData(fileBytes);
    } else {
      if (filePath == null) throw Exception("File path is required on Mobile");
      uploadTask = ref.putFile(File(filePath));
    }
    
    uploadTask.snapshotEvents.listen((event) {
      if (event.totalBytes > 0) {
        final progress = (event.bytesTransferred / event.totalBytes) * 100;
        onProgress(progress);
      }
    });
    
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> submitTicket(TicketModel ticket) async {
    final ref = _db.ref('contact_support/tickets').child(ticket.id);
    await ref.set(ticket.toMap());
  }

  Future<ContactConfigModel> getContactConfig() async {
    final ref = _db.ref('contact_support/config');
    final snapshot = await ref.get();
    if (!snapshot.exists || snapshot.value == null) {
      final defaultConfig = ContactConfigModel(
        status: 'online',
        responseTimeText: 'We typically reply in 2–4 hours',
        responseTime: '2-4 business hours',
      );
      await ref.set(defaultConfig.toMap());
      return defaultConfig;
    }
    return ContactConfigModel.fromMap(Map<String, dynamic>.from(snapshot.value as Map));
  }

  Stream<ContactConfigModel> watchContactConfig() {
    return _db.ref('contact_support/config').onValue.map((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        return ContactConfigModel.fromMap(Map<String, dynamic>.from(event.snapshot.value as Map));
      }
      return ContactConfigModel(
        status: 'online',
        responseTimeText: 'We typically reply in 2–4 hours',
        responseTime: '2-4 business hours',
      );
    });
  }

  Stream<List<TicketModel>> watchTicketsForUser(String userId) {
    return _db.ref('contact_support/tickets').onValue.map((event) {
      final List<TicketModel> list = [];
      final data = event.snapshot.value;
      if (data is Map) {
        data.forEach((key, val) {
          if (val != null) {
            final ticket = TicketModel.fromMap(Map<String, dynamic>.from(val as Map));
            if (ticket.userId == userId) {
              list.add(ticket);
            }
          }
        });
      }
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    });
  }
}
