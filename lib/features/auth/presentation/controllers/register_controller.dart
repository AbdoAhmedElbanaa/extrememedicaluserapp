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

  void nextStep() {
    if (currentStep.value < totalSteps) {
      isForward.value = true;
      currentStep.value++;
    } else {
      register();
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

  void register() {
    Get.snackbar(
      'Success',
      'Account created successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.7),
      colorText: Colors.white,
    );
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
