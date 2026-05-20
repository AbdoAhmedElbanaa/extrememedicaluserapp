import 'package:get/get.dart';
import '../../../shared/services/firebase_service.dart';

class UsersController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  final RxList<Map<String, dynamic>> users = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  void fetchUsers() async {
    // Placeholder for actual Firestore fetch
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    users.value = [
      {'id': '1', 'name': 'John Doe', 'email': 'john@example.com'},
      {'id': '2', 'name': 'Jane Smith', 'email': 'jane@example.com'},
    ];
    isLoading.value = false;
  }
}
