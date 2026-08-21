import 'dart:math';

import 'package:email_validator/email_validator.dart';
import 'package:example/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

bool checkEmail(String email) {
  return EmailValidator.validate(email);
}

Future<void> openFullScreenDialog(BuildContext context, Widget content, double maxWidth,
    [String? title]) async {
  await showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: "Close",
    barrierColor: Colors.black54, // Полупрозрачный фон
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      final authProvider = Provider.of<AuthProvider>(context);

      return Material(
        color: Colors.transparent,
        child: SafeArea(
          child: Dialog(
            insetPadding: const EdgeInsets.all(20),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              width: min(maxWidth, MediaQuery.of(context).size.width * 0.9),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              child: Stack(
                children: [
                  // Контент с прокруткой
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
                      child: SingleChildScrollView(
                        child: content,
                      ),
                    ),
                  ),

                  Positioned(
                    top: 27,
                    left: 20,
                    child: Text(
                      title ?? '',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  // Кнопка закрытия
                  Positioned(
                    top: 15,
                    right: 10,
                    child: IconButton(
                      icon: Icon(Icons.close, size: 28),
                      onPressed: () {
                        authProvider.clearError();
                        Navigator.of(context).pop();
                      },
                      splashRadius: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOut),
        ),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
  );
}

// page layout limited by width
Widget AntLayout(Widget child) {
  return Container(
      color: Color.fromARGB(255, 225, 229, 233),
      child: Align(
          alignment: Alignment.topCenter,
          child: Container(
              constraints: BoxConstraints(
                maxWidth: 1366,
              ),
              child: child)));
}

String? ucfirst(String? str) {
  if (str == null) return null;
  return str[0].toUpperCase() + str.substring(1);
}
