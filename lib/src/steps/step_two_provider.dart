import 'dart:async';

import 'package:example/src/steps/my_wizard_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wizard/flutter_wizard.dart';
import 'package:rxdart/rxdart.dart';

class StepTwoProvider extends MyWizardStep with WizardStep {
  StepTwoProvider()
      : super({
          'aim': BehaviorSubject<String>.seeded(''),
          'why': BehaviorSubject<String>.seeded(''),
        }, {});

  final descriptionFocusNode = FocusNode();

  final descriptionTextController = TextEditingController();

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

  void dispose() {
    descriptionTextController.dispose();
  }
}
