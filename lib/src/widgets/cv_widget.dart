import 'package:example/providers/auth_provider.dart';
import 'package:example/src/src.dart';
import 'package:example/src/utils.dart';
import 'package:flutter/material.dart';
import 'package:markup_text/markup_text.dart';
import 'package:provider/provider.dart';

import '../../models/cv.dart';
import 'custom_card.dart';

class CVWidget extends StatefulWidget {
  final CV cv;
  final String? guid;

  const CVWidget(
      {super.key, // Flutter 3.0+ syntax (replaces `Key? key`)
      required this.cv,
      this.guid});

// http://localhost:44374/#/review/d59rh3pams3u9gk3eto0

  // show list of cards

  @override
  State<StatefulWidget> createState() {
    return CVWidgetState();
  }
}

class CVWidgetState extends State<CVWidget> {
  Map<String, Map<String, String>> categories = {
    'duty': {'1': 'Предпочитаемые', '-1': 'Нежелательные', 'extra': 'Дополнительные'},
    'skill': {'Сильным навыком': 'Сильный', 'Слабым навыком': 'Слабый'},
    'know': {'1': 'Месяц назад', '3': '3 мес. назад', '6': 'Полгода', '12': 'Год и более'},
    'achieve': {'1': 'Месяц назад', '3': '3 мес. назад', '6': 'Полгода', '12': 'Год и более'},
  };

  Map<String, Set<String>> selectedCategories = {
    'duty': {},
    'skill': {},
    'know': {},
    'achieve': {}
  };

  final TextEditingController _resultDescController = TextEditingController();

  get commonTextStyle => TextStyle(fontSize: 20); // common text

  List<Map<String, String>> filterCards(category, [type]) {
    print('----- ${category} -----: ${selectedCategories['duty']} ');
    if (selectedCategories[category] == null) {
      return widget.cv.getList(category);
    }

    return widget.cv.getList(category).where((item) {
      print('----- ${selectedCategories[category]} -----: ${item} ');
      if (type != null && item['type'] != type) {
        return false;
      }
      return selectedCategories[category]!.isEmpty ||
          (category == 'duty' &&
              (selectedCategories[category]!.contains(item['attitude']) ||
                  selectedCategories[category]!.contains(item['type']))) ||
          (category == 'skill' && selectedCategories[category]!.contains(item['power'])) ||
          ((category == 'achieve' || category == 'know') &&
              selectedCategories[category]!.contains(item['when']));
    }).toList()
      ..sort((a, b) {
        if ((category == 'duty' || category == 'skill') && a['type'] != null && b['type'] != null)
          return a['type']!.compareTo(b['type']!);
        if ((category == 'know' || category == 'achieve') && a['when'] != null && b['when'] != null)
          return int.parse(a['when']!) - int.parse(b['when']!);
        return 0;
      });
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
    const h1 = 19.0;

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      // Text(cv.toJson()),
      const SizedBox(height: h1),
      MarkupText(
        'Кому: (b)${cv.getValue('boss_fio')}(/b)',
        style: commonTextStyle,
      ),
      const SizedBox(height: h1),
      MarkupText('От кого: (b)${cv.getValue('fio')} (${cv.getValue('position')}(/b))',
          style: commonTextStyle),
      // Text('От кого: ${cv.getValue('fio')} (${cv.getValue('position')})'),
      const SizedBox(height: h1),

      listCard(
        title: 'Моя ответственность:',
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
            return Color(0xFFF76D12);
          }
          return Colors.grey;
        },
        rightTextCallBack: (item) => 'Уровень ${item['level'] != '0' ? item['level'] : 'Не знаю'}',
        rightColorCallBack: (item) => Color(0xFF5B32332),
      ),
      const SizedBox(height: h1),

      listCard(
        title: 'Последнее время я развивал свои навыки следующим образом:',
        list: cv.know,
        category: 'know',
        centerTextCallBack: (item) => '${item['name'] ?? ''}  \n**Навык: ${item['skill'] ?? ''}**',
        leftTextCallBack: (item) => '${item['when']} мес. назад',
        leftColorCallBack: (item) => cardColorOk,
        rightTextCallBack: (item) => '',
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
        leftTextCallBack: (item) => '${item['when']} мес. назад',
        leftColorCallBack: (item) => cardColorOk,
        rightTextCallBack: (item) => '',
        rightColorCallBack: (item) => Color(0xFF5B32332),
        bottomTitleCallBack: (item) => 'Польза',
        bottomTextCallBack: (item) => item['result'] ?? '',
      ),
      const SizedBox(height: h1),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
                side: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(h1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MarkupText('У меня есть цель, я хочу:', style: commonTextStyle),
                    SizedBox(height: h1),
                    MarkupText('(b)${cv.getValue('aim')}(/b)', style: commonTextStyle),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: h1),
          Expanded(
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
                side: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(h1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MarkupText('Я заслуживаю её потому, что я', style: commonTextStyle),
                    SizedBox(height: h1),
                    MarkupText('(b)${cv.getValue('why')}(/b)', style: commonTextStyle),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      const SizedBox(height: h1),
      // set assign result buttons
      Padding(
        padding: EdgeInsets.symmetric(vertical: h1, horizontal: h1),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _openManagerReactDialog(context, false),
                child: Text('Разьяснить отказ'),
                style: ElevatedButton.styleFrom(
                  elevation: 0.5,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 19,
                  ),
                  backgroundColor: cardColorDislike,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            SizedBox(width: h1),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _openManagerReactDialog(context, true),
                child: Text('Можно обсудить'),
                style: ElevatedButton.styleFrom(
                  elevation: 0.5,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 19,
                  ),
                  backgroundColor: secondaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      // view assign result
      if (cv.getValue('assign') != null)
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
            side: BorderSide(
              color: cv.getValue('assign') == 1 ? cardColorLike : cardColorDislike,
              width: 1,
            ),
          ),
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(h1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                cv.getValue('assign') == 1
                    ? MarkupText('(b)Результат:(/b) (c #47b33d)Положительный(/c)',
                        style: commonTextStyle)
                    : MarkupText('(b)Результат:(/b) (c #cd3735)Отрицательный(/c)',
                        style: commonTextStyle),
                SizedBox(height: h1),
                MarkupText('${cv.getValue('comment')}', style: commonTextStyle),
              ],
            ),
          ),
        ),
      // Text('Я заслуживаю её потому, что я ${cv.getValue('why').toLowerCase()}',
      //     style: commonTextStyle),
      // const SizedBox(height: h1),
      // Text('Предлагаю назначить встречу и обсудить возможности или альтернативные варианты.',
      //     style: commonTextStyle),
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

    Widget sectionCards(sectionData, boxWidth) {
      return AdaptiveCardTable(
          cards: sectionData.map<CustomSquareCard>((item) {
        return CustomSquareCard(
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
            mode: CardMode.preview);
      }).toList());
    }

    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      double boxWidth = 250;
      if (constraints.maxWidth < screenSide600) {
        boxWidth = constraints.maxWidth;
      }

      Widget cardsContent;
      if (category == 'duty') {
        List<Widget> dutySection = [];
        List<Map<String, String>> sectionData;
        sectionData = filterCards('duty', 'base');
        if (sectionData.length > 0) {
          dutySection
              .add(Align(alignment: Alignment.topLeft, child: Text('Мои текущие обязанности')));
          dutySection.add(SizedBox(height: h1));
          dutySection.add(sectionCards(sectionData, boxWidth));
        }
        sectionData = filterCards('duty', 'new');
        if (sectionData.length > 0) {
          dutySection.add(Align(
              alignment: Alignment.topLeft,
              child: Text('Я уже выполняю дополнительные обязанности')));
          dutySection.add(SizedBox(height: h1));
          dutySection.add(sectionCards(sectionData, boxWidth));
        }
        sectionData = filterCards('duty', 'extra');
        if (sectionData.length > 0) {
          dutySection.add(Align(
              alignment: Alignment.topLeft,
              child: Text('Готов взять на себя больше ответственности')));
          dutySection.add(SizedBox(height: h1));
          dutySection.add(sectionCards(sectionData, boxWidth));
        }
        cardsContent = Column(children: dutySection);
      } else {
        cardsContent = AdaptiveCardTable(cards: [
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
        ]);
      }

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
          // categories
          categories[category] == null
              ? SizedBox(
                  height: 0,
                )
              : Container(
                  alignment: Alignment.topLeft,
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
          // cards
          cardsContent,
        ],
      );
    });
  }

  Future<void> _openManagerReactDialog(BuildContext context, bool assign) async {
    double h20 = 20;

    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(assign ? 'Можно обсудить наши возможности' : 'Разъяснение'),
          contentPadding: EdgeInsets.all(h20),
          // insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: baseScreenWidth / 2,
              maxWidth: baseScreenWidth,
            ),
            child: TextFormField(
              controller: _resultDescController,
              decoration: inputDecoration(
                assign
                    ? 'Можете оставить комментарий, либо назначить встречу'
                    : 'Можете оставить комментарий',
              ),
              autofocus: true,
              minLines: 3,
              maxLines: 3,
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.all(h20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Отмена'),
                      // style: ElevatedButton.styleFrom(backgroundColor: cardAddButtonBackColor)
                    ),
                  ),
                  SizedBox(width: h20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => sendManagerResult(context, assign),
                      child: Text('Сохранить'),
                    ),
                  ),
                ],
              ),
            ),
          ],
          actionsPadding: EdgeInsets.zero,
          actionsAlignment: MainAxisAlignment.center,
        );
      },
    );
  }

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      hintText: label,
      filled: true,
      fillColor: Colors.white,
      floatingLabelStyle: TextStyle(color: Colors.grey[800]),
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
    );
  }

  sendManagerResult(BuildContext context, bool assign) async {
    final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (await authProvider.saveResult(widget.guid ?? authProvider.currentUser!.guid,
        assign ? 1 : -1, _resultDescController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ok')));
    }
    Navigator.pop(context);
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
      backgroundColor: Colors.white,
      // selectedColor: Colors.blue.shade100,
      selectedColor: Colors.white,
      checkmarkColor: Colors.black,
      // checkmarkColor: Colors.grey.shade700,
      // checkmarkColor: Colors.blue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? Colors.black : Colors.grey.shade300,
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6), // Радиус 6
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
