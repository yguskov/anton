import 'package:flutter/material.dart';

import '../../example.dart';

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

  @override
  Widget build(
    BuildContext context,
  ) {
    List<Widget> textFields = [
      _buildTextFieldWithLabel('Имя пользователя', 'Введите ваше имя', 'fio'),
      const SizedBox(height: 16),
      _buildTextFieldWithLabel('Email', 'Введите ваш email', 'email'),
      const SizedBox(height: 16),
      _buildTextFieldWithLabel('Пароль', 'Введите пароль', 'password'),
      const SizedBox(height: 16),
      _buildDropdownSection(
          title: 'Категория товара',
          fieldName: 'category',
          items: categories,
          hint: 'Выберите категорию'),
    ];

    return Column(children: textFields);

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
  Widget _buildTextFieldWithLabel(String label, String hint, String fieldName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Описание
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: Color.fromRGBO(37, 46, 63, 1),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(3),
              topRight: Radius.circular(3),
              bottomLeft: Radius.circular(1),
              bottomRight: Radius.circular(1),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),

        // Отступ между описанием и текстовым полем
        const SizedBox(height: 4), // ← ДОБАВЛЕН ОТСТУП ЗДЕСЬ

        // Текстовое поле
        TextField(
          controller: widget.provider.controllerByName(fieldName),
          onChanged: (_) => widget.provider.updateValue(
              fieldName, widget.provider.controllerByName(fieldName).text),
          maxLines: 3,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[200],
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[600]!, width: 1.5),
              borderRadius: const BorderRadius.all(
                Radius.circular(4),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[800]!, width: 2.0),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(6),
                bottomRight: Radius.circular(6),
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 16,
          ),
        ),
      ],
    );
  }

// Виджет секции dropdown
  Widget _buildDropdownSection(
      {required String fieldName,
      required String title,
      required List<PopupDropdownItem<String>> items,
      String hint = ''}) {
    PopupDropdownWithCheckmark<String> dropdown =
        PopupDropdownWithCheckmark<String>(
            value: widget.provider.getValue(fieldName),
            items: items,
            hint: hint,
            onSelected: (value) {
              setState(() {
                widget.provider.updateValue(fieldName, value);
                print(value);
                print(widget.provider.getValue('category'));
              });
            });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: Color.fromRGBO(37, 46, 63, 1),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(3),
              topRight: Radius.circular(3),
              bottomLeft: Radius.circular(1),
              bottomRight: Radius.circular(1),
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              // fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 8),
        dropdown,
      ],
    );
  }
}

// Классы из предыдущего примера (должны быть в том же файле или импортированы)
class PopupDropdownItem<T> {
  final T value;
  final String label;

  PopupDropdownItem({
    required this.value,
    required this.label,
  });
}

class PopupDropdownWithCheckmark<T> extends StatelessWidget {
  final T? value;
  final List<PopupDropdownItem<T>> items;
  final ValueChanged<T> onSelected;
  final String hint;
  final double elevation;

  const PopupDropdownWithCheckmark({
    Key? key,
    required this.value,
    required this.items,
    required this.onSelected,
    this.hint = 'Выберите значение',
    this.elevation = 8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedItem = items.firstWhere(
      (item) => item.value == value,
      orElse: () => PopupDropdownItem<T>(
        value: items.first.value,
        label: hint,
      ),
    );

    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[600]!, width: 1),
          borderRadius: BorderRadius.circular(4),
          color: Colors.grey[200]),
      child: PopupMenuButton<T>(
        elevation: elevation,
        onSelected: onSelected,
        itemBuilder: (BuildContext context) {
          return items.map((item) {
            return PopupMenuItem<T>(
              value: item.value,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item.label),
                  if (value == item.value)
                    Icon(Icons.check, color: Theme.of(context).primaryColor),
                ],
              ),
            );
          }).toList();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value != null ? selectedItem.label : hint,
                  style: TextStyle(
                    color:
                        (value ?? '') != '' ? Colors.black : Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ),
              Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
            ],
          ),
        ),
      ),
    );
  }
}
