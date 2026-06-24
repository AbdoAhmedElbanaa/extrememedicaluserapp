import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import 'package:extrememedicaluserapp/core/routes/app_routes.dart';
import 'package:extrememedicaluserapp/core/services/toast_service.dart';
import 'package:extrememedicaluserapp/features/auth/services/auth_service.dart';

class TwoFactorVerificationView extends StatefulWidget {
  const TwoFactorVerificationView({super.key});

  @override
  State<TwoFactorVerificationView> createState() => _TwoFactorVerificationViewState();
}

class _TwoFactorVerificationViewState extends State<TwoFactorVerificationView> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  
  final _authService = Get.find<AuthService>();
  final _storage = GetStorage();
  
  String _generatedCode = '';
  bool _isLoading = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _generateAndSendCode();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _generateAndSendCode() async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;

    setState(() {
      _isSending = true;
    });

    try {
      // Generate random 6 digit code
      final random = Random();
      final code = (100000 + random.nextInt(900000)).toString();
      _generatedCode = code;

      // Save to Firebase RTDB
      await FirebaseDatabase.instance.ref('users').child(uid).update({
        'twoFactorCode': code,
      });

      setState(() {
        _isSending = false;
      });

      // Show testing help banner
      Future.delayed(const Duration(milliseconds: 500), () {
        Get.snackbar(
          'Security Verification',
          'Verification code generated (Demo): $code',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 8),
          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
          colorText: Colors.white,
          mainButton: TextButton(
            onPressed: () {
              // Auto fill for convenience
              for (int i = 0; i < 6; i++) {
                _controllers[i].text = code[i];
              }
              Get.back();
            },
            child: const Text('AUTO FILL', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        );
      });
    } catch (e) {
      setState(() {
        _isSending = false;
      });
      ToastService.show(
        title: 'Error',
        message: 'Failed to generate 2FA code: $e',
        type: ToastType.error,
      );
    }
  }

  Future<void> _verifyCode() async {
    final codeEntered = _controllers.map((c) => c.text.trim()).join();
    if (codeEntered.length < 6) {
      ToastService.show(
        title: 'Validation',
        message: 'Please enter all 6 digits',
        type: ToastType.warning,
      );
      return;
    }

    final uid = _authService.currentUser?.uid;
    if (uid == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot = await FirebaseDatabase.instance.ref('users').child(uid).child('twoFactorCode').get();
      final correctCode = snapshot.value?.toString() ?? '';

      if (codeEntered == correctCode && correctCode.isNotEmpty) {
        // Clear code from DB
        await FirebaseDatabase.instance.ref('users').child(uid).update({
          'twoFactorCode': null,
        });

        // Set session verified flag
        _storage.write('2fa_verified_$uid', true);

        ToastService.show(
          title: 'Success',
          message: '2FA Verification Successful',
          type: ToastType.success,
        );

        Get.offAllNamed(AppRoutes.home);
      } else {
        setState(() {
          _isLoading = false;
        });
        ToastService.show(
          title: 'Verification Failed',
          message: 'The code you entered is incorrect. Please try again.',
          type: ToastType.error,
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ToastService.show(
        title: 'Error',
        message: 'Failed to verify: $e',
        type: ToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('2FA Verification', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () async {
            await _authService.signOut();
            Get.offAllNamed(AppRoutes.login);
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    color: AppColors.primary,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                // Heading
                Text(
                  'Two-Factor Authentication',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.foregroundLight,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Please enter the 6-digit code sent to your email to authorize access to your account.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  ),
                ),
                const SizedBox(height: 36),
                // Digit Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 50,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            if (index < 5) {
                              _focusNodes[index + 1].requestFocus();
                            } else {
                              _focusNodes[index].unfocus();
                            }
                          } else {
                            if (index > 0) {
                              _focusNodes[index - 1].requestFocus();
                            }
                          }
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 32),
                // Verify button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 4,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Verify Code',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                // Resend action
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive the code? ",
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      ),
                    ),
                    GestureDetector(
                      onTap: _isSending ? null : _generateAndSendCode,
                      child: Text(
                        _isSending ? 'Sending...' : 'Resend Code',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
