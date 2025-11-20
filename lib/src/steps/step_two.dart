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
      Text('Какая у вас цель?', style: headerStyle),
      const SizedBox(height: 6),
      Text(
        'Почему вы этого заслуживаете?',
        style: headerStyle2,
      ),
      const SizedBox(height: 16),
      buildRadioList('Я хочу:', 'aim', aimList, 25.0),
      const SizedBox(height: 16),
      buildRadioList('Я этого заслуживаю (Цель) потому, что я:', 'why', whyList,
          35, 1.3, 'Другое'),
      const SizedBox(height: 16),
    ];

    // return ListView(
    //   children: textFields,
    //   // controller: ScrollController(),
    //   physics: AlwaysScrollableScrollPhysics(),
    //   // scrollDirection: Axis.vertical,
    // );

    return SingleChildScrollView(
      physics: ClampingScrollPhysics(),
      child: Column(
        children: textFields,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }
}


// Классы из предыдущего примера (должны быть в том же файле или импортированы)



