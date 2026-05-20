import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import 'package:extrememedicaluserapp/core/utils/responsive_layout.dart';
import 'package:extrememedicaluserapp/core/routes/app_routes.dart';
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
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors
          .backgroundLight,
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(context, isDark),
        tablet: _buildMobileLayout(context, isDark, isTablet: true),
        desktop: _buildDesktopLayout(context, isDark),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, bool isDark,
      {bool isTablet = false}) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.5),
          radius: 1.2,
          colors: isDark
              ? [
            AppColors.indigoDeep.withValues(alpha: 0.8),
            AppColors.backgroundDark
          ]
              : [AppColors.splashGradientLight[1], AppColors.backgroundLight],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: SafeArea(
            child: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: isTablet ? 550 : 500),
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsive(24, tablet: 40, desktop: 60),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildLoginContent(context, isDark),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, bool isDark) {
    return Row(
      children: [
        // Left Side: Hero Section
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.purpleDeep],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -100,
                  right: -100,
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(60.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLogo(false, isLarge: true),
                        const SizedBox(height: 40),
                        const Text(
                          'Advanced Medical Management',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                        ).animate().fadeIn(duration: 800.ms).slideY(
                            begin: 0.2, end: 0),
                        const SizedBox(height: 24),
                        Text(
                          'Experience the future of clinical documentation and device management with our all-in-one solution.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 18,
                            height: 1.6,
                          ),
                        ).animate().fadeIn(delay: 300.ms).slideY(
                            begin: 0.2, end: 0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Right Side: Login Form
        Expanded(
          flex: 1,
          child: Container(
            color: isDark ? AppColors.backgroundDark : AppColors
                .backgroundLight,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(60),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildLoginContent(context, isDark),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildLoginContent(BuildContext context, bool isDark) {
    final isDesktop = context.isDesktopLayout;

    return [
      if (!isDesktop) ...[
        const SizedBox(height: 20),
        _buildTopIcons(isDark, context),
        const SizedBox(height: 30),
        _buildLogo(isDark),
        const SizedBox(height: 30),
      ],

      // Welcome Text
      Text(
        'Welcome Back',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: context.responsive(32, tablet: 40, desktop: 44),
          fontWeight: FontWeight.w900,
          color: isDark ? AppColors.foregroundDark : AppColors.foregroundLight,
          letterSpacing: 1,
        ),
      ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),

      const SizedBox(height: 8),

      Text(
        'Sign in to your UserManual account',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: context.responsive(15, tablet: 18, desktop: 16),
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
      _buildSocialLogins(isDark, context),

      const SizedBox(height: 50),

      // Bottom Link
      _buildBottomLink(isDark),

      const SizedBox(height: 20),
    ];
  }

  Widget _buildLogo(bool isDark, {bool isLarge = false}) {
    final size = isLarge ? 120.0 : 80.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isLarge ? Colors.white : AppColors.primary,
        borderRadius: BorderRadius.circular(isLarge ? 32 : 24),
        boxShadow: [
          BoxShadow(
            color: (isLarge ? Colors.black : AppColors.primary).withValues(
                alpha: 0.3),
            blurRadius: 25,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          'UM',
          style: TextStyle(
            color: isLarge ? AppColors.primary : Colors.white,
            fontSize: isLarge ? 42 : 28,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack);
  }

  Widget _buildTopIcons(bool isDark, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSmallIconBox(Icons.bolt_rounded, isDark),
          _buildSmallIconBox(Icons.battery_std_rounded, isDark),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms);
  }

  Widget _buildSmallIconBox(IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.deepNavy.withValues(alpha: 0.5) : AppColors
            .mutedLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? AppColors.deepNavyBorder : AppColors.borderLight),
      ),
      child: Icon(icon, color: AppColors.primary, size: 20),
    );
  }

  Widget _buildLoginForm(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark.withValues(alpha: 0.6) : AppColors
            .cardLight,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? AppColors.deepNavyDarker : AppColors.borderLight,
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
    return TextField(
      controller: controller,
      obscureText: isPassword && !this.controller.isPasswordVisible.value,
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
        suffixIcon: isPassword ? Obx(() =>
            IconButton(
              icon: Icon(
                this.controller.isPasswordVisible.value
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: isDark ? AppColors.textMutedDark : AppColors
                    .textMutedLight,
                size: 20,
              ),
              onPressed: this.controller.togglePasswordVisibility,
            )) : null,
        filled: true,
        fillColor: isDark
            ? AppColors.cinematicSurface.withValues(alpha: 0.5)
            : AppColors.inputBackgroundLight,
        contentPadding: const EdgeInsets.symmetric(
            vertical: 20, horizontal: 16),
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
          colors: [AppColors.primary, AppColors.purpleDeep],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
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
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22)),
        ),
        child: Obx(() =>
        controller.isLoading.value
            ? const CircularProgressIndicator(color: Colors.white)
            : const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Sign In',
              style: TextStyle(fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            SizedBox(width: 8),
            Icon(
                Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white),
          ],
        ),
        ),
      ),
    ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildSeparator(bool isDark) {
    return Row(
      children: [
        Expanded(
            child: Divider(color: isDark ? Colors.white10 : Colors.black12)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(
              color: isDark
                  ? AppColors.textMutedDark.withValues(alpha: 0.5)
                  : AppColors.textMutedLight.withValues(alpha: 0.5),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
            child: Divider(color: isDark ? Colors.white10 : Colors.black12)),
      ],
    );
  }

  Widget _buildSocialLogins(bool isDark, BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildSocialButton('G Google', isDark, context),
        _buildSocialButton('🍎 Apple', isDark, context),
        _buildSocialButton('📱 Phone', isDark, context),
      ],
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildSocialButton(String label, bool isDark, BuildContext context) {
    // Dynamic width based on screen size but with limits
    double buttonWidth = (context.screenWidth - 72) / 3;
    if (buttonWidth < 100) buttonWidth = 100;

    return Container(
      width: context.isMobileLayout ? buttonWidth : 140,
      height: 55,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? AppColors.deepNavyDarker : AppColors.borderLight),
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
      onTap: () => Get.toNamed(AppRoutes.register),
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          Text(
            "Don't have an account? ",
            style: TextStyle(color: isDark ? AppColors.textMutedDark : AppColors
                .textMutedLight),
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
