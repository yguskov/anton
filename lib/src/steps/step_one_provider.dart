import 'dart:async';

import 'package:example/src/steps/my_wizard_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wizard/flutter_wizard.dart';
import 'package:rxdart/rxdart.dart';

class StepOneProvider extends MyWizardStep with WizardStep {
  StepOneProvider()
      : super({
          'fio': BehaviorSubject<String>.seeded(''),
          'position': BehaviorSubject<String>.seeded(''),
          'sector': BehaviorSubject<String>.seeded(''),
          'boss_fio': BehaviorSubject<String>.seeded(''),
          'boss_email': BehaviorSubject<String>.seeded(''),
        }, {
          'fio': TextEditingController(),
          'position': TextEditingController(),
          'sector': TextEditingController(),
          'boss_fio': TextEditingController(),
          'boss_email': TextEditingController(),
          // 'category':
        });

  final descriptionFocusNode = FocusNode();

  final descriptionTextController = TextEditingController();

  @override
  Future<void> onShowing() async {
    if (getValue('fio').isEmpty) {
      descriptionFocusNode.requestFocus();
    }
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
