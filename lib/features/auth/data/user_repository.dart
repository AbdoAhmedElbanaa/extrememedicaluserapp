import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'models/user_model.dart';

class UserRepository extends GetxService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    var snapshot = await _db.collection('users').doc(uid).get();
    if (snapshot.exists) {
      return UserModel.fromMap(snapshot.data()!);
    }
    return null;
  }
}
