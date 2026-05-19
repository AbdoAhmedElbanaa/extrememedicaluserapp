import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/devices_controller.dart';

class DevicesHeader extends GetView<DevicesController> {
  const DevicesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;
    
    final textColor = isDark ? Colors.white : Colors.black;
    final mutedTextColor = isDark ? const Color(0xFF8E8EA9) : Colors.black54;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.fromLTRB(20, topPadding + 10, 20, 15),
          decoration: BoxDecoration(
            color: isDark 
                ? const Color(0xFF04030D).withOpacity(0.7) 
                : Colors.white.withOpacity(0.8),
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row: Title and Top Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Devices',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Obx(() => Text(
                        '${controller.onlineCount} online · ${controller.warningCount} need attention',
                        style: TextStyle(
                          fontSize: 15,
                          color: mutedTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      )),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => controller.onRefresh(),
                    child: const _HeaderCircularButton(icon: Icons.refresh_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              
              // Search Bar
              Container(
                height: 58,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF13122B).withOpacity(0.5) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
                  ),
                ),
                child: TextField(
                  onChanged: controller.setSearchQuery,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Search devices or SN...',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white30 : Colors.black38,
                      fontSize: 16,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Icon(
                        Icons.search_rounded,
                        color: isDark ? Colors.white30 : Colors.black38,
                        size: 26,
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _CustomFilterChip(label: 'All', count: controller.getCount('All')),
                    const SizedBox(width: 10),
                    _CustomFilterChip(label: 'Online', count: controller.getCount('Online')),
                    const SizedBox(width: 10),
                    _CustomFilterChip(label: 'Warning', count: controller.getCount('Warning')),
                    const SizedBox(width: 10),
                    _CustomFilterChip(label: 'Offline', count: controller.getCount('Offline')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCircularButton extends StatelessWidget {
  final IconData icon;
  const _HeaderCircularButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF13122B).withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.1),
        ),
      ),
      child: Icon(
        icon,
        size: 22,
        color: isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7),
      ),
    );
  }
}

class _CustomFilterChip extends GetView<DevicesController> {
  final String label;
  final int count;

  const _CustomFilterChip({
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Obx(() {
      final isSelected = controller.selectedFilter.value == label;
      final activeColor = const Color(0xFF6366F1);
      final activeBg = isDark ? const Color(0xFF1A1A3F) : activeColor.withOpacity(0.1);
      
      return GestureDetector(
        onTap: () => controller.applyFilter(label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          decoration: BoxDecoration(
            color: isSelected ? activeBg : (isDark ? Colors.white.withOpacity(0.03) : Colors.transparent),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isSelected 
                ? activeColor.withOpacity(0.5) 
                : (isDark ? Colors.white.withOpacity(0.05) : Colors.black12),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected 
                    ? (isDark ? const Color(0xFF818CF8) : activeColor) 
                    : (isDark ? Colors.white54 : Colors.black54),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected 
                    ? (isDark ? const Color(0xFF04030D).withOpacity(0.5) : activeColor.withOpacity(0.2))
                    : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: isSelected 
                      ? (isDark ? const Color(0xFF818CF8) : activeColor) 
                      : (isDark ? Colors.white38 : Colors.black38),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
