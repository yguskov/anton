// lib/widgets/custom_app_bar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class AntAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  // final VoidCallback? onSettingsPressed;
  // final VoidCallback? onHelpPressed;

  const AntAppBar({
    super.key,
    required this.title,
    // this.onSettingsPressed,
    // this.onHelpPressed,
  });

  @override
  Widget build(BuildContext context) {
   final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: true);

    return AppBar(
      title: Text(title),
      actions: [
        SizedBox(width: 20),
        PopupMenuButton<String>(
          icon: const Icon(Icons.menu),
          iconSize: 30,
          onSelected: (String value) {
            switch (value) {
              case 'login':
                Navigator.pushNamed(context, '/login');
                break;               
              case 'logout':
                authProvider.logout();
                Navigator.pushNamed(context, '/login');
                break;              
              case 'profile':
                Navigator.pushNamed(context, '/profile');
                break;
              case 'help':
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Помощь')),
                );
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem<String>(
              value: 'login',
              child: Row(
                children: [
                  Icon(Icons.login, size: 18),
                  SizedBox(width: 8),
                  Text('Логин'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, size: 18),
                  SizedBox(width: 8),
                  Text('Выход'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person, size: 18),
                  SizedBox(width: 8),
                  Text('Профиль'),
                ],
              ),
            ),
          ],
        ),
        SizedBox(width: 20),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}