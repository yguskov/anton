import 'package:example/register.dart';
import 'package:example/src/steps/my_wizard_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wizard/flutter_wizard.dart';

class NextButton extends StatelessWidget {
  const NextButton({Key? key}) : super(key: key);

  @override
  Widget build(
    BuildContext context,
  ) {
    // context.findRootAncestorStateOfType
    return StreamBuilder<bool>(
      stream: context.wizardController.getIsGoNextEnabledStream(),
      initialData: context.wizardController.getIsGoNextEnabled(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.hasError) {
          return const SizedBox.shrink();
        }
        final enabled = snapshot.data!;
        return ElevatedButton(
          child: const Text("Сохранить >"),
          onPressed: () {
            if (enabled && verifyStepData(context)) {
              context.wizardController.goNext();
            } else {
              stepGlobalKey
                  .elementAtOrNull(context.wizardController.index)
                  ?.currentState
                  ?.setState(() {});

              // показать уведомление
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Заполните данные'),
                  backgroundColor: Theme.of(context).colorScheme.primary));
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFF76D12), // Основной цвет фона
            foregroundColor: Colors.white, // Цвет текста и иконки
          ),
        );
      },
    );
  }

  verifyStepData(BuildContext context) {
    MyWizardStep stepProvider = context
        .wizardController.stepControllers[context.wizardController.index].step as MyWizardStep;

    return stepProvider.verifyData();
  }
}
