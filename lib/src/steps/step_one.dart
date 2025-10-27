import 'package:example/src/widgets/text_bar.dart';
import 'package:flutter/material.dart';

import '../../example.dart';
import 'my_wizard_step.dart';

class StepOne extends StatefulWidgetStep {
  StepOne({
    required StepOneProvider provider,
    Key? key,
  }) : super(key: key, provider: provider);

  @override
  StateStep<StepOne> createState() => _StepOneState();
}

class _StepOneState extends StateStep<StepOne> {
  static const List<String> _positionOptions = [
    'Аналитик',
    'Джуниор фронтэнд программист',
    'Менеджер по работе с клиентами',
    'Системный администратор',
    'Строитель-монтажник',
  ];

  static const List<String> _sectorOptions = [
    'ИТ',
    'Консталтинг',
    'Торговля',
    'Строительство',
    'Финансы',
    'Услуги',
  ];

  @override
  Widget build(
    BuildContext context,
  ) {
    List<Widget> textFields = [
      Text('Представьтесь', style: headerStyle),
      const SizedBox(height: 20),
      buildTextFieldWithLabel('Ваши Фамилия и Имя', 'Михайлов Петр', 'fio'),
      const SizedBox(height: 16),
      buildTextFieldWithLabel('Какая у вас [должность/профессия]?',
          'Джуниор фронтэнд программист', 'position', _positionOptions),
      const SizedBox(height: 16),
      buildTextFieldWithLabel(
          'В какой [индустрии] работаете?', 'ИТ', 'sector', _sectorOptions),
      const SizedBox(height: 16),
      TextBar('Как вы обращаетесь к начальнику? Какая у него почта?'),
      const SizedBox(height: 5),
      Row(
        children: [
          Expanded(
            flex: 6,
            child: buildJustTextField('Петров Михаил', 'boss_fio'),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            flex: 5,
            child: buildJustTextField('petrovWork@mail.com', 'boss_email'),
          ),
        ],
      ),

      // _buildDropdownSection('Как вы обращаетесь к начальнику?', 'Петров Михаил', 'boss_fio', categories),
      // const SizedBox(height: 16),
      // _buildRadioList('Какая у вас цель?', 'Я хочу', 'aim', aimList),
    ];

    return Column(
      children: textFields,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
    );

    /*
    return InputField(
      label: const Text(
        'Description',
      ),
      input: TextField(
        controller: provider.descriptionTextController,
        maxLines: 3,
        onChanged: (_) => provider.updateDescription(
          provider.descriptionTextController.text,
        ),
        focusNode: provider.descriptionFocusNode,
      ),
    );
    */
  }
}


// Классы из предыдущего примера (должны быть в том же файле или импортированы)



