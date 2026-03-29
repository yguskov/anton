import 'dart:math';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

bool checkEmail(String email) {
  return EmailValidator.validate(email);
}

void openFullScreenDialog(BuildContext context, Widget content, double maxWidth) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Close",
      barrierColor: Colors.black54, // Полупрозрачный фон
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
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
                        padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
                        child: SingleChildScrollView(
                          child: content,
                        ),
                      ),
                    ),

                    // Кнопка закрытия
                    Positioned(
                      top: 10,
                      right: 10,
                      child: IconButton(
                        icon: Icon(Icons.close, size: 28),
                        onPressed: () => Navigator.of(context).pop(),
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