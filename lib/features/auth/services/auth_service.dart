import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/features/auth/data/models/user_model.dart';
import 'package:extrememedicaluserapp/features/auth/data/user_repository.dart';
import 'google_sign_in_button.dart' as google_btn;

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final RxBool isGoogleInitialized = false.obs;
  final Rxn<UserModel> currentUserModel = Rxn<UserModel>();

  // Web Client ID from your configuration
  static const String _webClientId = '2089029110-enrib5ifja2mfh5eqvfuss290g4u66hi.apps.googleusercontent.com';

  @override
  void onInit() {
    super.onInit();
    _initializeGoogleSignIn();
    
    // Listen to auth state changes to load/clear user model
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        await loadUserModel(user.uid);
      } else {
        currentUserModel.value = null;
      }
    });
  }

  Future<void> loadUserModel(String uid) async {
    try {
      final userRepo = Get.find<UserRepository>();
      final model = await userRepo.getUser(uid);
      currentUserModel.value = model;
      debugPrint('Loaded user model: ${currentUserModel.value?.firstName} ${currentUserModel.value?.lastName}');
    } catch (e) {
      debugPrint('Error loading user model: $e');
    }
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
    return Obx(() => google_btn.buildGoogleSignInButton(
      isGoogleInitialized: isGoogleInitialized.value,
      webClientId: _webClientId,
    ));
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
