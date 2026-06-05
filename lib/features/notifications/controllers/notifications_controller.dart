import 'package:get/get.dart';
import '../models/notification_model.dart';
import '../services/notifications_service.dart';

class NotificationsController extends GetxController {
  final NotificationsService _service = NotificationsService.to;

  RxList<NotificationModel> get notifications => _service.notifications;

  void markAllAsRead() {
    _service.markAllAsRead();
  }

  void clearAll() {
    _service.clearAll();
  }

  void deleteNotification(String id) {
    _service.deleteNotification(id);
  }

  void handleNotificationTap(NotificationModel notif) {
    _service.handleNotificationNavigation(notif);
  }
}
