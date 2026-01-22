import 'package:example/models/cv.dart';
import 'package:flutter/cupertino.dart';
import 'package:example/src/steps/my_wizard_step.dart';
import 'package:rxdart/rxdart.dart';

class StepSixProvider extends MyWizardStep {
  List<Map<String, String>> knowList = [];

  StepSixProvider()
      : knowList = [],
        super({
          'know_name': BehaviorSubject<String>.seeded(''),
          'know_skill': BehaviorSubject<String>.seeded(''),
          'know_when': BehaviorSubject<String>.seeded(''),
          'know_result': BehaviorSubject<String>.seeded(''),
          'want_tip': BehaviorSubject<String>.seeded(''),
        }, {
          'know_name': TextEditingController(),
          'know_skill': TextEditingController(),
          'know_when': TextEditingController(),
          'know_result': TextEditingController(),
          'want_tip': TextEditingController(),
        }) {
    knowList = CV.instance.know;
  }

  updateCV(CV cv) {
    cv.setValue('know', knowList);
    cv.setValue('want_tip', getValue('want_tip'));
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
