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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: stepMenuIconFiles.asMap().entries.map((entry) {
          int itemIndex = entry.key;
          String iconFile = entry.value;

          final isMobile = MediaQuery.of(context).size.width < 711;
          final buttonSize =
              isMobile ? (MediaQuery.of(context).size.width < 375 ? 34.0 : 40.0) : 50.0;

          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (itemIndex > 0) SizedBox(width: 1.0),
              Container(
                width: 0.58 * buttonSize,
                height: buttonSize,
                decoration: BoxDecoration(
                  color: itemIndex > index ? Colors.white : cardColorOkBorder,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1.0,
                  ),
                ),
                child: Center(
                  child: ImageIcon(
                    color: itemIndex > index ? wizardProgressIconColor : Colors.white,
                    AssetImage('image/icons/${iconFile}'),
                    size: buttonSize * 0.25,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
