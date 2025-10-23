import 'package:flutter/material.dart';

import '../../example.dart';
import '../widgets/dropdown_field.dart';
import '../widgets/radio_list_field.dart';
import '../widgets/raw_autocomplete_example.dart';

class StepOne extends StatefulWidget {
  StepOne({
    required this.provider,
    Key? key,
  }) : super(key: key);

  final StepOneProvider provider;

  @override
  State<StepOne> createState() => _StepOneState();
}

class _StepOneState extends State<StepOne> {
  // Данные для dropdown'ов
  final List<PopupDropdownItem<String>> categories = [
    PopupDropdownItem(value: 'electronics', label: 'Электроника'),
    PopupDropdownItem(value: 'clothing', label: 'Одежда'),
    PopupDropdownItem(value: 'books', label: 'Книги'),
    PopupDropdownItem(value: 'home', label: 'Дом и сад'),
    PopupDropdownItem(value: 'sports', label: 'Спорт'),
  ];

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
      _buildTextFieldWithLabel('Представьтесь', 'Михайлов Петр', 'fio'),
      const SizedBox(height: 16),
      _buildTextFieldWithLabel('Какая у вас [должность/профессия]?',
          'Джуниор фронтэнд программист', 'position', _positionOptions),
      const SizedBox(height: 16),
      _buildTextFieldWithLabel(
          'В какой [индустрии] работаете?', 'ИТ', 'sector', _sectorOptions),
      const SizedBox(height: 16),
      _buildTextFieldWithLabel(
          'Как вы обращаетесь к начальнику?', 'Петров Михаил', 'boss_fio'),
      // _buildDropdownSection('Как вы обращаетесь к начальнику?', 'Петров Михаил', 'boss_fio', categories),
      // const SizedBox(height: 16),
      // _buildRadioList('Какая у вас цель?', 'Я хочу', 'aim', aimList),
/*
      Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text == '') {
            return const Iterable<String>.empty();
          }
          return _options.where((String option) {
            return option.toLowerCase().contains(
                  textEditingValue.text.toLowerCase(),
                );
          });
        },
        onSelected: (String selection) {
          debugPrint('You just selected $selection');
        },
      ),

*/
    ];

    return Column(
        children: textFields,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min);

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

  // Метод для создания поля с описанием
  Widget _buildTextFieldWithLabel(String label, String hint, String fieldName,
      [List<String>? options]) {
    return RawAutocompleteExample(
      fieldName: fieldName,
      label: label,
      hint: hint,
      provider: widget.provider,
      options: options,
    );
  }

// Виджет секции dropdown
  Widget _buildDropdownSection(String label, String hint, String fieldName,
      List<PopupDropdownItem<String>> items) {
    return DropdownField(
      fieldName: fieldName,
      label: label,
      items: items,
      provider: widget.provider,
    );
  }

  final List<String> _options2 = [
    'Apple',
    'Banana',
    'Orange',
    'Grapes',
    'Mango'
  ];

  String? _selectedValue;

  Widget _buildRadioList(
      String label, String hint, String fieldName, List<String> items) {
    return DynamicRadioList(
        fieldName: fieldName,
        label: label,
        hint: hint,
        items: items,
        provider: widget.provider);
  }
}


// Классы из предыдущего примера (должны быть в том же файле или импортированы)



