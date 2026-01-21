import 'package:flutter/cupertino.dart';
import 'package:example/src/steps/my_wizard_step.dart';

class StepFinishProvider extends MyWizardStep {
  StepFinishProvider() : super({}, {});

  final descriptionFocusNode = FocusNode();

  @override
  Future<void> onShowing() async {
    // if (getValue('fio').isEmpty) {
    //   descriptionFocusNode.requestFocus();
    // }
  }

  @override
  Future<void> onHiding() async {
    if (descriptionFocusNode.hasFocus) {
      descriptionFocusNode.unfocus();
    }
  }

  void dispose() {}
}
