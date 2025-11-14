import 'dart:js_interop';

import 'package:example/src/steps/step_five_provider.dart';
import 'package:example/src/widgets/dropdown_field.dart';
import 'package:flutter/material.dart';

import '../widgets/custom_card.dart';
import 'my_wizard_step.dart';

class StepFive extends StatefulWidgetStep {
  final StepFiveProvider myProvider;

  StepFive({
    required StepFiveProvider provider,
    Key? key,
  })  : myProvider = provider,
        super(key: key, provider: provider);

  @override
  State<StepFive> createState() => _StepFiveState();
}

class _StepFiveState extends StateStep<StepFive> {
  List<Map<String, String>> get skillList => widget.myProvider.skillList;
  int? _selectedSkill;

  @override
  void initState() {
    super.initState();
    // Подписываемся на изменения всех полей
    widget.provider.controllerByName('skill_name').addListener(_rebuild);
    widget.provider.controllerByName('skill_level').addListener(_rebuild);
    widget.provider.controllerByName('skill_type').addListener(_rebuild);
    widget.provider.controllerByName('skill_power').addListener(_rebuild);
  }

  // select paticular skill
  void _onSelect(int? index) {
    setState(() {
      _selectedSkill = index;
      widget.provider.controllerByName('skill_name').text =
          index.isDefinedAndNotNull ? skillList[index!]['name']! : '';
      widget.provider.controllerByName('skill_level').text =
          index.isDefinedAndNotNull ? skillList[index!]['level']! : '';
      widget.provider.controllerByName('skill_type').text =
          index.isDefinedAndNotNull ? skillList[index!]['type']! : '';
      widget.provider.controllerByName('skill_power').text =
          index.isDefinedAndNotNull ? skillList[index!]['power']! : '';
      widget.provider.updateValue('skill_name',
          index.isDefinedAndNotNull ? skillList[index!]['name']! : '');
      widget.provider.updateValue('skill_level',
          index.isDefinedAndNotNull ? skillList[index!]['level']! : '');
      widget.provider.updateValue('skill_type',
          index.isDefinedAndNotNull ? skillList[index!]['type']! : '');
      widget.provider.updateValue('skill_power',
          index.isDefinedAndNotNull ? skillList[index!]['power']! : '');
    });
  }

  // save skill
  void _save() {
    Map<String, String> currentSkill;
    setState(() {
      currentSkill = {
        'name': widget.provider.getValue('skill_name'),
        'level': widget.provider.getValue('skill_level'),
        'type': widget.provider.getValue('skill_type'),
        'power': widget.provider.getValue('skill_power'),
      };

      if (_selectedSkill.isNull) {
        skillList.add(currentSkill);
      } else {
        skillList[_selectedSkill!] = currentSkill;
      }

      widget.provider.controllerByName('skill_name').text = '';
      widget.provider.controllerByName('skill_level').text = '';
      widget.provider.controllerByName('skill_type').text = '';
      widget.provider.controllerByName('skill_power').text = '';
      widget.provider.updateValue('skill_name', '');
      widget.provider.updateValue('skill_level', '');
      widget.provider.updateValue('skill_type', '');
      widget.provider.updateValue('skill_power', '');
    });

    // Delay slightly to ensure layout is updated
    if (_selectedSkill.isNull) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } else {
      _selectedSkill = null;
    }
  }

  // remove Skill
  void _remove() {
    setState(() {
      skillList.removeAt(_selectedSkill!);
      widget.provider.controllerByName('skill_name').text = '';
      widget.provider.controllerByName('skill_level').text = '';
      widget.provider.controllerByName('skill_type').text = '';
      widget.provider.controllerByName('skill_power').text = '';
      widget.provider.updateValue('skill_name', '');
      widget.provider.updateValue('skill_level', '');
      widget.provider.updateValue('skill_type', '');
      widget.provider.updateValue('skill_power', '');
      _selectedSkill = null;
    });
  }

  List<String>? get skills => [
        'Пишу на Java',
        'Пишу на PHP',
        'Бухучет',
        'Вожу самосвал',
        'В детстве водил мотоцикл',
        'Управление метлой'
      ];

  List<PopupDropdownItem<String>> get levels => [
        PopupDropdownItem(value: '1', label: '1'),
        PopupDropdownItem(value: '2', label: '2'),
        PopupDropdownItem(value: '3', label: '3'),
        PopupDropdownItem(value: '4', label: '4'),
        PopupDropdownItem(value: '5', label: '5'),
        PopupDropdownItem(value: '0', label: 'Не знаю'),
      ];

  bool get saveEnabled =>
      widget.provider.getValue('skill_name').isNotEmpty &&
      widget.provider.getValue('skill_level').isNotEmpty &&
      widget.provider.getValue('skill_type').isNotEmpty;

  bool get removeEnabled => !_selectedSkill.isNull;

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
        Text('Навыки', style: headerStyle),
        const SizedBox(height: 6),
        Text(
            'Какие навыки позволят использовать ваши умения в максимально эффективных позициях.',
            style: headerStyle2),
        const SizedBox(height: 16),
        buildTextFieldWithLabel(
            'Мои навыки', 'Управление метлой', 'skill_name', skills),
        const SizedBox(height: 16),
        buildDropdownSection('Какой у вас уровень навыка?', '1-5| не знаю',
            'skill_level', levels),
        const SizedBox(height: 16),
        buildTextFieldWithLabel('К какому типу относится навык?',
            'hard|soft|другое', 'skill_type', ['hard', 'soft']),
        const SizedBox(height: 16),
        // power
        buildRadioList('Я считаю это своим:', 'skill_power',
            ['Не знаю', 'Сильным навыком', 'Слабым навыком'], null, 1.3),
        const SizedBox(height: 12),
        Row(
          children: [
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
        _buildSkillList(constraints),
      ];

      return ListView(
        controller: _scrollController,
        children: textFields,
      );
    });
  }

  _buildSkillList(BoxConstraints constraints) {
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
        children: List.generate(skillList.length, (index) {
          return MouseRegion(
            cursor: MaterialStateMouseCursor.clickable,
            child: GestureDetector(
              onTap: () => _onSelect(index),
              child: CustomSquareCard(
                width: boxWidth,
                height: 60,
                title:
                    '${skillList.elementAt(index)['name'] ?? ''} , Тип навыка: ${skillList.elementAt(index)['type'] ?? ''}',
                leftText: powerShortText(skillList.elementAt(index)['power']!),
                leftColor: powerColor(skillList.elementAt(index)['power']!),
                rightText: 'Уровень: ${skillList[index]['level']}',
                rightColor: Color(0xFF5801fd), // Colors.green.shade800
                selected: _selectedSkill == index,
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
    widget.provider.controllerByName('skill_name').removeListener(_rebuild);
    widget.provider.controllerByName('skill_level').removeListener(_rebuild);
    widget.provider.controllerByName('skill_type').removeListener(_rebuild);
    widget.provider.controllerByName('skill_power').removeListener(_rebuild);

    // widget.provider.controllerByName('skill_name').dispose();
    // widget.provider.controllerByName('skill_level').dispose();
    // widget.provider.controllerByName('skill_power').dispose();
    _scrollController.dispose();
    super.dispose();
  }

  powerShortText(String value) {
    switch (value) {
      case 'Сильным навыком':
        return 'Сильный';
      case 'Слабым навыком':
        return 'Слабый';
    }
  }

  Color powerColor(String value) {
    switch (value) {
      case 'Сильным навыком':
        return Colors.orange;
      case 'Слабым навыком':
        return Color.fromARGB(255, 147, 139, 79);
    }
    return Colors.grey;
  }
}
