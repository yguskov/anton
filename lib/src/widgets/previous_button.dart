import 'package:flutter/material.dart';
import 'package:flutter_wizard/flutter_wizard.dart';

import '../constants.dart';

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
        return ElevatedButton(
          child: const Text("Назад"),
          onPressed: enabled ? context.wizardController.goBack : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: secondaryColor,
            foregroundColor: Colors.white,
          ),
        );
      },
    );
  }
}
