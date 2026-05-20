import 'package:extrememedicaluserapp/features/auth/presentation/views/login_view.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:extrememedicaluserapp/features/permissions/data/models/permission_model.dart';

class PermissionsController extends GetxController {
  final storage = GetStorage();
  final List<PermissionModel> permissionsList = [
// ... (keep the rest of the permissionsList)
    PermissionModel(
      title: 'Notifications',
      description: 'Stay updated with real-time device alerts, maintenance reminders, and important updates.',
      icon: Icons.notifications_active_rounded,
      permission: Permission.notification,
    ),
    PermissionModel(
      title: 'Camera Access',
      description: 'Used for scanning medical equipment barcodes and capturing device diagnostic images.',
      icon: Icons.camera_alt_rounded,
      permission: Permission.camera,
    ),
    PermissionModel(
      title: 'Storage Access',
      description: 'Required to save and access medical manuals, offline guides, and diagnostic reports.',
      icon: Icons.folder_shared_rounded,
      permission: Permission.storage,
    ),
    PermissionModel(
      title: 'Nearby Devices',
      description: 'Used to discover and connect to your smart medical equipment via Bluetooth/WiFi.',
      icon: Icons.devices_other_rounded,
      permission: Permission.nearbyWifiDevices,
    ),
    PermissionModel(
      title: 'Background Work',
      description: 'Allows the app to sync data and receive urgent alerts even when not in the foreground.',
      icon: Icons.running_with_errors_rounded,
      permission: Permission.ignoreBatteryOptimizations,
    ),
  ];

  var permissionStatuses = <Permission, PermissionStatus>{}.obs;

  @override
  void onInit() {
    super.onInit();
    refreshPermissions();
  }

  Future<void> refreshPermissions() async {
    for (var model in permissionsList) {
      PermissionStatus status = await model.permission.status;

      // Fix for Storage on Android 13+
      if (model.permission == Permission.storage && !status.isGranted) {
        final photos = await Permission.photos.status;
        final videos = await Permission.videos.status;
        final audio = await Permission.audio.status;
        if (photos.isGranted || videos.isGranted || audio.isGranted) {
          status = PermissionStatus.granted;
        }
      }

      permissionStatuses[model.permission] = status;
    }
  }

  // Request a single permission when clicking on a card
  Future<void> requestSinglePermission(Permission permission) async {
    PermissionStatus status;

    if (permission == Permission.storage) {
      // Try standard storage first
      status = await permission.request();

      // Android 13+ Fallback: request media permissions if storage request didn't result in "granted"
      if (!status.isGranted) {
        final Map<Permission, PermissionStatus> statuses = await [
          Permission.photos,
          Permission.videos,
          Permission.audio,
        ].request();

        if (statuses.values.any((s) => s.isGranted)) {
          status = PermissionStatus.granted;
        }
      }
    } else {
      status = await permission.request();
    }

    permissionStatuses[permission] = status;

    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  // Request all permissions that are not yet granted
  Future<void> requestAllPermissions() async {
    List<Permission> toRequest = [];
    for (var model in permissionsList) {
      final currentStatus = permissionStatuses[model.permission];
      if (currentStatus == null || !currentStatus.isGranted) {
        toRequest.add(model.permission);
      }
    }

    if (toRequest.isEmpty) {
      goToNextScreen();
      return;
    }

    Map<Permission, PermissionStatus> statuses = await toRequest.request();
    permissionStatuses.addAll(statuses);

    // After requesting, check if everything important is granted
    if (permissionStatuses.values.every((s) => s.isGranted)) {
      goToNextScreen();
    }
  }

  void skipPermissions() {
    goToNextScreen();
  }

  void goToNextScreen() {
    storage.write('all_permissions_granted', true);
    Get.offAll(() => const LoginView());
  }
}
