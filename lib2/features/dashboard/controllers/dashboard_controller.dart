import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxInt totalUsers = 0.obs;
  final RxInt totalOrders = 0.obs;
  final RxDouble revenue = 0.0.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStats();
  }

  void fetchStats() {
    isLoading.value = true;
    
    // Stream for Total Users
    _firestore.collection('users').snapshots().listen((snapshot) {
      totalUsers.value = snapshot.docs.length;
    });

    // Stream for Total Orders and Revenue
    _firestore.collection('orders').snapshots().listen((snapshot) {
      totalOrders.value = snapshot.docs.length;
      
      double totalRev = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data.containsKey('totalPrice')) {
          totalRev += (data['totalPrice'] as num).toDouble();
        }
      }
      revenue.value = totalRev;
      
      isLoading.value = false;
    });
    
    // In case collections are empty
    Future.delayed(const Duration(seconds: 2), () {
      if (isLoading.value) isLoading.value = false;
    });
  }
}
