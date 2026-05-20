import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../models/nav_item_model.dart';
import '../data/sidebar_config.dart';

class SidebarNavigation extends StatelessWidget {
  final String currentRoute;

  const SidebarNavigation({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final menuItems = SidebarConfig.getMenuItems();
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        if (item.subItems != null) {
          return _ExpansionNavItem(
            item: item,
            currentRoute: currentRoute,
          );
        }
        return _SingleNavItem(
          item: item,
          isSelected: currentRoute == item.route,
        );
      },
    );
  }
}

class _SingleNavItem extends StatelessWidget {
  final NavItemModel item;
  final bool isSelected;

  const _SingleNavItem({required this.item, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          if (item.route != null && !isSelected) {
            if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
              Navigator.pop(context);
            }
            Get.offAllNamed(item.route!); // Use offAllNamed or similar to avoid stack issues in some cases, or just toNamed
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: isSelected 
              ? LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withAlpha(200),
                  ],
                ) 
              : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected ? [
              BoxShadow(
                color: AppColors.primary.withAlpha(80),
                blurRadius: 15,
                offset: const Offset(0, 5),
              )
            ] : null,
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                color: isSelected ? Colors.white : Colors.white.withAlpha(120),
                size: 20,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  item.title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white.withAlpha(150),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              if (isSelected)
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 400),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpansionNavItem extends StatefulWidget {
  final NavItemModel item;
  final String currentRoute;

  const _ExpansionNavItem({required this.item, required this.currentRoute});

  @override
  State<_ExpansionNavItem> createState() => _ExpansionNavItemState();
}

class _ExpansionNavItemState extends State<_ExpansionNavItem> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.item.subItems!.any((sub) => sub.route == widget.currentRoute);
  }

  @override
  Widget build(BuildContext context) {
    final bool hasActiveChild = widget.item.subItems!.any((sub) => sub.route == widget.currentRoute);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: hasActiveChild && !_isExpanded ? AppColors.primary.withAlpha(30) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.item.icon,
                    color: hasActiveChild ? AppColors.primary : Colors.white.withAlpha(120),
                    size: 20,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.item.title,
                      style: TextStyle(
                        color: hasActiveChild ? Colors.white : Colors.white.withAlpha(150),
                        fontWeight: hasActiveChild ? FontWeight.bold : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  RotationTransition(
                    turns: AlwaysStoppedAnimation(_isExpanded ? 0.25 : 0),
                    child: Icon(
                      Icons.keyboard_arrow_right_rounded,
                      color: Colors.white.withAlpha(100),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 8, left: 12),
              child: Column(
                children: widget.item.subItems!.map((sub) {
                  final bool isSubSelected = widget.currentRoute == sub.route;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: InkWell(
                      onTap: () {
                        if (!isSubSelected) {
                          if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
                            Navigator.pop(context);
                          }
                          Get.offAllNamed(sub.route);
                        }
                      },
                      borderRadius: BorderRadius.circular(15),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSubSelected ? AppColors.primary.withAlpha(25) : Colors.transparent,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 4,
                              height: isSubSelected ? 16 : 4,
                              decoration: BoxDecoration(
                                color: isSubSelected ? AppColors.primary : Colors.white.withAlpha(30),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                sub.title,
                                style: TextStyle(
                                  color: isSubSelected ? Colors.white : Colors.white.withAlpha(120),
                                  fontSize: 13,
                                  fontWeight: isSubSelected ? FontWeight.bold : FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}
