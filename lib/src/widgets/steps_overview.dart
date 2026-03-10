import 'package:flutter/material.dart';
import 'package:flutter_wizard/flutter_wizard.dart';

import '../../example.dart';

class StepsOverview extends StatelessWidget {
  const StepsOverview({Key? key}) : super(key: key);

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: ListView.builder(
        itemCount: context.wizardController.stepControllers.length,
        itemBuilder: (context, index) {
          final step = context.wizardController.stepControllers[index].step;
          return StreamBuilder<bool>(
            stream: context.wizardController.getIsGoToEnabledStream(index),
            initialData: context.wizardController.getIsGoToEnabled(index),
            builder: (context, snapshot) {
              final enabled = snapshot.data!;
              String title;
              switch (step.runtimeType) {
                case StepOneProvider:
                  title = "Представление";
                  break;
                case StepTwoProvider:
                  title = "Цели";
                  break;
                case StepThreeProvider:
                  title = "Зарплата";
                  break;
                case StepFourProvider:
                  title = "Обязанности";
                  break;
                case StepFiveProvider:
                  title = "Навыки";
                  break;
                case StepSixProvider:
                  title = "Знания";
                  break;
                case StepSevenProvider:
                  title = "Достижения";
                  break;
                case StepFinishProvider:
                  title = "Регистрация";
                  break;
                default:
                  title = "Еще";
                  break;
              }
              return StreamBuilder<int>(
                stream: context.wizardController.indexStream,
                initialData: context.wizardController.index,
                builder: (context, snapshot) {
                  final selectedIndex = snapshot.data!;
                  return ListTile(
                    title: Text(title),
                    selectedColor: Color(0xffffffff),
                    textColor: Color(0xffb3bdcd),
                    iconColor: Color(0xffb3bdcd),
                    leading: index == selectedIndex ? Icon(Icons.person) : Icon(Icons.ac_unit_rounded),
                    // leading: Image.asset('assets/profile.png'),
    
                    onTap: enabled
                        ? () => context.wizardController.goTo(index: index)
                        : null,
                    enabled: enabled,
                    selected: index == selectedIndex,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
