import 'package:flutter/material.dart';
import '../../example.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({Key? key}) : super(key: key);

  @override
  Widget build(
    BuildContext context,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth <= 600;
        double _buttonWidth = 340;

        Widget sponsorBox = Container(
          height: bottomHeight,
          padding: EdgeInsets.all(5),
          color: bottomGroundColor,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: _buttonWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('Если вам нравится наш сайт, то оставьте серверу на кофе',
                      style: bottomTextStyle, textAlign: TextAlign.center),
                  ElevatedButton(
                    onPressed: () => false,
                    child: Text('Стать спонсором', style: bottomButtonTextStyle),
                  )
                ],
              ),
            ),
          ),
        );

        Widget mailBox = Container(
          height: bottomHeight,
          padding: EdgeInsets.all(5),
          color: bottomGroundColor,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: _buttonWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('По вопросам сотрудничества или просто для связи пишите',
                      style: bottomTextStyle, textAlign: TextAlign.center),
                  ElevatedButton(
                    onPressed: () => false,
                    child: Text(
                      'mail@mail.ru',
                      style: bottomButtonTextStyle,
                    ),
                  )
                ],
              ),
            ),
          ),
        );

        return !narrow
            ? Container(
                color: bottomGroundColor,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 1, child: sponsorBox),
                    Container(
                      width: 1,
                      height: 80,
                      color: bottomDividerColor,
                    ),
                    Expanded(flex: 1, child: mailBox)
                  ],
                ),
              )
            : Container(
                color: bottomGroundColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    sponsorBox,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        height: 1,
                        color: bottomDividerColor,
                      ),
                    ),
                    mailBox
                  ],
                ),
              );
      },
    );
  }
}
