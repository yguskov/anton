import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
      Text('От кого: ${cv.getValue('fio')}'),
      const SizedBox(height: h1),
      listCard(
        title: 'Мои текущие обязанности',
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
        rightTextCallBack: (item) {
          return (item['type'] ?? '') == 'new'
              ? 'Новая'
              : (item['type'] == 'extra' ? 'Дополнительная' : '');
        },
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
    required String Function(Map<String, String>) leftTextCallBack,
    required String Function(Map<String, String>) rightTextCallBack,
    required Color Function(Map<String, String>) leftColorCallBack,
    required Color Function(Map<String, String>) rightColorCallBack,
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
                    leftText: leftTextCallBack(item),
                    rightText: rightTextCallBack(item),
                    leftColor: leftColorCallBack(item),
                    rightColor: rightColorCallBack(item),
                    selected: false,
                  )
              ]),
        ],
      );
    });
  }
}
