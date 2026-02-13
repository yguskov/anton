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
    // children.add(Align(
    //   alignment: Alignment.topLeft,
    //   child: Padding(
    //     padding: EdgeInsets.only(top: 10, left: 5),
    //     child: ,
    //   ),
    // ));

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
      // width: width,
      height: 20,
      decoration: BoxDecoration(
          // color: Colors.grey[300], // серый фон
          // border: Border.all(
          //   color: selected ? Colors.red.shade300 : Colors.blueGrey,
          //   width: selected ? 2 : 1.2,
          // ),
          // borderRadius: BorderRadius.circular(4), // скругление
          ),
      child: Stack(
        children: children,
      ),
    );

    return ConstrainedBox(
      // Минимальная высота блока
      constraints: const BoxConstraints(
        minHeight: 60,
      ),
      child: Container(
        // padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 189, 193, 197),
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(
            color: selected ? Color.fromARGB(255, 207, 87, 87) : Colors.blueGrey,
            width: selected ? 2 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
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
            mainContainer,
            const SizedBox(height: 2),
            // Flexible позволяет тексту занимать всю доступную высоту
            Flexible(
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
            const SizedBox(height: 5),
            bottomText != null
                ? Flexible(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: EdgeInsets.only(top: 0, left: 10, right: 10, bottom: 10),
                        child: Text(
                          bottomText!,
                          style: const TextStyle(
                            fontSize: 15,
                            // fontWeight: FontWeight.bold,
                            // color: Colors.blue,
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
