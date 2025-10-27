import 'package:example/src/widgets/dropdown_field.dart';
import 'package:example/src/widgets/raw_autocomplete_example.dart';
import 'package:example/src/widgets/text_bar.dart';
import 'package:flutter/material.dart';

import 'my_wizard_step.dart';
import 'step_three_provider.dart';

class StepThree extends StatefulWidgetStep {
  StepThree({
    required StepThreeProvider provider,
    Key? key,
  }) : super(key: key, provider: provider);

  @override
  State<StepThree> createState() => _StepThreeState();
}

class _StepThreeState extends StateStep<StepThree> {
  final List<PopupDropdownItem<String>> _salary_update_items = [
    PopupDropdownItem(value: '1', label: 'месяц назад'),
    PopupDropdownItem(value: '3', label: 'квартал назад'),
    PopupDropdownItem(value: '6', label: 'полгода назад'),
    PopupDropdownItem(value: '12', label: 'год назад'),
    PopupDropdownItem(value: '24', label: '2 года назад'),
    PopupDropdownItem(value: '36', label: '3 года назад'),
    PopupDropdownItem(value: '>36', label: 'больше 3 лет назад'),
  ];

  final List<PopupDropdownItem<String>> _work_from_items = [
    PopupDropdownItem(value: 'office', label: 'Офис'),
    PopupDropdownItem(value: 'home', label: 'Удаленная'),
    PopupDropdownItem(value: 'both', label: 'Гибрид'),
  ];

  List<String> region_items = [
    'Москва',
    'Санкт-Петербург',
    'Новосибирск',
  ];

  @override
  Widget build(
    BuildContext context,
  ) {
    List<Widget> textFields = [
      Text('Текущие зарплаты', style: headerStyle),
      const SizedBox(height: 6),
      Text('Будем предлагать лучшее время и размер для повышение зарплаты',
          style: headerStyle2),
      const SizedBox(height: 16),
      buildTextFieldWithLabel(
          'Какая у вас сейчас зарплата?', '15000', 'salary'),
      const SizedBox(height: 16),
      buildDropdownSection('Когда последний раз вам ее повышали?',
          'месяц назад', 'last_upgrade', _salary_update_items),
      const SizedBox(height: 16),
      buildDropdownSection('Какой у вас формат работы?', 'месяц назад',
          'work_from', _work_from_items),
      const SizedBox(height: 16),
      TextBar('В каком регионе работаете?'),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
              flex: 6,
              child: buildTextFieldWithLabel(
                  null, 'Москва', 'office_location', region_items)),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            flex: 5,
            child: buildTextFieldWithLabel(
                null, 'Россия', 'office_country', ['Россия', 'Казахстан']),
          ),
        ],
      ),
      const SizedBox(height: 16),
      buildCheckBox(
          'Я хочу обмениваться с сообществом и получать информирование об уровне зарплат в моём регионе у моей профессии.',
          'want_info')
    ];

    return Column(
      children: textFields,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }
}
