// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:google_sign_in_web/google_sign_in_web.dart' as web;

Widget buildGoogleSignInButton({
  required bool isGoogleInitialized,
  required String webClientId,
}) {
  if (!isGoogleInitialized) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  return Container(
    height: 44,
    constraints: const BoxConstraints(minWidth: 220),
    child: (GoogleSignInPlatform.instance as web.GoogleSignInPlugin).renderButton(
      configuration: web.GSIButtonConfiguration(
        shape: web.GSIButtonShape.pill,
        theme: web.GSIButtonTheme.outline,
        size: web.GSIButtonSize.large,
        text: web.GSIButtonText.signinWith,
      ),
    ),
  );
}
