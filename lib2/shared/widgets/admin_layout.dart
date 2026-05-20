import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/responsive_helper.dart';
import '../../features/dashboard/widgets/sidebar_widget.dart';
import '../../features/dashboard/widgets/header_widget.dart';

class AdminLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final bool showHeader;

  const AdminLayout({
    super.key,
    required this.child,
    this.title = 'Dashboard',
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveHelper.isDesktop(context);
    final String currentRoute = Get.currentRoute;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: isDesktop ? null : Drawer(
        width: 300,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutQuart,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(-100 * (1 - value), 0),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: SidebarWidget(currentRoute: currentRoute),
        ),
      ),
      body: Row(
        children: [
          if (isDesktop) SidebarWidget(currentRoute: currentRoute),
          Expanded(
            child: isDesktop 
              ? Column(
                  children: [
                    if (showHeader) HeaderWidget(title: title),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: child,
                      ),
                    ),
                  ],
                )
              : Stack(
                  children: [
                    // Main Content
                    Positioned.fill(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                          top: showHeader ? MediaQuery.of(context).padding.top + 90 : 20,
                          bottom: 24,
                        ),
                        child: child,
                      ),
                    ),
                    
                    // Floating Header
                    if (showHeader)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: HeaderWidget(title: title),
                      ),
                  ],
                ),
          ),
        ],
      ),
    );
  }
}
