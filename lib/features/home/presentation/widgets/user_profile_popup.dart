import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import 'package:extrememedicaluserapp/core/utils/responsive_layout.dart';

class UserProfilePopup extends StatelessWidget {
  const UserProfilePopup({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Barrier for closing on outside tap
        Positioned.fill(
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              color: Colors.black.withOpacity(0.4),
            ),
          ),
        ),
        
        // Popup Content
        Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: context.responsive(MediaQuery.of(context).size.width * 0.9, tablet: 400, desktop: 400),
              constraints: const BoxConstraints(maxHeight: 700),
              margin: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161531) : Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Section (Profile Info)
                  _buildHeader(isDark),
                  
                  Divider(
                    height: 1, 
                    thickness: 1, 
                    color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)
                  ),
                  
                  // Menu Items
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        children: [
                          _buildMenuItem(Icons.person_outline_rounded, 'View Profile', isDark),
                          _buildMenuItem(Icons.settings_outlined, 'Account Settings', isDark),
                          _buildMenuItem(Icons.layers_outlined, 'My Devices', isDark),
                          _buildMenuItem(Icons.notifications_none_rounded, 'Notifications', isDark, hasUpdate: true),
                          _buildMenuItem(Icons.security_outlined, 'Security', isDark),
                          _buildMenuItem(Icons.credit_card_outlined, 'Billing & Subscription', isDark),
                          _buildMenuItem(Icons.help_outline_rounded, 'Help Center', isDark),
                        ],
                      ),
                    ),
                  ),
                  
                  // Sign Out Section
                  _buildSignOutButton(isDark),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Avatar with Glow
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'AH',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Name & Email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ahmed Hassan',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black, 
                        fontSize: 20, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Icon(
                        Icons.close_rounded, 
                        color: isDark ? Colors.white.withOpacity(0.3) : Colors.black26, 
                        size: 20
                      ),
                    ),
                  ],
                ),
                Text(
                  'ahmed@clinic.com',
                  style: TextStyle(
                    color: isDark ? Colors.white.withOpacity(0.4) : Colors.black45, 
                    fontSize: 14
                  ),
                ),
                const SizedBox(height: 10),
                // Premium Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.greenAccent.withOpacity(0.2)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(backgroundColor: Colors.greenAccent, radius: 3),
                      SizedBox(width: 6),
                      Text(
                        'Premium Active',
                        style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, bool isDark, {bool hasUpdate = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1C44) : Colors.indigo.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon, 
                  color: isDark ? Colors.white70 : const Color(0xFF6366F1), 
                  size: 20
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (hasUpdate)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Colors.orangeAccent, shape: BoxShape.circle),
                ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded, 
                color: isDark ? Colors.white.withOpacity(0.2) : Colors.black12, 
                size: 14
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignOutButton(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.redAccent.withOpacity(0.1)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
              SizedBox(width: 12),
              Text(
                'Sign Out',
                style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
