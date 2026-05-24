import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:google_sign_in_web/google_sign_in_web.dart' as web;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final RxBool isGoogleInitialized = false.obs;

  // Web Client ID from your configuration
  static const String _webClientId = '2089029110-enrib5ifja2mfh5eqvfuss290g4u66hi.apps.googleusercontent.com';

  @override
  void onInit() {
    super.onInit();
    _initializeGoogleSignIn();
  }

  Future<void> _initializeGoogleSignIn() async {
    if (isGoogleInitialized.value) return;
    try {
      debugPrint('Initializing Google Sign In for Web...');
      
      // We provide both clientId and serverClientId for maximum compatibility on Web
      await _googleSignIn.initialize(
        clientId: _webClientId,
        serverClientId: _webClientId,
      );
      
      debugPrint('Google Sign In successfully initialized');
      isGoogleInitialized.value = true;
    } catch (e) {
      if (e.toString().contains('already been called')) {
        isGoogleInitialized.value = true;
      } else {
        debugPrint('Google Sign In initialization error: $e');
        // Force true to allow the button to attempt rendering
        isGoogleInitialized.value = true;
      }
    }
  }

  // Improved method for Web rendering with fixed constraints
  Widget buildGoogleSignInButton() {
    if (!kIsWeb) return const SizedBox.shrink();
    
    return Obx(() {
      if (!isGoogleInitialized.value) {
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
    });
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Ensure initialized (v7.2.0 requirement)
      await _initializeGoogleSignIn();

      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) return null;

      final googleAuth = googleUser.authentication;
      
      // For v7.2.0+, we need to request the accessToken separately via authorizationClient
      final authorization = await googleUser.authorizationClient.authorizeScopes([
        'email',
        'profile',
        'openid',
      ]);

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: authorization.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      debugPrint('Google Sign In Error Details: $e');
      if (e.toString().contains('already been called')) {
        // Retry without initialization if it's already done
        isGoogleInitialized.value = true;
        return signInWithGoogle();
      }
      throw 'Google login failed: ${e.toString()}';
    }
  }

  // Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Phone Authentication
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  Future<UserCredential> signInWithPhoneNumber(String verificationId, String smsCode) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Password reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'user-disabled':
        return 'This user has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'operation-not-allowed':
        return 'Operation not allowed.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }
}
