import 'package:flutter/material.dart';
import 'package:flutter_wizard/flutter_wizard.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../steps/step_finish_provider.dart';

class FinishedButton extends StatelessWidget {
  const FinishedButton({Key? key}) : super(key: key);

  @override
  Widget build(
    BuildContext context,
  ) {
    return StreamBuilder<bool>(
      stream: context.wizardController.getIsGoNextEnabledStream(),
      initialData: context.wizardController.getIsGoNextEnabled(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.hasError) {
          return const SizedBox.shrink();
        }
        final enabled = snapshot.data!;
        return ElevatedButton(
          child: const Text("Сохранить"),
          onPressed: enabled
              ? () {
                  _onPressed(context);
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFF76D12), // Основной цвет фона
            foregroundColor: Colors.white, // Цвет текста и иконки
          ),
        );
      },
    );
  }

  _onPressed(context) {
    stepFinishKey!.currentState!.onFinished();
  }
}
