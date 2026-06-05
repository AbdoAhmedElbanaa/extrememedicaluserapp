import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:extrememedicaluserapp/features/notifications/models/notification_model.dart';
import 'package:extrememedicaluserapp/features/notifications/services/notifications_service.dart';

class OneSignalService {
  static bool _isInitialized = false;
  static String? _pendingUserId;

  static const String defaultAppId = '05cddd0a-4e2c-446f-bf84-8e2d076d6f5f';

  static Future<void> initializeDynamic() async {
    if (_isInitialized) return;
    String appId = defaultAppId;
    try {
      final snapshot = await FirebaseDatabase.instance
          .ref('contact_support/config/onesignal/appId')
          .get();

      if (snapshot.exists && snapshot.value != null) {
        final dbAppId = snapshot.value.toString().trim();
        if (dbAppId.isNotEmpty) {
          appId = dbAppId;
          debugPrint('Retrieved dynamic OneSignal App ID: $appId');
        }
      } else {
        debugPrint('OneSignal configuration not found in Realtime Database. Using default App ID.');
      }
    } catch (e) {
      debugPrint('Error fetching dynamic OneSignal App ID: $e. Using default App ID.');
    }

    try {
      debugPrint('Initializing OneSignal with App ID: $appId');
      OneSignal.Debug.setLogLevel(OSLogLevel.none);
      OneSignal.initialize(appId);
      
      // Request notification permissions
      await OneSignal.Notifications.requestPermission(true);
      
      // Ensure push subscription is enabled to stay active
      OneSignal.User.pushSubscription.optIn();

      // Foreground notification listener
      OneSignal.Notifications.addForegroundWillDisplayListener((event) {
        debugPrint('OneSignal foreground notification: ${event.notification.title}');
        final additionalData = event.notification.additionalData;
        final notif = NotificationModel(
          id: event.notification.notificationId,
          title: event.notification.title ?? '',
          body: event.notification.body ?? '',
          receivedAt: DateTime.now(),
          isRead: false,
          route: additionalData?['route'] as String?,
          ticketId: additionalData?['ticketId'] as String?,
          payload: additionalData != null ? Map<String, dynamic>.from(additionalData) : const {},
        );
        NotificationsService.to.saveNotification(notif);
        event.notification.display();
      });

      // Notification click listener
      OneSignal.Notifications.addClickListener((event) {
        debugPrint('OneSignal notification click: ${event.notification.title}');
        final additionalData = event.notification.additionalData;
        final notif = NotificationModel(
          id: event.notification.notificationId,
          title: event.notification.title ?? '',
          body: event.notification.body ?? '',
          receivedAt: DateTime.now(),
          isRead: true,
          route: additionalData?['route'] as String?,
          ticketId: additionalData?['ticketId'] as String?,
          payload: additionalData != null ? Map<String, dynamic>.from(additionalData) : const {},
        );
        NotificationsService.to.saveNotification(notif);
        NotificationsService.to.handleNotificationNavigation(notif);
      });
      
      _isInitialized = true;

      // Handle login for already logged-in or pending users
      final activeUser = FirebaseAuth.instance.currentUser;
      final userIdToLogin = _pendingUserId ?? activeUser?.uid;
      if (userIdToLogin != null) {
        loginUser(userIdToLogin);
      }
    } catch (e) {
      debugPrint('Error initializing OneSignal: $e');
    }
  }

  static void loginUser(String userId) {
    if (!_isInitialized) {
      _pendingUserId = userId;
      debugPrint('OneSignal not initialized yet. Queueing login for user: $userId');
      return;
    }
    try {
      debugPrint('Logging user into OneSignal: $userId');
      OneSignal.login(userId);
      _pendingUserId = null;
    } catch (e) {
      debugPrint('Failed to login OneSignal user: $e');
    }
  }

  static void logoutUser() {
    _pendingUserId = null;
    if (!_isInitialized) return;
    try {
      debugPrint('Logging user out of OneSignal');
      OneSignal.logout();
    } catch (e) {
      debugPrint('Failed to logout OneSignal user: $e');
    }
  }

  static Future<void> setPushEnabled(bool enabled) async {
    try {
      if (!_isInitialized) await initializeDynamic();
      debugPrint('Setting OneSignal push enabled: $enabled');
      if (enabled) {
        OneSignal.User.pushSubscription.optIn();
      } else {
        OneSignal.User.pushSubscription.optOut();
      }
    } catch (e) {
      debugPrint('Failed to set push subscription: $e');
    }
  }

  static Future<void> setNotificationTag(String tag, bool enabled) async {
    try {
      if (!_isInitialized) await initializeDynamic();
      debugPrint('Setting OneSignal tag: $tag = $enabled');
      OneSignal.User.addTagWithKey(tag, enabled ? 'true' : 'false');
    } catch (e) {
      debugPrint('Failed to set tag: $e');
    }
  }

  static Future<String?> getPlayerId() async {
    try {
      if (!_isInitialized) await initializeDynamic();
      final id = OneSignal.User.pushSubscription.id;
      debugPrint('Retrieved OneSignal Player ID: $id');
      return id;
    } catch (e) {
      debugPrint('Failed to get player ID: $e');
      return null;
    }
  }

  static Future<bool> isSubscribed() async {
    try {
      if (!_isInitialized) await initializeDynamic();
      return OneSignal.User.pushSubscription.optedIn ?? false;
    } catch (e) {
      debugPrint('Failed to check subscription: $e');
      return false;
    }
  }
}
