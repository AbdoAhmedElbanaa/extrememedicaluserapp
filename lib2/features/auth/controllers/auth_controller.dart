import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../core/theme/app_colors.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final GoogleSignIn _googleSignIn;
  
  final RxBool isLoading = false.obs;
  final Rx<User?> _firebaseUser = Rx<User?>(null);

  User? get user => _firebaseUser.value;
  bool get isLoggedIn => _firebaseUser.value != null;

  static const String webClientId = '2089029110-enrib5ifja2mfh5eqvfuss290g4u66hi.apps.googleusercontent.com';

  @override
  void onInit() {
    super.onInit();
    
    _googleSignIn = GoogleSignIn.instance;
    
    // Initialize Google Sign-In
    _initializeGoogle();

    _firebaseUser.bindStream(_auth.authStateChanges());
    
    // 7.x uses authenticationEvents instead of onCurrentUserChanged
    _googleSignIn.authenticationEvents.listen((event) {
      if (event is GoogleSignInAuthenticationEventSignIn && kIsWeb) {
        _handleGoogleAuth(event.user);
      }
    });

    ever(_firebaseUser, _handleInitialScreen);
  }

  Future<void> _initializeGoogle() async {
    try {
      await _googleSignIn.initialize(
        clientId: kIsWeb ? webClientId : null,
      );
    } catch (e) {
      debugPrint('Google Sign-In Initialization Error: $e');
    }
  }

  void _handleInitialScreen(User? user) {
    if (user == null) {
      Get.offAllNamed('/login');
    } else {
      Get.offAllNamed('/dashboard');
    }
  }

  Future<void> _handleGoogleAuth(GoogleSignInAccount googleUser) async {
    try {
      isLoading.value = true;
      
      // 1. Get Authentication (ID Token)
      // In 7.x, .authentication is synchronous on the user object
      final googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      // 2. Get Access Token (Authorization)
      // In 7.x, accessToken is moved to the authorizationClient
      final List<String> scopes = ['email', 'profile'];
      final authorization = await googleUser.authorizationClient.authorizeScopes(scopes);
      final String? accessToken = authorization.accessToken;
      
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      await _auth.signInWithCredential(credential);
      _showSuccessSnackbar('Google login successful');
    } catch (e) {
      _showErrorSnackbar('Firebase Link Error: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _showSuccessSnackbar('Logged in successfully');
      return true;
    } on FirebaseAuthException catch (e) {
      _showErrorSnackbar(e.message ?? 'Authentication failed');
      return false;
    } catch (e) {
      _showErrorSnackbar('Error: ${e.toString()}');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> loginWithGoogle() async {
    try {
      isLoading.value = true;
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();

      if (googleUser != null) {
        await _handleGoogleAuth(googleUser);
        return true;
      }
      return false;
    } catch (e) {
      _showErrorSnackbar('Google Sign-In failed: ${e.toString()}');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Notice',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.error.withAlpha(220),
      colorText: Colors.white,
      margin: const EdgeInsets.all(20),
      borderRadius: 15,
      duration: const Duration(seconds: 6),
      icon: const Icon(Icons.info_outline, color: Colors.white),
    );
  }

  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.withAlpha(220),
      colorText: Colors.white,
      margin: const EdgeInsets.all(20),
      borderRadius: 15,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      _showErrorSnackbar('Logout failed');
    }
  }
}
