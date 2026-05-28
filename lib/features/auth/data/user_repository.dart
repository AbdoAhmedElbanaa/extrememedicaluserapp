import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'models/user_model.dart';

class UserRepository extends GetxService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  Future<void> createUser(UserModel user) async {
    await _db.ref('users').child(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    var snapshot = await _db.ref('users').child(uid).get();
    if (snapshot.exists && snapshot.value != null) {
      final map = Map<String, dynamic>.from(snapshot.value as Map);
      return UserModel.fromMap(map);
    }
    return null;
  }
}
