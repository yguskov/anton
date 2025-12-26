import 'package:flutter/cupertino.dart';

import '../../models/cv.dart';

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
          list: cv.getValue('duty')), // @book CV Card list
      const SizedBox(height: h1),
      Text('У меня есть Цель, я хочу ${cv.getValue('aim')}'),
      const SizedBox(height: h1),
      Text('Я заслуживаю её потому, что я ${cv.getValue('why')}'),
      const SizedBox(height: h1),
      Text(
          'Предлагаю назначить встречу и обсудить возможности или альтернативные варианты.'),
    ]);
  }

  // show list of cards
  listCard({required title, required List<Map<String, String>> list}) {}
}
