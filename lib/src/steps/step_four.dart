import 'dart:js_interop';

import 'package:example/src/steps/step_four_provider.dart';
import 'package:example/src/widgets/dropdown_field.dart';
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
          index != null ? dutyList[index!]['name']! : '';
      widget.provider.controllerByName('duty_period').text =
          index != null ? dutyList[index!]['period']! : '';
      widget.provider.controllerByName('duty_attitude').text =
          index != null ? dutyList[index!]['attitude']! : '';
      widget.provider.controllerByName('duty_type').text =
          index != null ? dutyList[index!]['type']! : '';
      widget.provider.updateValue(
          'duty_name', index != null ? dutyList[index!]['name']! : '');
      widget.provider.updateValue(
          'duty_period', index != null ? dutyList[index!]['period']! : '');
      widget.provider.updateValue(
          'duty_attitude', index != null ? dutyList[index!]['attitude']! : '');
      widget.provider.updateValue(
          'duty_type', index != null ? dutyList[index!]['type']! : '');
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
        'type': widget.provider.getValue('duty_type'),
      };

      if (_selectedDuty == null) {
        dutyList.add(currentDuty);
      } else {
        dutyList[_selectedDuty!] = currentDuty;
      }

      widget.provider.controllerByName('duty_name').text = '';
      widget.provider.controllerByName('duty_period').text = '';
      widget.provider.controllerByName('duty_attitude').text = '';
      widget.provider.controllerByName('duty_type').text = '';
      widget.provider.updateValue('duty_name', '');
      widget.provider.updateValue('duty_period', '');
      widget.provider.updateValue('duty_attitude', '');
      widget.provider.updateValue('duty_type', '');
    });

    // Delay slightly to ensure layout is updated
    if (_selectedDuty == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } else {
      _selectedDuty = null;
    }
  }

  // remove duty
  void _remove() {
    setState(() {
      dutyList.removeAt(_selectedDuty!);
      widget.provider.controllerByName('duty_name').text = '';
      widget.provider.controllerByName('duty_period').text = '';
      widget.provider.controllerByName('duty_attitude').text = '';
      widget.provider.controllerByName('duty_type').text = '';
      widget.provider.updateValue('duty_name', '');
      widget.provider.updateValue('duty_period', '');
      widget.provider.updateValue('duty_attitude', '');
      widget.provider.updateValue('duty_type', '');
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

  List<PopupDropdownItem<String>> get types => [
        PopupDropdownItem(value: 'base', label: 'Основная'),
        PopupDropdownItem(value: 'extra', label: 'Дополнительная'),
        PopupDropdownItem(value: 'new', label: 'Новая(Готов взять на себя)'),
      ];

  bool get saveEnabled =>
      widget.provider.getValue('duty_name').isNotEmpty &&
      widget.provider.getValue('duty_period').isNotEmpty &&
      widget.provider.getValue('duty_attitude').isNotEmpty;

  bool get removeEnabled => _selectedDuty != null;

  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return LayoutBuilder(builder: (context, constraints) {
      List<Widget> textFields = [
        Text('Круг вашей ответственности', style: headerStyle),
        const SizedBox(height: 6),
        Text(
            'Опишите ваши обязанности, и какие из них вам нравится или не нравится выполнять.\n' +
                'Какую новую ответственность вы готовы на себя взять для повышение зарплаты? ',
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
        buildDropdownSection(
            'Эта обязанность является',
            'Основной|Дополнительной|Новой(Готов взять на себя)',
            'duty_type',
            types),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: ElevatedButton(
                child: const Text("Удалить"),
                onPressed: removeEnabled ? _remove : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      removeEnabled ? Color(0xFFF76D12) : Colors.black87,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
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
        const SizedBox(height: 10),
        _buildDutyList(constraints),
      ];

      return ListView(
        controller: _scrollController,
        children: textFields,

        // mainAxisAlignment: MainAxisAlignment.start,
        // mainAxisSize: MainAxisSize.min,
        // crossAxisAlignment: CrossAxisAlignment.start,
      );
    });
  }

  _buildDutyList(BoxConstraints constraints) {
    double boxWidth;
    print(constraints);
    if (constraints.maxWidth < 600) {
      boxWidth = constraints.maxWidth;
    } else {
      boxWidth = constraints.maxWidth / 2 - 5;
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => _onSelect(null),
      child: Wrap(
        spacing: 10, // горизонтальный отступ между блоками
        runSpacing: 10, // вертикальный отступ между строками
        children: List.generate(dutyList.length, (index) {
          return MouseRegion(
            cursor: MaterialStateMouseCursor.clickable,
            child: GestureDetector(
              onTap: () => _onSelect(index),
              child: CustomSquareCard(
                width: boxWidth,
                height: 60,
                title:
                    '${dutyList.elementAt(index)['name'] ?? ''} , ${dutyList.elementAt(index)['period'] ?? ''}',
                leftText:
                    attitudeShortText(dutyList.elementAt(index)['attitude']!),
                leftColor:
                    attitudeColor(dutyList.elementAt(index)['attitude']!),
                rightText: dutyList[index]['type'] == 'new'
                    ? 'Новая'
                    : (dutyList[index]['type'] == 'extra'
                        ? 'Дополнительная'
                        : ''),
                rightColor: dutyList[index]['type'] == 'new'
                    ? Colors.green.shade800
                    : Color(0xFF5801fd),
                selected: _selectedDuty == index,
              ),
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
    widget.provider.controllerByName('duty_name').removeListener(_rebuild);
    widget.provider.controllerByName('duty_period').removeListener(_rebuild);
    widget.provider.controllerByName('duty_attitude').removeListener(_rebuild);

    // widget.provider.controllerByName('duty_name').dispose();
    // widget.provider.controllerByName('duty_period').dispose();
    // widget.provider.controllerByName('duty_attitude').dispose();
    _scrollController.dispose();
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
