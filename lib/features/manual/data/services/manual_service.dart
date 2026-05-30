import 'package:firebase_database/firebase_database.dart';
import '../models/manual_step_model.dart';

class ManualService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  Future<List<ManualStepModel>> getManualSteps() async {
    final ref = _db.ref('user_manual/steps');
    final snapshot = await ref.get();

    if (!snapshot.exists || snapshot.value == null) {
      return [];
    }

    final List<ManualStepModel> list = [];
    final val = snapshot.value;
    if (val is Map) {
      val.forEach((key, value) {
        if (value != null) {
          list.add(ManualStepModel.fromMap(Map<String, dynamic>.from(value as Map)));
        }
      });
    } else if (val is List) {
      for (int i = 0; i < val.length; i++) {
        final value = val[i];
        if (value != null) {
          list.add(ManualStepModel.fromMap(Map<String, dynamic>.from(value as Map)));
        }
      }
    }

    // Sort by stepNumber
    list.sort((a, b) => a.stepNumber.compareTo(b.stepNumber));
    return list;
  }
}
