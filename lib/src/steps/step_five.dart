import 'dart:js_interop';

import 'package:example/services/api_service.dart';
import 'package:example/src/steps/steps.dart';
import 'package:example/src/widgets/dropdown_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  State<StepFive> createState() => StepFiveState();
}

class StepFiveState extends StateStep<StepFive> {
  List<Map<String, String>> get skillList => widget.myProvider.skillList;
  int? _selectedSkill;

  List<String> _skill_options = [
    'Пишу на Java',
    'Пишу на PHP',
    'Бухучет',
    'Вожу самосвал',
    'В детстве водил мотоцикл',
    'Управление метлой'
  ];

  @override
  void initState() {
    super.initState();
    // default values
    widget.provider.controllerByName('skill_type').text = 'Не знаю';
    // Подписываемся на изменения всех полей
    widget.provider.controllerByName('skill_name').addListener(_rebuild);
    widget.provider.controllerByName('skill_level').addListener(_rebuild);
    widget.provider.controllerByName('skill_type').addListener(_rebuild);
    widget.provider.controllerByName('skill_power').addListener(_rebuild);

    ApiService apiService = Provider.of<ApiService>(context, listen: false);
    Future.microtask(() async {
      _skill_options = await apiService.listHint('skill');
      setState(() {});
    });
  }

  // select paticular skill
  void _onSelect(int? index) {
    setState(() {
      _selectedSkill = index;
      widget.provider.controllerByName('skill_name').text =
          index != null ? skillList[index!]['name']! : '';
      widget.provider.controllerByName('skill_level').text =
          index != null ? skillList[index!]['level']! : '';
      widget.provider.controllerByName('skill_type').text =
          index != null ? skillList[index!]['type']! : 'Не знаю';
      widget.provider.controllerByName('skill_power').text =
          index != null ? skillList[index!]['power']! : '';
      widget.provider.updateValue('skill_name', index != null ? skillList[index]['name']! : '');
      widget.provider.updateValue('skill_level', index != null ? skillList[index]['level']! : '');
      widget.provider
          .updateValue('skill_type', index != null ? skillList[index]['type']! : 'Не знаю');
      widget.provider.updateValue('skill_power', index != null ? skillList[index]['power']! : '');
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

      if (_selectedSkill == null) {
        skillList.add(currentSkill);
      } else {
        skillList[_selectedSkill!] = currentSkill;
      }

      widget.provider.controllerByName('skill_name').text = '';
      widget.provider.controllerByName('skill_level').text = '';
      widget.provider.controllerByName('skill_type').text = 'Не знаю';
      widget.provider.controllerByName('skill_power').text = '';
      widget.provider.updateValue('skill_name', '');
      widget.provider.updateValue('skill_level', '');
      widget.provider.updateValue('skill_type', 'Не знаю');
      widget.provider.updateValue('skill_power', '');
    });

    // Delay slightly to ensure layout is updated
    if (_selectedSkill == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.provider.wizardController.enableGoNext(4);
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
      if (widget.myProvider.skillList.length == 0)
        widget.provider.wizardController.disableGoNext(4);
    });
  }

  List<String>? get skills => _skill_options;

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

  bool get removeEnabled {
    if (_selectedSkill == null) return false;
    StepSixProvider providerSix = providerOfStep(5) as StepSixProvider;
    return !providerSix.knowList
        .any((item) => item['skill'] == widget.myProvider.skillList[_selectedSkill!]['name']);
  }

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
        Text('Чем вы сильны?', style: headerStyle),
        const SizedBox(height: 6),
        Text('Какие навыки позволят использовать ваши умения в максимально эффективных позициях.',
            style: headerStyle2),
        const SizedBox(height: 16),
        buildTextFieldWithLabel('Мои навыки', 'Управление метлой', 'skill_name', skills),
        const SizedBox(height: 16),
        buildDropdownSection(
            'Какой у вас уровень мастерства навыка', '1-5| не знаю', 'skill_level', levels),
        const SizedBox(height: 16),
        // power
        buildRadioList('Я считаю это своим:', 'skill_power',
            ['Сильным навыком', 'Слабым навыком', 'Не знаю'], null, 1.3),
        const SizedBox(height: 16),
        buildTextFieldWithLabel(
            'К какому типу относится навык?', 'hard|soft|другое', 'skill_type', ['hard', 'soft']),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: ElevatedButton(
                child: const Text("Удалить"),
                onPressed: removeEnabled ? _remove : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      removeEnabled ? Color(0xFFF76D12) : Colors.black87, // Основной цвет фона
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
                  backgroundColor:
                      saveEnabled ? Color(0xFFF76D12) : Colors.black87, // Основной цвет фона
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
                rightColor: Color(0xFF5B32332), // Colors.green.shade800
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
        return Color(0xFF3EAC5D); //Color.fromARGB(a, r, g, b); 3EAC5D
      case 'Слабым навыком':
        return Color(0xFFF76D12); // Colors.orange;
    }
    return Colors.grey;
  }
}
