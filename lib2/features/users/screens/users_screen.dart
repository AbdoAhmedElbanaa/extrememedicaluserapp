import 'package:flutter/material.dart';
import '../../../shared/widgets/admin_layout.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return AdminLayout(
      title: 'User Management',
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 80,
              color: isDark ? Colors.white10 : Colors.black12,
            ),
            const SizedBox(height: 16),
            Text(
              'User Management Content',
              style: TextStyle(
                color: isDark ? Colors.white24 : Colors.black26,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
