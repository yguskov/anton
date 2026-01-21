import 'dart:async';

import 'package:example/models/cv.dart';
import 'package:example/src/steps/my_wizard_step.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class StepOneProvider extends MyWizardStep {
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
