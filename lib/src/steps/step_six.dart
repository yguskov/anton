import 'dart:js_interop';

import 'package:example/src/steps/steps.dart';
import 'package:flutter/material.dart';

import '../widgets/custom_card.dart';
import '../widgets/dropdown_field.dart';
import 'my_wizard_step.dart';

class StepSix extends StatefulWidgetStep {
  final StepSixProvider myProvider;

  StepSix({
    required StepSixProvider provider,
    Key? key,
  })  : myProvider = provider,
        super(key: key, provider: provider);

  @override
  State<StepSix> createState() => StepSixState();
}

class StepSixState extends StateStep<StepSix> {
  List<Map<String, String>> get knowList => widget.myProvider.knowList;
  int? _selectedKnow;
// List<PopupDropdownItem<String>>
  List<PopupDropdownItem<String>> get skill_list {
    // StepFourProvider fourProvider = widget.myProvider.wizardController
    //     .stepControllers[3].step as StepFourProvider;

    StepFiveProvider fiveProvider = providerOfStep(4) as StepFiveProvider;
    return fiveProvider.skillList
        .map((item) => PopupDropdownItem(value: item['name']!, label: item['name']!))
        // .where((name) => name != null)
        .cast<PopupDropdownItem<String>>()
        .toList()
      ..sort((a, b) => a.value.compareTo(b.value));
  }

  List<PopupDropdownItem<String>> get period_list => [
        PopupDropdownItem(value: '1', label: 'месяц назад'),
        PopupDropdownItem(value: '3', label: 'квартал назад'),
        PopupDropdownItem(value: '6', label: 'полгода назад'),
        PopupDropdownItem(value: '12', label: 'год назад'),
      ];

  String get_period_by_value(val) {
    try {
      print(period_list.singleWhere((item) {
        print('${item.value} == $val');
        return item.value == val;
      }));
      print('------>|$val|');
      return period_list.singleWhere((item) => item.value == val).label;
    } catch (e) {
      return '-';
    }
  }

  @override
  void initState() {
    super.initState();
    // Подписываемся на изменения всех полей
    widget.provider.controllerByName('know_name').addListener(_rebuild);
    widget.provider.controllerByName('know_skill').addListener(_rebuild);
    widget.provider.controllerByName('know_when').addListener(_rebuild);
    widget.provider.controllerByName('know_result').addListener(_rebuild);
  }

  // select paticular know
  void _onSelect(int? index) {
    setState(() {
      _selectedKnow = index;
      widget.provider.controllerByName('know_name').text =
          index != null ? knowList[index!]['name']! : '';
      widget.provider.controllerByName('know_skill').text =
          index != null ? knowList[index!]['skill']! : '';
      widget.provider.controllerByName('know_when').text =
          index != null ? knowList[index!]['when']! : '';
      widget.provider.controllerByName('know_result').text =
          index != null ? knowList[index!]['result']! : '';
      widget.provider.updateValue('know_name', index != null ? knowList[index!]['name']! : '');
      widget.provider.updateValue('know_skill', index != null ? knowList[index!]['skill']! : '');
      widget.provider.updateValue('know_when', index != null ? knowList[index!]['when']! : '');
      widget.provider.updateValue('know_result', index != null ? knowList[index!]['result']! : '');
    });
  }

  // save know
  void _save() {
    Map<String, String> currentKnow;
    setState(() {
      currentKnow = {
        'name': widget.provider.getValue('know_name'),
        'skill': widget.provider.getValue('know_skill'),
        'when': widget.provider.getValue('know_when'),
        'result': widget.provider.getValue('know_result'),
      };

      if (_selectedKnow == null) {
        knowList.add(currentKnow);
      } else {
        knowList[_selectedKnow!] = currentKnow;
      }

      widget.provider.controllerByName('know_name').text = '';
      widget.provider.controllerByName('know_skill').text = '';
      widget.provider.controllerByName('know_when').text = '';
      widget.provider.controllerByName('know_result').text = '';
      widget.provider.updateValue('know_name', '');
      widget.provider.updateValue('know_skill', '');
      widget.provider.updateValue('know_when', '');
      widget.provider.updateValue('know_result', '');
    });

    // Delay slightly to ensure layout is updated
    if (_selectedKnow == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } else {
      _selectedKnow = null;
    }
  }

  // remove Know
  void _remove() {
    setState(() {
      knowList.removeAt(_selectedKnow!);
      widget.provider.controllerByName('know_name').text = '';
      widget.provider.controllerByName('know_skill').text = '';
      widget.provider.controllerByName('know_when').text = '';
      widget.provider.controllerByName('know_result').text = '';
      widget.provider.updateValue('know_name', '');
      widget.provider.updateValue('know_skill', '');
      widget.provider.updateValue('know_when', '');
      widget.provider.updateValue('know_result', '');
      _selectedKnow = null;
    });
  }

  List<String>? get knows => [
        'Прочитал книгу ...',
      ];

  bool get saveEnabled =>
      widget.provider.getValue('know_name').isNotEmpty &&
      widget.provider.getValue('know_skill').isNotEmpty &&
      widget.provider.getValue('know_when').isNotEmpty;

  bool get removeEnabled => _selectedKnow != null;

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
        Text('Ваша мотивация развиваться', style: headerStyle),
        const SizedBox(height: 6),
        Text(
            'Покажите, что в вас стоит вкладываться ресурсами ради вашего роста и повышения эффективности',
            style: headerStyle2),
        const SizedBox(height: 16),
        buildTextFieldWithLabel('Укажите какое новое знание вы получили',
            'Прочитал книгу “Программирование для чайников”', 'know_name', knows),
        const SizedBox(height: 16),
        buildDropdownSection(
            'Какой навык это развивает?', 'Выбрать навык из имеющихся', 'know_skill', skill_list),
        const SizedBox(height: 16),
        buildDropdownSection('Когда вы это изучали?', 'Х месяцев назад', 'know_when', period_list),
        const SizedBox(height: 16),
        // result
        buildTextFieldWithLabel('Что принесло вам новое знание?',
            'Научился копировать код из учебника на компьютер', 'know_result'),
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
        buildCheckBox(
            'Я хочу получать советы по новым знаниям и активностям, которые помогут развивать мои текущие уровни навыков',
            'want_tip'),
        const SizedBox(height: 10),
        _buildKnowList(constraints),
      ];

      return ListView(
        controller: _scrollController,
        children: textFields,
      );
    });
  }

  _buildKnowList(BoxConstraints constraints) {
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
        children: List.generate(knowList.length, (index) {
          return MouseRegion(
            cursor: MaterialStateMouseCursor.clickable,
            child: GestureDetector(
              onTap: () => _onSelect(index),
              child: CustomSquareCard(
                width: boxWidth,
                height: 60,
                title:
                    '${knowList.elementAt(index)['name'] ?? ''} Навык: ${knowList.elementAt(index)['skill'] ?? ''}\n${knowList.elementAt(index)['result'] ?? ''} ',
                leftText: '',
                // leftColor: resultColor(knowList.elementAt(index)['result']!),
                rightText: get_period_by_value(knowList[index]['when']),
                rightColor: Colors.green.shade800,
                selected: _selectedKnow == index,
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
    widget.provider.controllerByName('know_name').removeListener(_rebuild);
    widget.provider.controllerByName('know_skill').removeListener(_rebuild);
    widget.provider.controllerByName('know_when').removeListener(_rebuild);
    widget.provider.controllerByName('know_result').removeListener(_rebuild);
    widget.provider.controllerByName('want_tip').removeListener(_rebuild);

    // widget.provider.controllerByName('know_name').dispose();
    // widget.provider.controllerByName('know_skill').dispose();
    // widget.provider.controllerByName('know_result').dispose();
    _scrollController.dispose();
    super.dispose();
  }

  resultShortText(String value) {
    switch (value) {
      case 'Сильным навыком':
        return 'Сильный';
      case 'Слабым навыком':
        return 'Слабый';
    }
  }

  Color resultColor(String value) {
    switch (value) {
      case 'Сильным навыком':
        return Color(0xFF3EAC5D); //Color.fromARGB(a, r, g, b); 3EAC5D
      case 'Слабым навыком':
        return Color(0xFFF76D12); // Colors.orange;
    }
    return Colors.grey;
  }
}
