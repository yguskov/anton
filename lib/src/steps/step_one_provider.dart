import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_wizard/flutter_wizard.dart';
import 'package:rxdart/rxdart.dart';

class StepOneProvider with WizardStep {
  StepOneProvider();

  final _controller = {
    'fio': TextEditingController(),
    'email': TextEditingController(),
    'password': TextEditingController(),
    // 'category':
  };

  final _field = {
    'fio': BehaviorSubject<String>.seeded(''),
    'email': BehaviorSubject<String>.seeded(''),
    'password': BehaviorSubject<String>.seeded(''),
    'category': BehaviorSubject<String>.seeded(''),
    'aim': BehaviorSubject<String>.seeded(''),
  };

  final descriptionFocusNode = FocusNode();

  final descriptionTextController = TextEditingController();

  String getValue(name) {
    return _field[name]!.value;
    // return _description.value;
  }

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

  void updateValue(String name, String value) {
    _field[name]!.add(value);
  }

  void dispose() {
    descriptionTextController.dispose();
  }

  controllerByName(String field) {
    return _controller[field];
  }
}
