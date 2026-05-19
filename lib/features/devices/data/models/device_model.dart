import 'package:flutter/material.dart';

enum DeviceStatus { online, warning, offline }

class DeviceModel {
  final String id;
  final String name;
  final String model;
  final String serialNumber;
  final DeviceStatus status;
  final String lastSync;
  final int batteryLevel; // نسبة مئوية 0-100
  final int signalStrength; // نسبة مئوية 0-100
  final String firmwareVersion;
  final IconData icon;

  DeviceModel({
    required this.id,
    required this.name,
    required this.model,
    required this.serialNumber,
    required this.status,
    required this.lastSync,
    required this.batteryLevel,
    required this.signalStrength,
    required this.firmwareVersion,
    required this.icon,
  });
}
