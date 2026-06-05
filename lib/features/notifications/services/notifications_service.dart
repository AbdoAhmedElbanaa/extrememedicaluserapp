import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/notification_model.dart';
import 'package:extrememedicaluserapp/features/contact/services/contact_service.dart';
import 'package:extrememedicaluserapp/core/routes/app_routes.dart';

class NotificationsService extends GetxService {
  static NotificationsService get to => Get.find<NotificationsService>();

  final GetStorage _storage = GetStorage();
  static const String _storageKey = 'notifications_list';

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxInt unreadCount = 0.obs;

  Future<NotificationsService> init() async {
    loadNotifications();
    return this;
  }

  void loadNotifications() {
    try {
      final List<dynamic>? saved = _storage.read<List<dynamic>>(_storageKey);
      if (saved != null) {
        notifications.assignAll(
          saved.map((item) => NotificationModel.fromMap(Map<String, dynamic>.from(item))).toList(),
        );
      }
      _updateUnreadCount();
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  void saveNotification(NotificationModel notif) {
    // Avoid duplicates by ID
    notifications.removeWhere((item) => item.id == notif.id);
    notifications.insert(0, notif);
    _saveToStorage();
    _updateUnreadCount();
  }

  void markAsRead(String id) {
    final index = notifications.indexWhere((item) => item.id == id);
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      _saveToStorage();
      _updateUnreadCount();
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < notifications.length; i++) {
      notifications[i] = notifications[i].copyWith(isRead: true);
    }
    _saveToStorage();
    _updateUnreadCount();
  }

  void deleteNotification(String id) {
    notifications.removeWhere((item) => item.id == id);
    _saveToStorage();
    _updateUnreadCount();
  }

  void clearAll() {
    notifications.clear();
    _saveToStorage();
    _updateUnreadCount();
  }

  void _saveToStorage() {
    try {
      final data = notifications.map((notif) => notif.toMap()).toList();
      _storage.write(_storageKey, data);
    } catch (e) {
      debugPrint('Error saving notifications: $e');
    }
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((item) => !item.isRead).length;
  }

  Future<void> handleNotificationNavigation(NotificationModel notif) async {
    // Mark as read immediately on tap/click
    markAsRead(notif.id);

    // Dynamic routing
    final ticketId = notif.ticketId;
    final route = notif.route;

    if (ticketId != null && ticketId.isNotEmpty) {
      // Show loading indicator
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      final contactService = ContactService();
      final ticket = await contactService.getTicket(ticketId);

      // Close loading dialog
      Get.back();

      if (ticket != null) {
        if (route == 'chat_support' || notif.title.toLowerCase().contains('chat') || notif.body.toLowerCase().contains('chat')) {
          Get.toNamed(AppRoutes.chatSupport, arguments: ticket);
        } else {
          Get.toNamed(AppRoutes.ticketTracker, arguments: ticket);
        }
      } else {
        Get.toNamed(AppRoutes.mySupportRequests);
      }
    } else if (route != null && route.isNotEmpty) {
      if (route == 'my_support_requests') {
        Get.toNamed(AppRoutes.mySupportRequests);
      } else {
        Get.toNamed(route);
      }
    }
  }
}
