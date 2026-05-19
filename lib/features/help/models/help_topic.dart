import 'package:flutter/material.dart';

class HelpTopic {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final String? route;

  HelpTopic({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.route,
  });
}
