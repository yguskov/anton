import 'package:flutter/material.dart';

import '../../example.dart';
import 'my_wizard_step.dart';

class StepTwo extends StatefulWidgetStep {
  StepTwo({
    required StepTwoProvider provider,
    Key? key,
  }) : super(key: key, provider: provider);

  @override
  State<StepTwo> createState() => _StepTwoState();
}

class _StepTwoState extends StateStep<StepTwo> {
  // Данные для dropdown'ов
  static const List<String> aimList = [
    'Повышения зарплаты',
    'Профессионального роста',
    'Продвижения по карьере',
    'Сменить направление'
  ];

  static const List<String> whyList = [
    'Взял/Готов взять на себя дополнительную ответственность',
    'Активно развиваюсь и обещаю продолжать расти',
    'Принес пользу выдающимися достижениями',
  ];

  @override
  Widget build(
    BuildContext context,
  ) {
    List<Widget> textFields = [
      buildRadioList('Какая у вас цель?', 'Я хочу', 'aim', aimList),
      const SizedBox(height: 16),
      buildRadioList('', 'Я заслуживаю (Цель) потому, что я:', 'why', whyList),
      const SizedBox(height: 16),
    ];

    return Column(
        children: textFields,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min);
  }
}


// Классы из предыдущего примера (должны быть в том же файле или импортированы)



