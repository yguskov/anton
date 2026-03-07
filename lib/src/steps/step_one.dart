import 'package:example/services/api_service.dart';
import 'package:example/src/widgets/text_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../example.dart';
import 'my_wizard_step.dart';

class StepOne extends StatefulWidgetStep {
  StepOne({
    required StepOneProvider provider,
    Key? key,
  }) : super(key: key, provider: provider);

  @override
  StateStep<StepOne> createState() => StepOneState();
}

class StepOneState extends StateStep<StepOne> {
  static List<String> _positionOptions = [
    'Аналитик',
    'Джуниор фронтэнд программист',
    'Менеджер по работе с клиентами',
    'Системный администратор',
    'Строитель-монтажник',
  ];

  static List<String> _sectorOptions = [
    'ИТ',
    'Консталтинг',
    'Торговля',
    'Строительство',
    'Финансы',
    'Услуги',
  ];

  @override
  void initState() {
    ApiService apiService = Provider.of<ApiService>(context, listen: false);
    Future.microtask(() async {
      _positionOptions = await apiService.listHint('position');
      _sectorOptions = await apiService.listHint('sector');
      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    print('---- Rebuild positions');
    List<Widget> textFields = [
      Text('Представьтесь', style: headerStyle),
      const SizedBox(height: 20),
      buildTextFieldWithLabel('Ваши Фамилия и Имя', 'Михайлов Петр', 'fio'),
      const SizedBox(height: 16),
      buildTextFieldWithLabel('Какая у вас [должность/профессия]?', 'Джуниор фронтэнд программист',
          'position', _positionOptions),
      const SizedBox(height: 16),
      buildTextFieldWithLabel('В какой [индустрии] работаете?', 'ИТ', 'sector', _sectorOptions),
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

    return ListView(children: textFields);

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



