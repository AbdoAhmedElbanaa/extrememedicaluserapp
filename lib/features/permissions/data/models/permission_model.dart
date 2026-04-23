import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionModel {
  final String title;
  final String description;
  final IconData icon;
  final Permission permission;
  final bool isRequired;

  PermissionModel({
    required this.title,
    required this.description,
    required this.icon,
    required this.permission,
    this.isRequired = true,
  });
}
