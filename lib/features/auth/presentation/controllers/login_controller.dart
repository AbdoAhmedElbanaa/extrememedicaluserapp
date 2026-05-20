import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/features/auth/services/auth_service.dart';
import 'package:extrememedicaluserapp/core/services/toast_service.dart';
import 'package:extrememedicaluserapp/core/routes/app_routes.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  final _authService = Get.find<AuthService>();
  
  var isPasswordVisible = false.obs;
  var isLoading = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login() async {
    if (emailController.text.trim().isEmpty || passwordController.text.trim().isEmpty) {
      ToastService.show(
        title: 'Error',
        message: 'Please fill in all fields',
        type: ToastType.error,
      );
      return;
    }

    if (isLoading.value) return;
    
    isLoading.value = true;
    try {
      await _authService.signInWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      
      ToastService.show(
        title: 'Success',
        message: 'Logged in successfully',
        type: ToastType.success,
      );

      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      ToastService.show(
        title: 'Login Failed',
        message: e.toString(),
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithGoogle() async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      final userCredential = await _authService.signInWithGoogle();
      if (userCredential != null) {
        ToastService.show(
          title: 'Success',
          message: 'Logged in with Google successfully',
          type: ToastType.success,
        );
        Get.offAllNamed(AppRoutes.home);
      }
    } catch (e) {
      ToastService.show(
        title: 'Google Login Failed',
        message: e.toString(),
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
