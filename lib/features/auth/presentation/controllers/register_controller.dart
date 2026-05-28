import 'package:extrememedicaluserapp/features/auth/data/user_repository.dart';
import 'package:extrememedicaluserapp/features/auth/data/models/user_model.dart';
import 'package:extrememedicaluserapp/features/auth/services/auth_service.dart';
import 'package:extrememedicaluserapp/core/services/toast_service.dart';
import 'package:extrememedicaluserapp/core/routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class RegisterController extends GetxController {
  // Navigation State
  var currentStep = 1.obs;
  var isForward = true.obs;
  final int totalSteps = 4;
  
  final _authService = Get.find<AuthService>();
  var isLoading = false.obs;
  String? _verificationId;

  // Step 1: Clinic Information Controllers
  final clinicNameController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final clinicAddressController = TextEditingController();

  // Step 2: Phone Controllers
  final phoneController = TextEditingController();
  var selectedCountryCode = '+20'.obs;
  var selectedCountryName = 'EG'.obs;

  // Step 3: OTP Controllers
  final otpController = TextEditingController();
  var timerSeconds = 30.obs;
  var canResend = false.obs;
  Worker? _timerWorker;

  void startTimer() {
    canResend.value = false;
    timerSeconds.value = 30;
    
    // Using a simpler approach for the timer to avoid potential issues
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (timerSeconds.value > 0) {
        timerSeconds.value--;
        return true;
      } else {
        canResend.value = true;
        return false;
      }
    });
  }

  String get formattedTimer {
    int minutes = timerSeconds.value ~/ 60;
    int seconds = timerSeconds.value % 60;
    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }

  // Step 4: Device Controllers
  final serialNumberController = TextEditingController();
  final deviceModelController = TextEditingController();
  final deviceNameController = TextEditingController();
  final additionalInfoController = TextEditingController();

  // Map State
  GoogleMapController? mapController;
  final Rx<LatLng> selectedLocation = const LatLng(30.0444, 31.2357).obs; // Default: Cairo
  final RxSet<Marker> markers = <Marker>{}.obs;
  var isMapLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _updateMarker(selectedLocation.value);
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void onCameraMove(CameraPosition position) {
    selectedLocation.value = position.target;
    _updateMarker(position.target);
  }

  void onCameraIdle() {
    _getAddressFromLatLng(selectedLocation.value);
  }

  void _updateMarker(LatLng position) {
    markers.clear();
    markers.add(
      Marker(
        markerId: const MarkerId('selected_location'),
        position: position,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      ),
    );
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = "${place.street}, ${place.locality}, ${place.country}";
        clinicAddressController.text = address;
      }
    } catch (e) {
      debugPrint("Error getting address: $e");
    }
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    isMapLoading.value = true;
    Position position = await Geolocator.getCurrentPosition();
    LatLng currentLatLng = LatLng(position.latitude, position.longitude);
    
    selectedLocation.value = currentLatLng;
    _updateMarker(currentLatLng);
    
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: currentLatLng, zoom: 15),
      ),
    );
    
    await _getAddressFromLatLng(currentLatLng);
    isMapLoading.value = false;
  }

  void nextStep() async {
    if (isLoading.value) return;

    if (currentStep.value == 1) {
      if (clinicNameController.text.isEmpty || firstNameController.text.isEmpty) {
        ToastService.show(title: 'Error', message: 'Please fill clinic info', type: ToastType.error);
        return;
      }
      isForward.value = true;
      currentStep.value++;
    } else if (currentStep.value == 2) {
      await _sendOtp();
    } else if (currentStep.value == 3) {
      await _verifyOtp();
    } else if (currentStep.value < totalSteps) {
      isForward.value = true;
      currentStep.value++;
    } else {
      register();
    }
  }

  Future<void> _sendOtp() async {
    if (phoneController.text.isEmpty) {
      ToastService.show(title: 'Error', message: 'Please enter phone number', type: ToastType.error);
      return;
    }

    isLoading.value = true;
    try {
      String phoneNumber = selectedCountryCode.value + phoneController.text.trim();
      await _authService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // This can happen on some Android devices with auto-retrieval
          await FirebaseAuth.instance.signInWithCredential(credential);
          isForward.value = true;
          currentStep.value = 4; // Skip OTP step if auto-verified
          ToastService.show(title: 'Verified', message: 'Phone number auto-verified', type: ToastType.success);
        },
        verificationFailed: (FirebaseAuthException e) {
          ToastService.show(title: 'Error', message: e.message ?? 'Verification failed', type: ToastType.error);
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          isForward.value = true;
          currentStep.value++;
          startTimer();
          ToastService.show(title: 'OTP Sent', message: 'Please check your messages', type: ToastType.success);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      ToastService.show(title: 'Error', message: e.toString(), type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _verifyOtp() async {
    if (otpController.text.length < 6) {
      ToastService.show(title: 'Error', message: 'Please enter valid OTP', type: ToastType.error);
      return;
    }

    if (_verificationId == null) {
      ToastService.show(title: 'Error', message: 'Verification ID missing. Please resend OTP.', type: ToastType.error);
      return;
    }

    isLoading.value = true;
    try {
      await _authService.signInWithPhoneNumber(_verificationId!, otpController.text.trim());
      isForward.value = true;
      currentStep.value++;
      ToastService.show(title: 'Success', message: 'Phone verified successfully', type: ToastType.success);
    } catch (e) {
      ToastService.show(title: 'Error', message: e.toString(), type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }

  void previousStep() {
    if (currentStep.value > 1) {
      isForward.value = false;
      currentStep.value--;
    } else {
      Get.back();
    }
  }

  void register() async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      User? currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw 'User not authenticated';
      }

      UserModel userModel = UserModel(
        uid: currentUser.uid,
        phoneNumber: currentUser.phoneNumber,
        clinicName: clinicNameController.text.trim(),
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        address: clinicAddressController.text.trim(),
        latitude: selectedLocation.value.latitude,
        longitude: selectedLocation.value.longitude,
      );

      await Get.find<UserRepository>().createUser(userModel);
      _authService.currentUserModel.value = userModel;

      ToastService.show(
        title: 'Success',
        message: 'Account created successfully ✨',
        type: ToastType.success,
      );

      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      ToastService.show(
        title: 'Error',
        message: e.toString(),
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    clinicNameController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    clinicAddressController.dispose();
    phoneController.dispose();
    otpController.dispose();
    serialNumberController.dispose();
    deviceModelController.dispose();
    deviceNameController.dispose();
    additionalInfoController.dispose();
    _timerWorker?.dispose();
    super.onClose();
  }
}
