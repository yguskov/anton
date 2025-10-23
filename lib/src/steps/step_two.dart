import 'package:flutter/material.dart';

import '../../example.dart';
import '../widgets/dropdown_field.dart';
import '../widgets/radio_list_field.dart';
import '../widgets/raw_autocomplete_example.dart';

class StepTwo extends StatefulWidget {
  StepTwo({
    required this.provider,
    Key? key,
  }) : super(key: key);

  final StepTwoProvider provider;

  @override
  State<StepTwo> createState() => _StepTwoState();
}

class _StepTwoState extends State<StepTwo> {
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
      _buildRadioList('Какая у вас цель?', 'Я хочу', 'aim', aimList),
      const SizedBox(height: 16),
      _buildRadioList('', 'Я заслуживаю (Цель) потому, что я:', 'why', whyList),
      const SizedBox(height: 16),
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



