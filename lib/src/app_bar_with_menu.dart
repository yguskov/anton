// lib/widgets/custom_app_bar.dart
import 'package:example/src/constants.dart';
import 'package:example/src/widgets/login_dialog.dart';
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
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_outline, size: 25),
                    SizedBox(width: 8),
                    Text(
                      authProvider.isAuth ? authProvider.currentUser!.email : '',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_drop_down, size: 20),
                  ],
                ),
              ),
            ),
            // iconSize: 30,
            onSelected: (String value) {
              switch (value) {
                case 'login':
                  showLoginDialog(context);
                  // Navigator.pushNamed(context, '/login');
                  break;
                case 'logout':
                  authProvider.logout();
                  // Navigator.pushNamed(context, '/login');
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
              if (!authProvider.isAuth)
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
              if (authProvider.isAuth)
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
              if (authProvider.isAuth)
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
        elevation: antBarElevation);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
