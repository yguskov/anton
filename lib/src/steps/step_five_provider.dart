import 'package:flutter/cupertino.dart';
import 'package:flutter_wizard/flutter_wizard.dart';
import 'package:example/src/steps/my_wizard_step.dart';
import 'package:rxdart/rxdart.dart';

class StepFiveProvider extends MyWizardStep with WizardStep {
  List<Map<String, String>> skillList = [];

  StepFiveProvider()
      : skillList = [],
        super({
          'skill_name': BehaviorSubject<String>.seeded(''),
          'skill_level': BehaviorSubject<String>.seeded(''),
          'skill_type': BehaviorSubject<String>.seeded(''),
          'skill_power': BehaviorSubject<String>.seeded(''),
        }, {
          'skill_name': TextEditingController(),
          'skill_level': TextEditingController(),
          'skill_type': TextEditingController(),
          'skill_power': TextEditingController(),
        });

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
