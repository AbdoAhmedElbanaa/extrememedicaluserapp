import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import 'package:extrememedicaluserapp/features/auth/services/auth_service.dart';
import 'package:extrememedicaluserapp/features/auth/data/models/user_model.dart';
import 'package:extrememedicaluserapp/core/services/toast_service.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _authService = Get.find<AuthService>();
  final _database = FirebaseDatabase.instance.ref();
  
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _clinicController = TextEditingController();
  final _locationController = TextEditingController();
  final _deviceController = TextEditingController();

  final List<String> _avatars = [
    'https://raw.githubusercontent.com/Ashwinvalento/cartoon-avatar/master/lib/images/male/45.png',
    'https://raw.githubusercontent.com/Ashwinvalento/cartoon-avatar/master/lib/images/female/45.png',
    'https://raw.githubusercontent.com/Ashwinvalento/cartoon-avatar/master/lib/images/male/8.png',
    'https://raw.githubusercontent.com/Ashwinvalento/cartoon-avatar/master/lib/images/female/8.png',
    'https://raw.githubusercontent.com/Ashwinvalento/cartoon-avatar/master/lib/images/male/22.png',
    'https://raw.githubusercontent.com/Ashwinvalento/cartoon-avatar/master/lib/images/female/22.png',
  ];

  String _selectedAvatar = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = _authService.currentUserModel.value;
    if (user != null) {
      _firstNameController.text = user.firstName ?? '';
      _lastNameController.text = user.lastName ?? '';
      _phoneController.text = user.phoneNumber ?? '';
      _selectedAvatar = user.photoUrl ?? '';
      _emailController.text = user.email ?? 'N/A';
      _clinicController.text = user.clinicName ?? 'N/A';
      _locationController.text = (user.latitude != null && user.longitude != null)
          ? '${user.latitude!.toStringAsFixed(5)}, ${user.longitude!.toStringAsFixed(5)}'
          : (user.address ?? 'N/A');
      _deviceController.text = user.device?.serialNo ?? 'No Device Configured';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _clinicController.dispose();
    _locationController.dispose();
    _deviceController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_firstNameController.text.trim().isEmpty || _lastNameController.text.trim().isEmpty) {
      ToastService.show(
        title: 'Validation',
        message: 'First Name and Last Name cannot be empty',
        type: ToastType.warning,
      );
      return;
    }

    final uid = _authService.currentUser?.uid;
    if (uid == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Update values in Realtime Database under users/uid
      await _database.child('users').child(uid).update({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'photoUrl': _selectedAvatar,
      });

      // Reload user model in auth service to sync state
      await _authService.loadUserModel(uid);

      ToastService.show(
        title: 'Success',
        message: 'Profile updated successfully',
        type: ToastType.success,
      );
      
      Get.back();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ToastService.show(
        title: 'Error',
        message: 'Failed to update profile: $e',
        type: ToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar Picker Section
                Text(
                  'CHOOSE PROFILE PICTURE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 90,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _avatars.length,
                    itemBuilder: (context, index) {
                      final avatar = _avatars[index];
                      final isSelected = _selectedAvatar == avatar;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedAvatar = avatar;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 14),
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AppColors.primary : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: isSelected ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 10,
                                spreadRadius: 2,
                              )
                            ] : [],
                          ),
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(avatar),
                            backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[200],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
                
                // Editable Fields
                Text(
                  'EDITABLE DETAILS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _firstNameController,
                  label: 'First Name',
                  icon: Icons.person_outline_rounded,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _lastNameController,
                  label: 'Last Name',
                  icon: Icons.person_outline_rounded,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone_android_rounded,
                  isDark: isDark,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 32),

                // Read-only fields
                Text(
                  'READONLY ACCOUNT METRICS (DISABLED)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  icon: Icons.alternate_email_rounded,
                  isDark: isDark,
                  enabled: false,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _clinicController,
                  label: 'Clinic Name',
                  icon: Icons.local_hospital_outlined,
                  isDark: isDark,
                  enabled: false,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _locationController,
                  label: 'Coordinates / Address',
                  icon: Icons.map_outlined,
                  isDark: isDark,
                  enabled: false,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _deviceController,
                  label: 'Linked Hardware Serial No',
                  icon: Icons.developer_board_rounded,
                  isDark: isDark,
                  enabled: false,
                ),
                const SizedBox(height: 40),

                // Save action
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 4,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Save Changes',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      style: TextStyle(
        color: enabled 
            ? (isDark ? Colors.white : Colors.black87)
            : (isDark ? Colors.white30 : Colors.black38),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          fontSize: 12,
        ),
        prefixIcon: Icon(icon, color: enabled ? AppColors.primary : Colors.grey, size: 20),
        filled: true,
        fillColor: enabled 
            ? (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50])
            : (isDark ? Colors.white.withValues(alpha: 0.01) : Colors.grey[200]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? Colors.transparent : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      onChanged: (_) {},
    );
  }
}
