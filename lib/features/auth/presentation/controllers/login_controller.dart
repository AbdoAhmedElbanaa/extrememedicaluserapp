import 'package:extrememedicaluserapp/features/auth/data/user_repository.dart';
import 'package:extrememedicaluserapp/features/auth/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:extrememedicaluserapp/features/auth/services/auth_service.dart';
import 'package:extrememedicaluserapp/core/services/toast_service.dart';
import 'package:extrememedicaluserapp/core/routes/app_routes.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  final _authService = Get.find<AuthService>();
  final _userRepo = Get.find<UserRepository>();
  
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
      final userCredential = await _authService.signInWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      
      if (userCredential.user != null) {
        await _authService.loadUserModel(userCredential.user!.uid);
        final uid = userCredential.user!.uid;
        GetStorage().write('2fa_verified_$uid', false);
        
        final userModel = _authService.currentUserModel.value;
        if (userModel != null && userModel.twoFactorEnabled) {
          ToastService.show(
            title: '2FA Required',
            message: 'Please verify the security code to proceed',
            type: ToastType.info,
          );
          Get.offAllNamed(AppRoutes.twoFactorVerification);
          return;
        }
      }
      
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
        final user = userCredential.user!;
        
        // Ensure user exists in Firestore
        final existingUser = await _userRepo.getUser(user.uid);
        if (existingUser == null) {
          String firstName = 'User';
          String lastName = '';
          if (user.displayName != null && user.displayName!.isNotEmpty) {
            List<String> parts = user.displayName!.split(' ');
            firstName = parts.first;
            if (parts.length > 1) lastName = parts.sublist(1).join(' ');
          }

          final newUser = UserModel(
            uid: user.uid,
            email: user.email,
            phoneNumber: user.phoneNumber,
            firstName: firstName,
            lastName: lastName,
          );
          await _userRepo.createUser(newUser);
          _authService.currentUserModel.value = newUser;
        } else {
          _authService.currentUserModel.value = existingUser;
        }

        final uid = user.uid;
        GetStorage().write('2fa_verified_$uid', false);
        
        final userModel = _authService.currentUserModel.value;
        if (userModel != null && userModel.twoFactorEnabled) {
          ToastService.show(
            title: '2FA Required',
            message: 'Please verify the security code to proceed',
            type: ToastType.info,
          );
          Get.offAllNamed(AppRoutes.twoFactorVerification);
          return;
        }

        ToastService.show(
          title: 'Success',
          message: 'Logged in with Google successfully',
          type: ToastType.success,
        );
        Get.offAllNamed(AppRoutes.home);
      }
    } catch (e) {
      debugPrint('Google Login Error: $e');
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
