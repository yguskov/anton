import 'package:flutter/material.dart';

import '../../example.dart';

class StepsProgressIndicator extends StatelessWidget {
  StepsProgressIndicator({
    Key? key,
    this.duration = const Duration(milliseconds: 150),
    required this.count,
    required this.index,
    this.size = 20.0,
    this.padding = 2.5,
  })  : assert(index >= 0),
        assert(index < count),
        super(key: key);

  final Duration duration;
  final int count;
  final int index;
  final double size;
  final double padding;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      height: size + 5,
      // width: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: stepMenuIconFiles.length,
        itemBuilder: (itemContext, itemIndex) {
          String iconFile = stepMenuIconFiles[itemIndex];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: itemIndex > index ? Colors.white : cardColorOkBorder,
                  foregroundColor: wizardProgressIconColor,
                  shape: CircleBorder(),
                  // padding: EdgeInsets.all(3),
                  minimumSize: Size(size, size), // Минимальный размер
                  fixedSize: Size(size, size),
                  padding: EdgeInsets.zero, // Фиксированный размер (Flutter 3.0+)
                  elevation: 0.5),
              onPressed: () {},
              child: ImageIcon(
                color: itemIndex > index ? wizardProgressIconColor : Colors.white,
                AssetImage('image/icons/${iconFile}'),
                size: size / 2,
              ),
              // IconButton автоматически круглый с радиусом 20
            ),
          );
        },
      ),
    );
  }
}
