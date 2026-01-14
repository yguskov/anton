import 'package:flutter/material.dart';

class CustomSquareCard extends StatelessWidget {
  final String title;
  final String? leftText;
  final String? rightText;
  final String? bottomTitle;
  final String? bottomText;
  final double width;
  final double height;
  final Color? leftColor;
  final Color? rightColor;
  final bool selected;

  const CustomSquareCard({
    Key? key,
    required this.title,
    this.width = 250,
    this.height = 100,
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
    children.add(Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.only(top: 10, left: 5),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.normal,
            color: Colors.black87,
          ),
        ),
      ),
    ));

    if (leftText != null && leftText != '') {
      children.add(Positioned(
        bottom: 0,
        left: 0,
        child: Container(
          width: 100,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white70,
            border: Border.all(
              color: leftColor ?? Colors.grey,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              leftText!,
              style: TextStyle(fontSize: 12, color: leftColor),
            ),
          ),
        ),
      ));
    }

    if (rightText != null) {
      children.add(Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          width: 100,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white70,
            border: Border.all(
              color: rightColor ?? Colors.grey,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              rightText!,
              style: TextStyle(fontSize: 12, color: rightColor),
            ),
          ),
        ),
      ));
    }

    Widget mainContainer = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300], // серый фон
        border: Border.all(
          color: selected ? Colors.red.shade300 : Colors.blueGrey,
          width: selected ? 2 : 1.2,
        ),
        borderRadius: BorderRadius.circular(4), // скругление
      ),
      child: Stack(
        children: children,
      ),
    );

    if (bottomText == null) {
      return mainContainer;
    } else {
      var borderSide = BorderSide(
        color: selected ? Colors.red.shade300 : Colors.blueGrey,
        width: selected ? 2 : 1.2,
      );
      Widget bottomContainer = Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300], // серый фон
          border: Border(
              top: BorderSide(
                color: Colors.blueGrey,
                width: 0.6,
              ),
              left: borderSide,
              bottom: borderSide,
              right: borderSide),
          borderRadius: BorderRadius.circular(4), // скругление
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: 100,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white70,
                  border: Border.all(
                    color: Colors.green.shade800,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(1),
                ),
                child: Center(
                  child: Text(
                    bottomTitle ?? ' ',
                    style:
                        TextStyle(fontSize: 12, color: Colors.green.shade800),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(top: 20, left: 5),
                child: Text(
                  bottomText!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                    color: Colors.black87,
                  ),
                ),
              ),
            )
          ],
        ),
      );
      // second long text
      return Column(
        children: [mainContainer, bottomContainer],
      );
    }
  }
}
