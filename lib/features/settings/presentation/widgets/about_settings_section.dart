import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import 'package:extrememedicaluserapp/core/routes/app_routes.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';
import 'settings_expandable_tile.dart';
import 'settings_sub_tile.dart';

class AboutSettingsSection extends StatefulWidget {
  const AboutSettingsSection({super.key});

  @override
  State<AboutSettingsSection> createState() => _AboutSettingsSectionState();
}

class _AboutSettingsSectionState extends State<AboutSettingsSection> {
  final _database = FirebaseDatabase.instance.ref();
  String _version = 'v2.0.0';
  String _company = 'Extreme Medical Co.';
  String _description = 'Extreme Medical Clinic Staff App provides real-time telemetry tracking, hardware integration, diagnostic analytics, and patient profiling to medical practitioners.';
  String _supportEmail = 'support@extrememedical.com';
  String _website = 'https://extrememedical.com';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAboutInfo();
  }

  Future<void> _loadAboutInfo() async {
    try {
      final snapshot = await _database.child('app_settings/about_info').get();
      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          _version = data['version'] ?? 'v2.0.0';
          _company = data['company'] ?? 'Extreme Medical Co.';
          _description = data['description'] ?? 'Extreme Medical Clinic Staff App provides real-time telemetry tracking, hardware integration, diagnostic analytics, and patient profiling to medical practitioners.';
          _supportEmail = data['support_email'] ?? 'support@extrememedical.com';
          _website = data['website'] ?? 'https://extrememedical.com';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _launchURL(String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error'.tr,
          'Could not open: $urlString',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Could not launch URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SettingsExpandableTile(
      icon: Icons.info_outline_rounded,
      iconColor: AppColors.blueSoft,
      title: 'About',
      canExpand: isMobile,
      initiallyExpanded: !isMobile,
      showHeader: isMobile,
      children: [
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          )
        else ...[
          SettingsSubTile(
            icon: Icons.info_outline_rounded,
            iconColor: AppColors.blueSoft,
            title: 'App Version',
            subtitle: _version,
            trailing: _buildBadge('Latest', Colors.greenAccent, isDark),
          ),
          SettingsSubTile(
            icon: Icons.business_rounded,
            iconColor: AppColors.indigoSoft,
            title: 'Developer',
            subtitle: _company,
            onTap: () => _launchURL(_website),
          ),
          SettingsSubTile(
            icon: Icons.help_outline_rounded,
            iconColor: AppColors.emeraldSoft,
            title: 'About App',
            subtitle: _description,
          ),
          SettingsSubTile(
            icon: Icons.alternate_email_rounded,
            iconColor: AppColors.purpleSoft,
            title: 'Support Contact',
            subtitle: _supportEmail,
            onTap: () => _launchURL('mailto:$_supportEmail'),
          ),
          SettingsSubTile(
            icon: Icons.language_rounded,
            iconColor: AppColors.blueSoft,
            title: 'Website',
            subtitle: _website,
            onTap: () => _launchURL(_website),
          ),
          SettingsSubTile(
            icon: Icons.privacy_tip_outlined,
            iconColor: AppColors.purpleSoft,
            title: 'Privacy Policy',
            onTap: () => Get.toNamed(AppRoutes.privacyPolicy),
          ),
          SettingsSubTile(
            icon: Icons.description_outlined,
            iconColor: AppColors.indigoSoft,
            title: 'Terms of Service',
            onTap: () => Get.toNamed(AppRoutes.termsOfService),
          ),
          SettingsSubTile(
            icon: Icons.code_rounded,
            iconColor: AppColors.blueSoft,
            title: 'Open Source Licenses',
            showDivider: false,
            onTap: () {},
          ),
        ],
      ],
    );
  }

  Widget _buildBadge(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

