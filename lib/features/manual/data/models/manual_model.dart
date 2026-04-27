import 'package:flutter/material.dart';

class ManualModel {
  final String title;
  final String deviceName;
  final String lastUpdated;
  final String fileSize;
  final IconData icon;
  final Color color;

  ManualModel({
    required this.title,
    required this.deviceName,
    required this.lastUpdated,
    required this.fileSize,
    required this.icon,
    required this.color,
  });
}
