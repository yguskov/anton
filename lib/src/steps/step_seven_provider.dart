import 'package:example/models/cv.dart';
import 'package:flutter/cupertino.dart';
import 'package:example/src/steps/my_wizard_step.dart';
import 'package:rxdart/rxdart.dart';

class StepSevenProvider extends MyWizardStep {
  List<Map<String, String>> achieveList = [];

  StepSevenProvider()
      : achieveList = [],
        super({
          'achieve_name': BehaviorSubject<String>.seeded(''),
          'achieve_result': BehaviorSubject<String>.seeded(''),
          'achieve_when': BehaviorSubject<String>.seeded(''),
          'want_tip': BehaviorSubject<String>.seeded(''),
        }, {
          'achieve_name': TextEditingController(),
          'achieve_result': TextEditingController(),
          'achieve_when': TextEditingController(),
        }) {
    achieveList = CV.instance.achieve;
  }

  updateCV(CV cv) {
    cv.setValue('achieve', achieveList);
    keepInStorage(cv);
  }

  reloadDataFromCV(CV cv) {
    achieveList = cv.achieve;
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
