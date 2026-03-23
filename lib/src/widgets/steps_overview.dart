import 'package:flutter/material.dart';
import 'package:flutter_wizard/flutter_wizard.dart';

import '../../example.dart';

class StepsOverview extends StatelessWidget {
  const StepsOverview({Key? key}) : super(key: key);

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 20.0),
      child: ListView.builder(
        itemCount: context.wizardController.stepControllers.length,
        itemBuilder: (context, index) {
          final step = context.wizardController.stepControllers[index].step;
          return StreamBuilder<bool>(
            stream: context.wizardController.getIsGoToEnabledStream(index),
            initialData: context.wizardController.getIsGoToEnabled(index),
            builder: (context, snapshot) {
              final enabled = snapshot.data!;

              String title = stepTitles[index];
              String iconFile = stepMenuIconFiles[index];
              return StreamBuilder<int>(
                stream: context.wizardController.indexStream,
                initialData: context.wizardController.index,
                builder: (context, snapshot) {
                  final selectedIndex = snapshot.data!;
                  return ListTile(
                    title: Text(title),
                    selectedColor: Color(0xffffffff),
                    textColor: Color(0xffb3bdcd),
                    iconColor: Color(0xffb3bdcd),
                    // leading: index == selectedIndex ? Icon(Icons.person) : Icon(Icons.ac_unit_rounded),
                    leading: ImageIcon(
                      AssetImage('image/icons/${iconFile}'),
                      size: 15,
                    ),
                    visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                    contentPadding: EdgeInsets.zero,
                    horizontalTitleGap: -8,
                    onTap: enabled ? () => context.wizardController.goTo(index: index) : null,
                    enabled: enabled,
                    selected: index == selectedIndex,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
