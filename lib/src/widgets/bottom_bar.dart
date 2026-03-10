import 'package:flutter/material.dart';
import 'package:flutter_wizard/flutter_wizard.dart';

import '../../example.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({Key? key}) : super(key: key);

  @override
  Widget build(
    BuildContext context,
  ) {
    Widget sponsorBox = Container(
      height: bottomHeight,
      padding: EdgeInsets.all(15),
      color: bottomGroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Если вам нравится наш сайт, то оставьте серверу на кофе',
              style: bottomTextStyle, textAlign: TextAlign.center),
          ElevatedButton(onPressed: () => false, child: Text('Стать спонсором'))
        ],
      ),
    );
    Widget mailBox = Container(
      height: bottomHeight,
      padding: EdgeInsets.all(15),
      color: bottomGroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Text('По вопросам сотрудничества или просто для связи пишите',
                  style: bottomTextStyle, textAlign: TextAlign.center)),
          ElevatedButton(onPressed: () => false, child: Text('mail@mail.ru'))
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth <= 600;
        return !narrow
            ? Container(
                color: bottomGroundColor,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 1, child: sponsorBox),
                    Container(
                      height: 80,
                      width: 1,
                      color: Colors.black,
                    ),
                    Expanded(flex: 1, child: mailBox)
                  ],
                ),
              )
            : Container();
      },
    );
  }

  _buildPreviewButton(BuildContext context) {
    return ElevatedButton(
      child: const Text("Предпросмотр"),
      onPressed: () => false,
      style: OutlinedButton.styleFrom(
        // backgroundColor: Color(0xFF5801fd), // Цвет фона
        foregroundColor: Colors.black54, // Цвет текста
        // foregroundColor: Colors.white, // Цвет текста
        side: BorderSide(color: Colors.black12), // Цвет границы
      ),
    );
  }
}
