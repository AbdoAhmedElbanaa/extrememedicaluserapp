import 'package:flutter/material.dart';

class OnboardingModel {
  final String title;
  final String description;
  final IconData? icon;
  final String? imagePath;
  final List<Color> gradientColors;
  final bool isImagePage;

  OnboardingModel({
    required this.title,
    required this.description,
    this.icon,
    this.imagePath,
    required this.gradientColors,
    this.isImagePage = false,
  });
}
