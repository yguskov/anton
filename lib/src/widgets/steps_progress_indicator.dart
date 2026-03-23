import 'package:flutter/material.dart';

import '../../example.dart';

class StepsProgressIndicator extends StatelessWidget {
  const StepsProgressIndicator({
    Key? key,
    this.duration = const Duration(milliseconds: 150),
    required this.count,
    required this.index,
  })  : assert(index >= 0),
        assert(index < count),
        super(key: key);

  final Duration duration;
  final int count;
  final int index;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      height: 25,
      // width: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: stepMenuIconFiles.length,
        itemBuilder: (itemContext, itemIndex) {
          String iconFile = stepMenuIconFiles[itemIndex];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.5, vertical: 2.5),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: itemIndex > index ? Colors.white : cardColorOkBorder,
                  foregroundColor: wizardProgressIconColor,
                  shape: CircleBorder(),
                  // padding: EdgeInsets.all(3),
                  minimumSize: Size(20, 20), // Минимальный размер
                  fixedSize: Size(20, 20),
                  padding: EdgeInsets.zero, // Фиксированный размер (Flutter 3.0+)
                  elevation: 0.5),
              onPressed: () {},
              child: ImageIcon(
                color: itemIndex > index ? wizardProgressIconColor : Colors.white,
                AssetImage('image/icons/${iconFile}'),
                size: 10,
              ),
              // IconButton автоматически круглый с радиусом 20
            ),
          );
        },
      ),
    );
  }
}
