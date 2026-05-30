import 'package:firebase_database/firebase_database.dart';
import '../models/ticket_model.dart';
import '../models/contact_config_model.dart';

class ContactService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

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
