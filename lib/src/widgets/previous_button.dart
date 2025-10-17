import 'package:flutter/material.dart';
import 'package:flutter_wizard/flutter_wizard.dart';

class PreviousButton extends StatelessWidget {
  const PreviousButton({Key? key}) : super(key: key);

  @override
  Widget build(
    BuildContext context,
  ) {
    return StreamBuilder<bool>(
      stream: context.wizardController.getIsGoBackEnabledStream(),
      initialData: context.wizardController.getIsGoBackEnabled(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.hasError) {
          return const SizedBox.shrink();
        }
        final enabled = snapshot.data!;
        return OutlinedButton(
          child: const Text("< Назад"),
          onPressed: enabled ? context.wizardController.goBack : null,
          style: OutlinedButton.styleFrom(
            // backgroundColor: Color(0xFF5801fd), // Цвет фона
            foregroundColor: Color(0xFF5801fd), // Цвет текста
            // foregroundColor: Colors.white, // Цвет текста
            side: BorderSide(color: Colors.black54), // Цвет границы
          ),
        );
      },
    );
  }
}
