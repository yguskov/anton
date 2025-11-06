import 'dart:js_interop';

import 'package:example/src/steps/step_four_provider.dart';
import 'package:example/src/widgets/dropdown_field.dart';
import 'package:example/src/widgets/text_bar.dart';
import 'package:flutter/material.dart';

import '../widgets/custom_card.dart';
import 'my_wizard_step.dart';

class StepFour extends StatefulWidgetStep {
  final StepFourProvider myProvider;

  StepFour({
    required StepFourProvider provider,
    Key? key,
  })  : myProvider = provider,
        super(key: key, provider: provider);

  @override
  State<StepFour> createState() => _StepFourState();
}

class _StepFourState extends StateStep<StepFour> {
  List<Map<String, String>> get dutyList => widget.myProvider.dutyList;
  int? _selectedDuty;

  @override
  void initState() {
    super.initState();
    // Подписываемся на изменения всех полей
    widget.provider.controllerByName('duty_name').addListener(_rebuild);
    widget.provider.controllerByName('duty_period').addListener(_rebuild);
    widget.provider.controllerByName('duty_attitude').addListener(_rebuild);
  }

  // select paticular duty
  void _onSelect(int? index) {
    setState(() {
      _selectedDuty = index;
      widget.provider.controllerByName('duty_name').text =
          index.isDefinedAndNotNull ? dutyList[index!]['name']! : '';
      widget.provider.controllerByName('duty_period').text =
          index.isDefinedAndNotNull ? dutyList[index!]['period']! : '';
      widget.provider.controllerByName('duty_attitude').text =
          index.isDefinedAndNotNull ? dutyList[index!]['attitude']! : '';
      // widget.provider.controllerByName('duty_additional').text = dutyList[index]['additional']!;
      // widget.provider.controllerByName('duty_new').text = dutyList[index]['new']!;
      widget.provider.updateValue('duty_name',
          index.isDefinedAndNotNull ? dutyList[index!]['name']! : '');
      widget.provider.updateValue('duty_period',
          index.isDefinedAndNotNull ? dutyList[index!]['period']! : '');
      widget.provider.updateValue('duty_attitude',
          index.isDefinedAndNotNull ? dutyList[index!]['attitude']! : '');
      widget.provider.updateValue('duty_additional',
          index.isDefinedAndNotNull ? dutyList[index!]['additional']! : '');
      widget.provider.updateValue('duty_new',
          index.isDefinedAndNotNull ? dutyList[index!]['new']! : '');
    });
  }

  // save duty
  void _save() {
    Map<String, String> currentDuty;
    setState(() {
      currentDuty = {
        'name': widget.provider.getValue('duty_name'),
        'period': widget.provider.getValue('duty_period'),
        'attitude': widget.provider.getValue('duty_attitude'),
        'additional': widget.provider.getValue('duty_additional'),
        'new': widget.provider.getValue('duty_new'),
      };

      if (_selectedDuty.isNull) {
        dutyList.add(currentDuty);
      } else {
        dutyList[_selectedDuty!] = currentDuty;
      }

      _selectedDuty = null;
      widget.provider.controllerByName('duty_name').text = '';
      widget.provider.controllerByName('duty_period').text = '';
      widget.provider.controllerByName('duty_attitude').text = '';
      widget.provider.controllerByName('duty_additional').text = '';
      widget.provider.updateValue('duty_name', '');
      widget.provider.updateValue('duty_period', '');
      widget.provider.updateValue('duty_attitude', '');
      widget.provider.updateValue('duty_additional', '');
      widget.provider.updateValue('duty_new', '');
    });
  }

  // remove duty
  void _remove() {
    setState(() {
      dutyList.removeAt(_selectedDuty!);
      widget.provider.controllerByName('duty_name').text = '';
      widget.provider.controllerByName('duty_period').text = '';
      widget.provider.controllerByName('duty_attitude').text = '';
      widget.provider.controllerByName('duty_additional').text = '';
      widget.provider.updateValue('duty_name', '');
      widget.provider.updateValue('duty_period', '');
      widget.provider.updateValue('duty_attitude', '');
      widget.provider.updateValue('duty_additional', '');
      widget.provider.updateValue('duty_new', '');
      _selectedDuty = null;
    });
  }

  List<String>? get duites =>
      ['Чистка конюшен', 'Разработка приложений', 'Тестирование'];

  List<String>? get periods => [
        'каждый день',
        '2 раза в неделю',
        'раз в неделю',
        'раз в две недели',
        'раз в месяц'
      ];

  List<PopupDropdownItem<String>> get attitudes => [
        PopupDropdownItem(value: '1', label: 'Предпочитаю выполнять'),
        PopupDropdownItem(value: '-1', label: 'Нежелательно выполнять'),
        PopupDropdownItem(value: '0', label: 'Нейтрально'),
      ];

  bool get saveEnabled =>
      widget.provider.getValue('duty_name').isNotEmpty &&
      widget.provider.getValue('duty_period').isNotEmpty &&
      widget.provider.getValue('duty_attitude').isNotEmpty;

  bool get removeEnabled => !_selectedDuty.isNull;

  @override
  Widget build(
    BuildContext context,
  ) {
    List<Widget> textFields = [
      Text('Отвественность', style: headerStyle),
      const SizedBox(height: 6),
      Text(
          'Продемонстрируйте, что понимаете круг вашей ответственности, ' +
              'укажите те обязанности, которые вам нравится или не нравится выполнять. ' +
              'А также новые, которые еще готовы взять на себя. ' +
              'Специализация покажет стремление к повышению производительности.',
          style: headerStyle2),
      const SizedBox(height: 16),
      buildTextFieldWithLabel(
          'Мои обязанности', 'Чистка конюшен', 'duty_name', duites),
      const SizedBox(height: 16),
      buildTextFieldWithLabel(
          'Как часто?', '2 раза в неделю', 'duty_period', periods),
      const SizedBox(height: 16),
      buildDropdownSection(
          'Как вы относитесь к этой обязанности?',
          'Нравится выполнять|Не нравится выполнять|Нейтрально',
          'duty_attitude',
          attitudes),
      const SizedBox(height: 16),
      TextBar('Взята ли эта обязанность дополнительно к вашим основным?'),
      const SizedBox(height: 6),
      Row(
        children: [
          Expanded(
              flex: 3,
              child: buildCheckBox(
                  'Да, обязанность не входит в основные', 'duty_additional')),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              child: const Text("Сохранить"),
              onPressed: saveEnabled ? _save : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: saveEnabled
                    ? Color(0xFFF76D12)
                    : Colors.black87, // Основной цвет фона
                foregroundColor: Colors.white, // Цвет текста и иконки
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 3),
      Row(
        children: [
          Expanded(
              flex: 3,
              child:
                  buildCheckBox('Готов взять новую обязанность', 'duty_new')),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              child: const Text("Удалить"),
              onPressed: removeEnabled ? _remove : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: removeEnabled
                    ? Color(0xFFF76D12)
                    : Colors.black87, // Основной цвет фона
                foregroundColor: Colors.white, // Цвет текста и иконки
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      _buildDutyList(),
    ];

    return ListView(
      children: textFields,
      // mainAxisAlignment: MainAxisAlignment.start,
      // mainAxisSize: MainAxisSize.min,
      // crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  _buildDutyList() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => _onSelect(null),
      child: Wrap(
        spacing: 10, // горизонтальный отступ между блоками
        runSpacing: 10, // вертикальный отступ между строками
        children: List.generate(dutyList.length, (index) {
          return GestureDetector(
            onTap: () => _onSelect(index),
            child: CustomSquareCard(
              width: 280, // фиксированная ширина блока
              height: 60, // фиксированная высота
              title:
                  '${dutyList.elementAt(index)['name'] ?? ''} , ${dutyList.elementAt(index)['period'] ?? ''}',
              leftText:
                  attitudeShortText(dutyList.elementAt(index)['attitude']!),
              leftColor: attitudeColor(dutyList.elementAt(index)['attitude']!),
              rightText: dutyList[index]['new'] == '1'
                  ? 'Новая'
                  : (dutyList[index]['additional'] == '1'
                      ? 'Дополнительная'
                      : ''),
              rightColor: dutyList[index]['new'] == '1'
                  ? Colors.green.shade800
                  : Color(0xFF5801fd),
              selected: _selectedDuty == index,
            ),
          );
        }),
      ),
    );
  }

  void _rebuild() {
    widget.provider;
    setState(() {});
  }

  @override
  void dispose() {
    // Не забываем отписаться, чтобы избежать утечек памяти
    widget.provider.controllerByName('duty_name').removeListener(_rebuild);
    widget.provider.controllerByName('duty_period').removeListener(_rebuild);
    widget.provider.controllerByName('duty_attitude').removeListener(_rebuild);

    // widget.provider.controllerByName('duty_name').dispose();
    // widget.provider.controllerByName('duty_period').dispose();
    // widget.provider.controllerByName('duty_attitude').dispose();
    super.dispose();
  }

  attitudeShortText(String value) {
    switch (value) {
      case '-1':
        return 'Не нравится';
      case '0':
        return '';
      case '1':
        return 'Нравится';
    }
    return '';
  }

  Color attitudeColor(String value) {
    switch (value) {
      case '-1':
        return Colors.orange;
      case '0':
        return Colors.grey;
      case '1':
        return Colors.green.shade800;
    }
    return Colors.grey;
  }
}
