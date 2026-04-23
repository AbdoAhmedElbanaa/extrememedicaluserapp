import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<LoginController>()) {
      Get.put(LoginController());
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.5),
            radius: 1.2,
            colors: isDark
                ? [AppColors.indigoDeep.withValues(alpha: 0.8), AppColors.backgroundDark]
                : [AppColors.splashGradientLight[1], AppColors.backgroundLight],
          ),
        ),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildTopIcons(isDark),
                  const SizedBox(height: 30),
                  
                  // Logo
                  _buildLogo(isDark),
                  
                  const SizedBox(height: 30),
                  
                  // Welcome Text
                  Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.foregroundDark : AppColors.foregroundLight,
                      letterSpacing: 1,
                    ),
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Sign in to your UserManual account',
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: 40),
                  
                  // Login Form Card
                  _buildLoginForm(isDark),
                  
                  const SizedBox(height: 24),
                  
                  // Main Sign In Button
                  _buildSignInButton(),
                  
                  const SizedBox(height: 30),
                  
                  // OR Separator
                  _buildSeparator(isDark),
                  
                  const SizedBox(height: 30),
                  
                  // Social Login Buttons
                  _buildSocialLogins(isDark),
                  
                  const SizedBox(height: 50),
                  
                  // Bottom Link
                  _buildBottomLink(isDark),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopIcons(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSmallIconBox(Icons.bolt_rounded, isDark),
        _buildSmallIconBox(Icons.battery_std_rounded, isDark),
      ],
    ).animate().fadeIn(duration: 800.ms);
  }

  Widget _buildSmallIconBox(IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1C44).withValues(alpha: 0.5) : AppColors.mutedLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF323066) : AppColors.borderLight),
      ),
      child: Icon(icon, color: AppColors.primary, size: 20),
    );
  }

  Widget _buildLogo(bool isDark) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 25,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'UM',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack);
  }

  Widget _buildLoginForm(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark.withValues(alpha: 0.6) : AppColors.cardLight,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? const Color(0xFF1E1D3A) : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          _buildTextField(
            controller: controller.emailController,
            hint: 'Email or Phone',
            icon: Icons.email_outlined,
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: controller.passwordController,
            hint: 'Password',
            icon: Icons.lock_outline_rounded,
            isDark: isDark,
            isPassword: true,
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Forgot Password?',
              style: TextStyle(
                color: AppColors.primary.withValues(alpha: 0.8),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    bool isPassword = false,
  }) {
    if (isPassword) {
      return Obx(() => TextField(
        controller: controller,
        obscureText: !this.controller.isPasswordVisible.value,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              color: isDark
                  ? AppColors.textMutedDark.withValues(alpha: 0.5)
                  : AppColors.textMutedLight.withValues(alpha: 0.5)),
          prefixIcon: Icon(icon,
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              size: 20),
          suffixIcon: IconButton(
            icon: Icon(
              this.controller.isPasswordVisible.value
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              size: 20,
            ),
            onPressed: this.controller.togglePasswordVisibility,
          ),
          filled: true,
          fillColor: isDark
              ? const Color(0xFF161531).withValues(alpha: 0.5)
              : AppColors.inputBackgroundLight,
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      ));
    }
    return TextField(
      controller: controller,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
            color: isDark
                ? AppColors.textMutedDark.withValues(alpha: 0.5)
                : AppColors.textMutedLight.withValues(alpha: 0.5)),
        prefixIcon: Icon(icon,
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            size: 20),
        filled: true,
        fillColor: isDark
            ? const Color(0xFF161531).withValues(alpha: 0.5)
            : AppColors.inputBackgroundLight,
        contentPadding: const EdgeInsets.symmetric(vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return Container(
      width: double.infinity,
      height: 65,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: controller.login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        ),
        child: Obx(() => controller.isLoading.value 
          ? const CircularProgressIndicator(color: Colors.white)
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Sign In',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white),
              ],
            ),
        ),
      ),
    ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildSeparator(bool isDark) {
    return Row(
      children: [
        Expanded(child: Divider(color: isDark ? Colors.white10 : Colors.black12)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(
              color: isDark ? AppColors.textMutedDark.withValues(alpha: 0.5) : AppColors.textMutedLight.withValues(alpha: 0.5),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(child: Divider(color: isDark ? Colors.white10 : Colors.black12)),
      ],
    );
  }

  Widget _buildSocialLogins(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSocialButton('G Google', isDark),
        _buildSocialButton('🍎 Apple', isDark),
        _buildSocialButton('📱 Phone', isDark),
      ],
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildSocialButton(String label, bool isDark) {
    return Container(
      width: Get.width * 0.28,
      height: 55,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF1E1D3A) : AppColors.borderLight),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomLink(bool isDark) {
    return GestureDetector(
      onTap: () => Get.toNamed('/register'),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Don't have an account? ",
            style: TextStyle(color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
          ),
          Text(
            "Create Account",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms);
  }
}
