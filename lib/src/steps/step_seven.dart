import 'dart:js_interop';

import 'package:example/src/steps/steps.dart';
import 'package:flutter/material.dart';

import '../widgets/custom_card.dart';
import '../widgets/dropdown_field.dart';
import 'my_wizard_step.dart';

class StepSeven extends StatefulWidgetStep {
  final StepSevenProvider myProvider;

  StepSeven({
    required StepSevenProvider provider,
    Key? key,
  })  : myProvider = provider,
        super(key: key, provider: provider);

  @override
  State<StepSeven> createState() => _StepSevenState();
}

class _StepSevenState extends StateStep<StepSeven> {
  List<Map<String, String>> get achieveList => widget.myProvider.achieveList;
  int? _selectedAchieve;

  List<PopupDropdownItem<String>> get period_list => [
        PopupDropdownItem(value: '1', label: 'месяц назад'),
        PopupDropdownItem(value: '3', label: 'квартал назад'),
        PopupDropdownItem(value: '6', label: 'полгода назад'),
        PopupDropdownItem(value: '12', label: 'год назад'),
      ];

  String get_period_by_value(val) {
    try {
      print(period_list.singleWhere((item) {
        return item.value == val;
      }));
      return period_list.singleWhere((item) => item.value == val).label;
    } catch (e) {
      return '';
    }
  }

  @override
  void initState() {
    super.initState();
    // Подписываемся на изменения всех полей
    widget.provider.controllerByName('achieve_name').addListener(_rebuild);
    widget.provider.controllerByName('achieve_result').addListener(_rebuild);
    widget.provider.controllerByName('achieve_when').addListener(_rebuild);
  }

  // select paticular achieve
  void _onSelect(int? index) {
    setState(() {
      _selectedAchieve = index;
      widget.provider.controllerByName('achieve_name').text =
          index.isDefinedAndNotNull ? achieveList[index!]['name']! : '';
      widget.provider.controllerByName('achieve_result').text =
          index.isDefinedAndNotNull ? achieveList[index!]['result']! : '';
      widget.provider.controllerByName('achieve_when').text =
          index.isDefinedAndNotNull ? achieveList[index!]['when']! : '';
      widget.provider.updateValue('achieve_name',
          index.isDefinedAndNotNull ? achieveList[index!]['name']! : '');
      widget.provider.updateValue('achieve_result',
          index.isDefinedAndNotNull ? achieveList[index!]['result']! : '');
      widget.provider.updateValue('achieve_when',
          index.isDefinedAndNotNull ? achieveList[index!]['when']! : '');
    });
  }

  // save achieve
  void _save() {
    Map<String, String> currentAchieve;
    setState(() {
      currentAchieve = {
        'name': widget.provider.getValue('achieve_name'),
        'result': widget.provider.getValue('achieve_result'),
        'when': widget.provider.getValue('achieve_when'),
      };

      if (_selectedAchieve.isNull) {
        achieveList.add(currentAchieve);
      } else {
        achieveList[_selectedAchieve!] = currentAchieve;
      }

      widget.provider.controllerByName('achieve_name').text = '';
      widget.provider.controllerByName('achieve_result').text = '';
      widget.provider.controllerByName('achieve_when').text = '';
      widget.provider.updateValue('achieve_name', '');
      widget.provider.updateValue('achieve_result', '');
      widget.provider.updateValue('achieve_when', '');
    });

    // Delay slightly to ensure layout is updated
    if (_selectedAchieve.isNull) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } else {
      _selectedAchieve = null;
    }
  }

  // remove Achieve
  void _remove() {
    setState(() {
      achieveList.removeAt(_selectedAchieve!);
      widget.provider.controllerByName('achieve_name').text = '';
      widget.provider.controllerByName('achieve_result').text = '';
      widget.provider.controllerByName('achieve_when').text = '';
      widget.provider.updateValue('achieve_name', '');
      widget.provider.updateValue('achieve_result', '');
      widget.provider.updateValue('achieve_when', '');
      _selectedAchieve = null;
    });
  }

  List<String>? get achieves => [
        'Научился ...',
      ];

  bool get saveEnabled =>
      widget.provider.getValue('achieve_name').isNotEmpty &&
      widget.provider.getValue('achieve_result').isNotEmpty &&
      widget.provider.getValue('achieve_when').isNotEmpty;

  bool get removeEnabled => !_selectedAchieve.isNull;

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
        Text('Ваши успехи и достижения', style: headerStyle),
        const SizedBox(height: 6),
        Text(
            'Напомните реальными примерами какую пользу вы принесли и как повлияли на других',
            style: headerStyle2),
        const SizedBox(height: 16),
        buildTextFieldWithLabel('Каких выдающихся успехов вы добились?',
            'Научился мести двумя руками', 'achieve_name', achieves),
        const SizedBox(height: 16),
        // result
        buildTextFieldWithLabel(' Какую пользу это принесло компании?',
            'Увеличил продуктивность на 15%', 'achieve_result'),
        const SizedBox(height: 16),
        buildDropdownSection('Когда это произошло?', 'Х месяцев назад',
            'achieve_when', period_list),
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
                  backgroundColor:
                      saveEnabled ? Color(0xFFF76D12) : Colors.black87,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildAchieveList(constraints),
      ];

      return ListView(
        controller: _scrollController,
        children: textFields,
      );
    });
  }

  _buildAchieveList(BoxConstraints constraints) {
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
        spacing: 10,
        runSpacing: 10,
        children: List.generate(achieveList.length, (index) {
          return MouseRegion(
            cursor: MaterialStateMouseCursor.clickable,
            child: GestureDetector(
              onTap: () => _onSelect(index),
              child: CustomSquareCard(
                width: boxWidth,
                height: 60,
                title:
                    '${achieveList.elementAt(index)['name'] ?? ''}\n ${achieveList.elementAt(index)['result'] ?? ''} ',
                leftText: '',
                // leftColor: resultColor(achieveList.elementAt(index)['result']!),
                rightText: get_period_by_value(achieveList[index]['when']),
                rightColor: Colors.green.shade800,
                selected: _selectedAchieve == index,
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
    widget.provider.controllerByName('achieve_name').removeListener(_rebuild);
    widget.provider.controllerByName('achieve_skill').removeListener(_rebuild);
    widget.provider.controllerByName('achieve_when').removeListener(_rebuild);
    widget.provider.controllerByName('achieve_result').removeListener(_rebuild);
    widget.provider.controllerByName('want_tip').removeListener(_rebuild);

    // widget.provider.controllerByName('achieve_name').dispose();
    // widget.provider.controllerByName('achieve_skill').dispose();
    // widget.provider.controllerByName('achieve_result').dispose();
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
