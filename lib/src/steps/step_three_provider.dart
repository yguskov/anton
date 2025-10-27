import 'package:flutter/cupertino.dart';
import 'package:flutter_wizard/flutter_wizard.dart';
import 'package:example/src/steps/my_wizard_step.dart';
import 'package:rxdart/rxdart.dart';

class StepThreeProvider extends MyWizardStep with WizardStep {
  StepThreeProvider()
      : super({
          'salary': BehaviorSubject<String>.seeded(''),
          'last_upgrade': BehaviorSubject<String>.seeded(''),
          'work_from': BehaviorSubject<String>.seeded(''),
          'office_location': BehaviorSubject<String>.seeded(''),
          'office_country': BehaviorSubject<String>.seeded(''),
          'want_info': BehaviorSubject<String>.seeded(''),
        }, {
          'salary': TextEditingController(),
          'last_upgrade': TextEditingController(),
          'work_from': TextEditingController(),
          'office_location': TextEditingController(),
          'office_country': TextEditingController(),
          'want_info': TextEditingController(),
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
