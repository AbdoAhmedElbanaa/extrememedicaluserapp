import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';

import 'package:firebase_database/firebase_database.dart';

class LegalDocumentView extends StatefulWidget {
  final String title;
  final bool isPrivacy;

  const LegalDocumentView({
    super.key,
    required this.title,
    required this.isPrivacy,
  });

  @override
  State<LegalDocumentView> createState() => _LegalDocumentViewState();
}

class _LegalDocumentViewState extends State<LegalDocumentView> {
  final _database = FirebaseDatabase.instance.ref();
  String _content = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      final path = widget.isPrivacy ? 'app_settings/privacy_policy' : 'app_settings/terms_of_service';
      final snapshot = await _database.child(path).get();
      if (snapshot.exists && snapshot.value != null) {
        setState(() {
          _content = snapshot.value.toString();
          _isLoading = false;
        });
      } else {
        setState(() {
          _content = widget.isPrivacy ? _getDefaultPrivacy() : _getDefaultTerms();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _content = widget.isPrivacy ? _getDefaultPrivacy() : _getDefaultTerms();
        _isLoading = false;
      });
    }
  }

  String _getDefaultPrivacy() {
    return '1. Information Collection\nWe collect information directly from your telemetry device, profile configuration, and support requests to provide and improve the service. This includes hardware serial numbers, diagnostic metrics, email, and phone numbers.\n\n'
        '2. Telemetry and Diagnostic Metrics\nAll biological metrics and hardware state indicators streamed from the device to Firebase are encrypted and processed securely. We utilize this information to map diagnostics and sync profiles.\n\n'
        '3. Sharing Your Information\nWe do not sell or trade your personal information. Information may be shared with our administrative team for the sole purpose of support ticketing and telemetry configuration.';
  }

  String _getDefaultTerms() {
    return '1. Acceptable Use\nYou agree to use this application and the linked hardware device strictly for diagnostic telemetry monitoring. Unauthorized reverse engineering of hardware signaling or data interception is strictly prohibited.\n\n'
        '2. Profile Integrity\nYou are responsible for ensuring that all clinic credentials, email configurations, and linked hardware devices are registered with accurate details. Falsifying records may result in account termination.\n\n'
        '3. Warranty and Support limits\nTechnical support tickets submitted are resolved according to priority categories. Warranties for hardware devices expire as configured in the profile settings, and no extensions are implied.';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          widget.title.tr,
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
            Text(
              widget.title.tr,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.foregroundLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last Updated: June 24, 2026',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
            ),
            const Divider(height: 32, thickness: 1),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              Text(
                _content,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
