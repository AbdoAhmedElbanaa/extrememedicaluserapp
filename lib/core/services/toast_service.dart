import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';

enum ToastType { success, error, warning, info }

class ToastService {
  static void show({
    required String title,
    required String message,
    ToastType type = ToastType.success,
  }) {
    final context = Get.context;
    if (context == null) return;

    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;

    Color primaryColor;
    IconData icon;

    switch (type) {
      case ToastType.success:
        primaryColor = AppColors.success;
        icon = Icons.check_rounded;
        break;
      case ToastType.error:
        primaryColor = AppColors.errorRed;
        icon = Icons.close_rounded;
        break;
      case ToastType.warning:
        primaryColor = AppColors.warning;
        icon = Icons.warning_amber_rounded;
        break;
      case ToastType.info:
        primaryColor = AppColors.bluePrimary;
        icon = Icons.info_outline_rounded;
        break;
    }

    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      autoCloseDuration: const Duration(seconds: 4),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      description: Text(
        message,
        style: TextStyle(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.6),
          fontSize: 12,
        ),
      ),
      alignment: Alignment.topCenter,
      direction: TextDirection.ltr,
      animationDuration: const Duration(milliseconds: 400),
      animationBuilder: (context, animation, alignment, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.elasticOut,
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, color: primaryColor, size: 20),
      ),
      showIcon: true,
      primaryColor: primaryColor,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      foregroundColor: isDark ? Colors.white : Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide(
        color: isDark ? Colors.white.withValues(alpha: 0.1) : primaryColor
            .withValues(alpha: 0.4),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
      showProgressBar: false,
      closeButtonShowType: CloseButtonShowType.onHover,
      closeOnClick: false,
      pauseOnHover: true,
      dragToClose: true,
      applyBlurEffect: true,
      // Stacking configuration for iOS style
      callbacks: ToastificationCallbacks(
        onTap: (item) => toastification.dismiss(item),
      ),
    );
  }
}
