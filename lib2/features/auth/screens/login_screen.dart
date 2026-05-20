import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final AuthController authController = Get.find<AuthController>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // Part 1: Hero Section
          if (isDesktop)
            Expanded(
              flex: 5,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppColors.backgroundGradient,
                  ),
                ),
                child: Stack(
                  children: [
                    _buildHeroBlobs(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 80),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(15),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: Colors.white.withAlpha(20),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.medical_services_rounded,
                              size: 72,
                              color: AppColors.primary,
                            ),
                          ).animate().scale(
                            duration: const Duration(milliseconds: 1200),
                            curve: Curves.elasticOut,
                          ),
                          const SizedBox(height: 48),
                          const Text(
                                'Extreme Medical\nManagement.',
                                style: TextStyle(
                                  fontSize: 56,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  height: 1.05,
                                  letterSpacing: -1.5,
                                ),
                              )
                              .animate()
                              .fadeIn(delay: const Duration(milliseconds: 300))
                              .slideY(begin: 0.2),
                          const SizedBox(height: 24),
                          const Text(
                                'Control every aspect of your healthcare ecosystem with our next-gen admin portal.',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppColors.textSecondary,
                                  height: 1.6,
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                              .animate()
                              .fadeIn(delay: const Duration(milliseconds: 500))
                              .slideY(begin: 0.2),
                          const SizedBox(height: 64),
                          Row(
                            children: [
                              _buildStatItem('24/7', 'System Uptime'),
                              const SizedBox(width: 48),
                              _buildStatItem('Secure', 'Persistence'),
                            ],
                          ).animate().fadeIn(
                            delay: const Duration(milliseconds: 800),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Part 2: Login Data Section
          Expanded(
            flex: isDesktop ? 4 : 9,
            child: Container(
              height: double.infinity,
              color: AppColors.surface,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 64,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!isDesktop) ...[
                            Center(
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.medical_services_rounded,
                                    size: 64,
                                    color: AppColors.primary,
                                  ).animate().scale(),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'EXTREME MEDICAL',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 48),
                                ],
                              ),
                            ),
                          ],

                          const Text(
                            'Admin Login',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ).animate().fadeIn().slideX(begin: -0.1),
                          const SizedBox(height: 8),
                          const Text(
                                'Enter your credentials or use Google',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 16,
                                ),
                              )
                              .animate()
                              .fadeIn(delay: const Duration(milliseconds: 200))
                              .slideX(begin: -0.1),
                          const SizedBox(height: 48),

                          CustomTextField(
                                controller: emailController,
                                label: 'EMAIL ADDRESS',
                                hint: 'admin@extrememedical.com',
                                prefixIcon: Icons.email_outlined,
                                validator: (value) =>
                                    GetUtils.isEmail(value ?? '')
                                    ? null
                                    : 'Valid email required',
                              )
                              .animate()
                              .fadeIn(delay: const Duration(milliseconds: 400))
                              .slideY(begin: 0.1),
                          const SizedBox(height: 24),
                          CustomTextField(
                                controller: passwordController,
                                label: 'PASSWORD',
                                hint: '••••••••',
                                isPassword: true,
                                prefixIcon: Icons.lock_outline_rounded,
                                validator: (value) => (value?.length ?? 0) >= 6
                                    ? null
                                    : 'Min 6 characters',
                              )
                              .animate()
                              .fadeIn(delay: const Duration(milliseconds: 600))
                              .slideY(begin: 0.1),
                          const SizedBox(height: 32),

                          Obx(
                            () => CustomButton(
                              text: 'SIGN IN',
                              isLoading: authController.isLoading.value,
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  await authController.login(
                                    emailController.text.trim(),
                                    passwordController.text.trim(),
                                  );
                                }
                              },
                            ),
                          ).animate().fadeIn(
                            delay: const Duration(milliseconds: 800),
                          ),

                          const SizedBox(height: 20),

                          // Google Sign In Section
                          _buildGoogleSection().animate().fadeIn(
                            delay: const Duration(milliseconds: 900),
                          ),

                          const SizedBox(height: 40),
                          const Center(
                            child: Text(
                              'Authorized Access Only',
                              style: TextStyle(
                                color: Colors.white24,
                                fontSize: 12,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ).animate().fadeIn(
                            delay: const Duration(milliseconds: 1000),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleSection() {
    if (kIsWeb) {
      return Container(
        margin: const EdgeInsets.only(top: 10),
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: (GoogleSignInPlatform.instance as dynamic).renderButton(),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: OutlinedButton(
        onPressed: () => authController.loginWithGoogle(),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 54),
          side: const BorderSide(color: Colors.white24, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white.withAlpha(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://www.gstatic.com/images/branding/product/1x/gsa_512dp.png',
              height: 24,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.g_mobiledata_rounded,
                size: 30,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'SIGN IN WITH GOOGLE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildHeroBlobs() {
    return Stack(
      children: [
        Positioned(
              top: -150,
              left: -100,
              child: _buildBlob(AppColors.primary.withAlpha(40), 500),
            )
            .animate(onPlay: (c) => c.repeat())
            .move(
              begin: const Offset(-20, -20),
              end: const Offset(20, 20),
              duration: const Duration(seconds: 8),
              curve: Curves.easeInOut,
            ),
        Positioned(
              bottom: -150,
              right: -50,
              child: _buildBlob(AppColors.secondary.withAlpha(30), 450),
            )
            .animate(onPlay: (c) => c.repeat())
            .move(
              begin: const Offset(30, 30),
              end: const Offset(-30, -30),
              duration: const Duration(seconds: 10),
              curve: Curves.easeInOut,
            ),
      ],
    );
  }

  Widget _buildBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    ).animate().blur(
      begin: const Offset(80, 80),
      end: const Offset(120, 120),
      duration: const Duration(seconds: 3),
    );
  }
}
