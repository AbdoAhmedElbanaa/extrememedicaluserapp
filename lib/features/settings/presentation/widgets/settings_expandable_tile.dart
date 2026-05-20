import 'package:flutter/material.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';

class SettingsExpandableTile extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<Widget> children;
  final bool initiallyExpanded;
  final bool canExpand;
  final bool showHeader;

  const SettingsExpandableTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.children,
    this.initiallyExpanded = false,
    this.canExpand = true,
    this.showHeader = true,
  });

  @override
  State<SettingsExpandableTile> createState() => _SettingsExpandableTileState();
}

class _SettingsExpandableTileState extends State<SettingsExpandableTile> with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _iconTurns;

  @override
  void initState() {
    super.initState();
    _isExpanded = !widget.canExpand || widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _iconTurns = _controller.drive(Tween<double>(begin: 0.0, end: 0.5).chain(CurveTween(curve: Curves.easeIn)));
    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.canExpand) return;
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.cinematicSurface.withValues(alpha: 0.4) 
            : AppColors.surfaceLight.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark 
              ? AppColors.distinctBorderDark 
              : AppColors.distinctBorderLight,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          if (widget.showHeader)
            InkWell(
              onTap: _handleTap,
              borderRadius: BorderRadius.circular(28),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: widget.iconColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: widget.iconColor.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.iconColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.foregroundLight,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (widget.canExpand)
                      RotationTransition(
                        turns: _iconTurns,
                        child: Icon(
                          Icons.expand_more_rounded,
                          color: isDark ? Colors.white.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.2),
                          size: 20,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ClipRect(
            child: AnimatedAlign(
              alignment: Alignment.center,
              duration: const Duration(milliseconds: 300),
              heightFactor: _isExpanded ? 1.0 : 0.0,
              curve: Curves.easeInOut,
              child: Column(
                children: [
                  if (widget.showHeader)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
                    ),
                  ...widget.children,
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
