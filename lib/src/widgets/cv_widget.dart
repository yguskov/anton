import 'package:example/src/src.dart';
import 'package:example/src/utils.dart';
import 'package:flutter/material.dart';
import 'package:markup_text/markup_text.dart';

import '../../models/cv.dart';
import 'custom_card.dart';

class CVWidget extends StatefulWidget {
  final CV cv;

  const CVWidget({
    super.key, // Flutter 3.0+ syntax (replaces `Key? key`)
    required this.cv,
  });

// http://localhost:44374/#/review/d59rh3pams3u9gk3eto0

  // show list of cards

  @override
  State<StatefulWidget> createState() {
    return CVWidgetState();
  }
}

class CVWidgetState extends State<CVWidget> {
  Map<String, Map<String, String>> categories = {
    'duty': {'1': 'Предпочитаемые', '-1': 'Нежелательные', '0': 'Дополнительные'},
    'achieve': {'1': 'Месяц назад', '3': '3 мес. назад', '6': 'Полгода', '12': 'Год и более'},
  };

  Map<String, Set<String>> selectedCategories = {
    'duty': {},
    'skill': {},
    'know': {},
    'achieve': {}
  };

  List<Map<String, String>> filterCards(category) {
    print('----- ${category} -----: ${selectedCategories['duty']} ');
    if (selectedCategories[category] == null) {
      return widget.cv.getList(category);
    }

    return widget.cv.getList(category).where((item) {
      print('----- ${selectedCategories[category]} -----: ${item} ');
      return selectedCategories[category]!.isEmpty ||
          (category == 'duty' && selectedCategories[category]!.contains(item['attitude'])) ||
          (category == 'achieve' && selectedCategories[category]!.contains(item['when']));
    }).toList();
  }

  void toggleCategory(String category, String value) {
    setState(() {
      if (selectedCategories[category]!.contains(value)) {
        selectedCategories[category]!.remove(value);
      } else {
        selectedCategories[category]!.add(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final CV cv = widget.cv;

    print('------------- BUILD-CV------------------');
    print(widget.cv.toJson());
    const h1 = 20.0;

    return Column(children: [
      // Text(cv.toJson()),
      const SizedBox(height: h1),
      Text('Кому: ${cv.getValue('boss_fio')}'),
      const SizedBox(height: h1),
      MarkupText('От кого: ${cv.getValue('fio')} ((b)${cv.getValue('position')}(/b))'),
      // Text('От кого: ${cv.getValue('fio')} (${cv.getValue('position')})'),
      const SizedBox(height: h1),

      listCard(
        title: 'Мои текущие обязанности:',
        list: cv.duty,
        category: 'duty',
        centerTextCallBack: (item) {
          return '${item['name'] ?? ''}  \n**${ucfirst(item['period']) ?? ''}**';
        },
        leftTextCallBack: (item) {
          switch (item['attitude'] ?? '') {
            case '-1':
              return 'Не нравится';
            case '0':
              return '';
            case '1':
              return 'Нравится';
          }
          return '';
        },
        rightTextCallBack: (item) =>
            item['type'] == 'new' ? 'Новая' : (item['type'] == 'extra' ? 'Дополнительная' : ''),
        leftColorCallBack: (item) {
          switch (item['attitude']!) {
            case '-1':
              return cardColorDislike;
            case '0':
              return cardColorOk;
            case '1':
              return cardColorLike;
          }
          return cardColorOk;
        },
        rightColorCallBack: (item) {
          return item['type'] == 'new' ? cardColorLevel[3] : cardColorLevel[1];
        },
      ),
      const SizedBox(height: h1),

      listCard(
        title: 'В данный момент я обладаю навыками:',
        list: cv.skill,
        category: 'skill',
        centerTextCallBack: (item) => '${item['name'] ?? ''}. ${item['type'] ?? ''}',
        leftTextCallBack: (item) {
          if ((item['power'] ?? '').toLowerCase().contains('сильн')) {
            return 'сильный';
          }
          if ((item['power'] ?? '').toLowerCase().contains('слаб')) {
            return 'слабый';
          }
          return '';
        },
        leftColorCallBack: (item) {
          if ((item['power'] ?? '').toLowerCase().contains('сильн')) {
            return Colors.green.shade800;
          }
          if ((item['power'] ?? '').toLowerCase().contains('слаб')) {
            return Colors.orange;
          }
          return Colors.grey;
        },
        rightTextCallBack: (item) => 'Уровень ${item['level']}',
        rightColorCallBack: (item) => Color(0xFF5B32332),
      ),
      const SizedBox(height: h1),

      listCard(
        title: 'Последнее время я развивал свои навыки следующим образом:',
        list: cv.know,
        category: 'know',
        centerTextCallBack: (item) => item['name'] ?? '',
        leftTextCallBack: (item) => item['skill'] ?? '',
        leftColorCallBack: (item) => Color(0xFF5801fd),
        rightTextCallBack: (item) => '${item['when']} мес. назад',
        rightColorCallBack: (item) => Color(0xFF5B32332),
        bottomTitleCallBack: (item) => 'Польза',
        bottomTextCallBack: (item) => item['result'] ?? '',
      ),
      const SizedBox(height: h1),

      listCard(
        title: 'Я смог добиться выдающихся результатов:',
        list: cv.achieve,
        category: 'achieve',
        centerTextCallBack: (item) => item['name'] ?? '',
        rightTextCallBack: (item) => '${item['when']} мес. назад',
        rightColorCallBack: (item) => Color(0xFF5B32332),
        bottomTitleCallBack: (item) => 'Польза',
        bottomTextCallBack: (item) => item['result'] ?? '',
      ),
      const SizedBox(height: h1),
      Text('У меня есть Цель, я хочу ${cv.getValue('aim')}'),
      const SizedBox(height: h1),
      Text('Я заслуживаю её потому, что я ${cv.getValue('why')}'),
      const SizedBox(height: h1),
      Text('Предлагаю назначить встречу и обсудить возможности или альтернативные варианты.'),
    ]);
  }

  listCard({
    String category = '', // name of list attribute in CV model (duty, ...)
    required title,
    required List<Map<String, String>> list,
    required String Function(Map<String, String>) centerTextCallBack,
    String Function(Map<String, String>)? leftTextCallBack,
    Color Function(Map<String, String>)? leftColorCallBack,
    String Function(Map<String, String>)? rightTextCallBack,
    Color Function(Map<String, String>)? rightColorCallBack,
    String Function(Map<String, String>)? bottomTitleCallBack,
    String Function(Map<String, String>)? bottomTextCallBack,
  }) {
    double h1 = 20;
    const headerStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 19.0);

    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      double boxWidth = 250;
      if (constraints.maxWidth < screenSide600) {
        boxWidth = constraints.maxWidth;
      } else {}

      return Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              title,
              style: headerStyle,
            ),
          ),
          SizedBox(height: h1),
          categories[category] == null
              ? SizedBox(
                  height: 0,
                )
              : Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Кнопка "Все"
                      CategoryChip(
                        label: 'Все',
                        isSelected: selectedCategories[category]!.isEmpty,
                        onTap: () {
                          setState(() {
                            selectedCategories[category]!.clear();
                          });
                        },
                      ),
                      // Остальные категории
                      ...categories[category]!.entries.map((entry) => CategoryChip(
                            label: entry.value,
                            isSelected: selectedCategories[category]!.contains(entry.key),
                            onTap: () => toggleCategory(category, entry.key),
                            // backgroundColor: Colors.grey.shade100,
                            // selectedColor: Colors.blue.shade100,
                          )),
                    ],
                  ),
                ),
          SizedBox(height: h1),
          AdaptiveCardTable(cards: [
            for (var item in filterCards(category))
              CustomSquareCard(
                  width: boxWidth,
                  height: 60,
                  title: centerTextCallBack(item),
                  leftText: leftTextCallBack?.call(item),
                  leftColor: leftColorCallBack != null ? leftColorCallBack(item) : null,
                  rightText: rightTextCallBack != null ? rightTextCallBack(item) : null,
                  rightColor: rightColorCallBack!(item),
                  bottomTitle: bottomTitleCallBack != null ? bottomTitleCallBack(item) : null,
                  bottomText: bottomTextCallBack != null ? bottomTextCallBack(item) : null,
                  selected: false,
                  mode: CardMode.preview)
          ]),
        ],
      );
    });
  }
}

class CategoryChip extends StatelessWidget {
  // final String category;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    Key? key,
    // required this.category,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.grey.shade100,
      selectedColor: Colors.blue.shade100,
      checkmarkColor: Colors.blue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.blue.shade700 : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? Colors.blue : Colors.grey.shade300,
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6), // Радиус 6
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
