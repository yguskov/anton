import 'package:example/models/cv.dart';
import 'package:flutter/cupertino.dart';
import 'package:example/src/steps/my_wizard_step.dart';
import 'package:rxdart/rxdart.dart';

class StepFourProvider extends MyWizardStep {
  List<Map<String, String>> dutyList = [];
  StepFourProvider()
      : dutyList = [],
        super({
          'duty_name': BehaviorSubject<String>.seeded(''),
          'duty_period': BehaviorSubject<String>.seeded(''),
          'duty_attitude': BehaviorSubject<String>.seeded(''),
          'duty_type': BehaviorSubject<String>.seeded(''),
        }, {
          'duty_name': TextEditingController(),
          'duty_period': TextEditingController(),
          'duty_attitude': TextEditingController(),
          'duty_type': TextEditingController(),
        }) {
    dutyList = CV.instance.duty;
  }

  updateCV(CV cv) {
    cv.setValue('duty', dutyList);
  }

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
