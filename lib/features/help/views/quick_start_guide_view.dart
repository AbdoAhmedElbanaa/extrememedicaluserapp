import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';

class QuickStartGuideView extends StatefulWidget {
  const QuickStartGuideView({super.key});

  @override
  State<QuickStartGuideView> createState() => _QuickStartGuideViewState();
}

class _QuickStartGuideViewState extends State<QuickStartGuideView> {
  int _activeStep = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final steps = [
      {
        'title': 'step_1_title'.tr,
        'desc': 'step_1_desc'.tr,
        'icon': Icons.power_settings_new_rounded,
        'color': AppColors.indigoSoft,
      },
      {
        'title': 'step_2_title'.tr,
        'desc': 'step_2_desc'.tr,
        'icon': Icons.bluetooth_searching_rounded,
        'color': AppColors.blueSoft,
      },
      {
        'title': 'step_3_title'.tr,
        'desc': 'step_3_desc'.tr,
        'icon': Icons.accessibility_new_rounded,
        'color': AppColors.emeraldSoft,
      },
      {
        'title': 'step_4_title'.tr,
        'desc': 'step_4_desc'.tr,
        'icon': Icons.play_arrow_rounded,
        'color': AppColors.amberSoft,
      },
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'quick_start'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [AppColors.indigoDeep, AppColors.cinematicSurface]
                      : [AppColors.primary.withValues(alpha: 0.1), AppColors.secondary.withValues(alpha: 0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '5 MINS SETUP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'quick_start'.tr,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Learn how to properly operate and connect your medical telemetry hardware.',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Stepper progress indicator
            Row(
              children: List.generate(
                steps.length,
                (index) => Expanded(
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _activeStep = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _activeStep >= index
                                ? steps[index]['color'] as Color
                                : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
                            border: Border.all(
                              color: _activeStep == index
                                  ? AppColors.primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              _activeStep > index ? Icons.check_rounded : steps[index]['icon'] as IconData,
                              size: 16,
                              color: _activeStep >= index ? Colors.white : (isDark ? Colors.white38 : Colors.black38),
                            ),
                          ),
                        ),
                      ),
                      if (index < steps.length - 1)
                        Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 2,
                            color: _activeStep > index
                                ? steps[index]['color'] as Color
                                : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Stepper Content details
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Container(
                key: ValueKey<int>(_activeStep),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cinematicSurface.withValues(alpha: 0.4) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          steps[_activeStep]['icon'] as IconData,
                          color: steps[_activeStep]['color'] as Color,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            steps[_activeStep]['title'] as String,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      steps[_activeStep]['desc'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Anatomy Section
            Text(
              'anatomy_title'.tr,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'anatomy_desc'.tr,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
            ),
            const SizedBox(height: 24),

            // Simulated Device Layout
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cinematicSurface.withValues(alpha: 0.2) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
                ),
              ),
              child: Column(
                children: [
                  // Simulated Hardware Device
                  Container(
                    width: 140,
                    height: 220,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.indigoDeep : Colors.grey[200],
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.primary, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // OLED Status Screen representation
                        Container(
                          width: 100,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: const Center(
                            child: Icon(Icons.show_chart_rounded, color: Colors.greenAccent, size: 24),
                          ),
                        ),
                        // Power Button representation
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black,
                            border: Border.all(color: AppColors.primary, width: 2),
                          ),
                          child: const Center(
                            child: Icon(Icons.power_settings_new_rounded, color: Colors.white, size: 18),
                          ),
                        ),
                        // Status indicator LED
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Legends listing anatomy
                  _buildLegendItem('power_btn'.tr, 'Press & hold 3s to turn ON/OFF.', isDark),
                  _buildLegendItem('display_screen'.tr, 'Displays telemetry connection and pulse indicators.', isDark),
                  _buildLegendItem('sensor_strap'.tr, 'Attach metal sensors directly to clean skin.', isDark),
                  _buildLegendItem('charging_port'.tr, 'USB Type-C port located on bottom of device.', isDark, showDivider: false),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String title, String desc, bool isDark, {bool showDivider = true}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.circle, size: 8, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
          ),
      ],
    );
  }
}
