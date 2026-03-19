import 'dart:math';

import 'package:example/example.dart';
import 'package:flutter/material.dart';

class CustomSquareCard extends StatelessWidget {
  final String title;
  final String? leftText;
  final String? rightText;
  final String? bottomTitle;
  final String? bottomText;
  // final double width;
  final double height;
  final Color? leftColor;
  final Color? rightColor;
  final bool selected;

  const CustomSquareCard({
    Key? key,
    required this.title,
    width = 250,
    this.height = 60,
    this.leftText,
    this.rightText,
    this.leftColor = Colors.grey,
    this.rightColor = Colors.grey,
    this.selected = false,
    this.bottomTitle,
    this.bottomText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    // left badge
    if (leftText != null && leftText != '') {
      children.add(Positioned(
        top: -10,
        left: 10,
        child: Container(
          height: 25,
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: leftColor ?? cardColorOk,
            border: Border.all(
              color: (leftColor != cardColorOk) ? Colors.transparent : cardColorOkBorder,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              leftText!,
              style: TextStyle(
                  fontSize: 12,
                  color: (leftColor != cardColorOk) ? Colors.white : cardColorOkBorder),
            ),
          ),
        ),
      ));
    }
    // right badge
    if (rightText != null && rightText != '') {
      children.add(
        Positioned(
          top: -10,
          right: cardRemoveButtonWidth + 10,
          child: Container(
            height: 25,
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: cardBackColorLevel[
                  max(0, cardColorLevel.indexOf(rightColor ?? cardColorLevel[0]))],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(' $rightText ',
                  style: TextStyle(
                      fontSize: 12,
                      color: (rightColor != cardColorLevel[0]) ? rightColor : cardColorLevel[0])),
            ),
          ),
        ),
      );
    }
    // badge stack container
    Widget mainContainer = Container(
      height: 20,
      decoration: BoxDecoration(),
      child: Stack(
        clipBehavior: Clip.none,
        children: children,
      ),
    );

    // card container
    return ConstrainedBox(
      // Минимальная высота блока
      constraints: const BoxConstraints(
        minHeight: 60,
      ),
      child: Container(
        // padding: const EdgeInsets.all(16.0),
        // border arround card
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9.0),
          border: Border.all(
            color: selected ? Color(0xff0042c5) : cardBorderColor,
            width: selected ? 1 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: selected ? Color(0xffc7e4f0) : Colors.white.withOpacity(1.0),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Высота колонки подстраивается под контент
          children: [
            mainContainer, // badges
            const SizedBox(height: 2),
            // Flexible позволяет тексту занимать всю доступную высоту
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // main text container
                  Flexible(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: cardBorderColor,
                            width: 1.0,
                            style: BorderStyle.solid,
                          ),
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 15,
                              // fontWeight: FontWeight.bold,
                              // color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // button to delete
                  Container(
                      width: cardRemoveButtonWidth,
                      child: IconButton(
                        onPressed: () {},
                        icon: ImageIcon(
                          AssetImage('image/icons/trash.png'),
                          size: 20,
                        ),
                        color: Color(0xffc4cee0),
                      ))
                ],
              ),
            ),
            const SizedBox(height: 5),
            bottomText != null
                ? Flexible(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(9),
                          bottomRight: Radius.circular(9),
                        ),
                        color: Color(0xff47b33d),
                      ),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.only(top: 0, left: 10, right: 10, bottom: 5),
                          child: Text(
                            bottomText!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              // fontWeight: FontWeight.bold,
                              // color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );

    // var borderSide = BorderSide(
    //   color: selected ? Colors.red.shade300 : Colors.blueGrey,
    //   width: selected ? 2 : 1.2,
    // );
  }
}
