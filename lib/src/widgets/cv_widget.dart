import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:markup_text/markup_text.dart';

import '../../models/cv.dart';
import 'custom_card.dart';

class CVWidget extends StatelessWidget {
  final CV cv;

  const CVWidget({
    super.key, // Flutter 3.0+ syntax (replaces `Key? key`)
    required this.cv,
  });

  @override
  Widget build(BuildContext context) {
    print('------------- BUILD-CV------------------');
    print(cv.toJson());
    const h1 = 20.0;

    return Column(children: [
      // Text(cv.toJson()),
      const SizedBox(height: h1),
      Text('Кому: ${cv.getValue('boss_fio')}'),
      const SizedBox(height: h1),
      MarkupText(
          'От кого: ${cv.getValue('fio')} ((b)${cv.getValue('position')}(/b))'),
      // Text('От кого: ${cv.getValue('fio')} (${cv.getValue('position')})'),
      const SizedBox(height: h1),

      listCard(
        title: 'Мои текущие обязанности:',
        list: cv.duty,
        centerTextCallBack: (item) {
          return '${item['name'] ?? ''} , ${item['period'] ?? ''}';
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
        rightTextCallBack: (item) => item['type'] == 'new'
            ? 'Новая'
            : item['type'] == 'extra'
                ? 'Дополнительная'
                : 'Основная',
        leftColorCallBack: (item) {
          switch (item['attitude'] ?? '') {
            case '-1':
              return Colors.orange;
            case '0':
              return Colors.grey;
            case '1':
              return Colors.green.shade800;
          }
          return Colors.grey;
        },
        rightColorCallBack: (item) {
          return (item['type'] ?? '') == 'new'
              ? Colors.green.shade800
              : Color(0xFF5801fd);
        },
      ),
      const SizedBox(height: h1),

      listCard(
        title: 'В данный момент я обладаю навыками:',
        list: cv.skill,
        centerTextCallBack: (item) =>
            '${item['name'] ?? ''}. ${item['type'] ?? ''}',
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
      Text(
          'Предлагаю назначить встречу и обсудить возможности или альтернативные варианты.'),
    ]);
  }

// http://localhost:44374/#/review/d59rh3pams3u9gk3eto0

  // show list of cards
  listCard({
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

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      double boxWidth;
      if (constraints.maxWidth < 600) {
        boxWidth = constraints.maxWidth;
      } else {
        boxWidth = constraints.maxWidth / 2 - 5;
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
          Wrap(
              spacing: 10, // горизонтальный отступ между блоками
              runSpacing: 10, // вертикальный отступ между строками
              children: [
                for (var item in list)
                  CustomSquareCard(
                    width: boxWidth,
                    height: 60,
                    title: centerTextCallBack(item),
                    leftText: leftTextCallBack?.call(item),
                    leftColor: leftColorCallBack != null
                        ? leftColorCallBack(item)
                        : null,
                    rightText: rightTextCallBack != null
                        ? rightTextCallBack(item)
                        : null,
                    rightColor: rightColorCallBack!(item),
                    bottomTitle: bottomTitleCallBack != null
                        ? bottomTitleCallBack(item)
                        : null,
                    bottomText: bottomTextCallBack != null
                        ? bottomTextCallBack(item)
                        : null,
                    selected: false,
                  )
              ]),
        ],
      );
    });
  }
}
