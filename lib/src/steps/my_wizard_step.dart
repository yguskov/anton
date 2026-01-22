import 'dart:async';
import 'dart:html';

import 'package:example/models/cv.dart';
import 'package:example/src/widgets/just_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wizard/flutter_wizard.dart';

import '../widgets/dropdown_field.dart';
import '../widgets/radio_list_field.dart';
import '../widgets/raw_autocomplete_example.dart';

const headerStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.w700);
const headerStyle2 = TextStyle(fontSize: 16, fontWeight: FontWeight.w400);

abstract class StatefulWidgetStep extends StatefulWidget {
  late final MyWizardStep provider;

  StatefulWidgetStep({super.key, required this.provider});
}

/**
 * Base class of steps widget with predefined field text autocomplete, dropdown box and radio list
 */
abstract class StateStep<T extends StatefulWidgetStep> extends State<T> {
  final StreamController<String> _streamController = StreamController<String>();

  // get another step
  MyWizardStep providerOfStep(int i) {
    return widget.provider.wizardController.stepControllers[i].step as MyWizardStep;
  }

  Widget buildJustTextField(String hint, String fieldName) {
    return JustTextField(
      fieldName: fieldName,
      hint: hint,
      provider: widget.provider,
    );
  }

  Widget buildTextFieldWithLabel(String? label, String hint, String fieldName,
      [List<String>? options]) {
    return RawAutocompleteExample(
      fieldName: fieldName,
      label: label,
      hint: hint,
      provider: widget.provider,
      options: options,
    );
  }

  Widget buildDropdownSection(
      String label, String hint, String fieldName, List<PopupDropdownItem<String>> items) {
    return DropdownField(
      fieldName: fieldName,
      label: label,
      hint: hint,
      items: items,
      provider: widget.provider,
    );
  }

  Widget buildRadioList(String label, String fieldName, List<String> items,
      [optionHeight, optionFontSize, optionOtherText]) {
    return DynamicRadioList(
      fieldName: fieldName,
      label: label,
      items: items,
      provider: widget.provider,
      optionHeight: optionHeight,
      optionFontSize: optionFontSize,
      otherText: optionOtherText,
    );
  }

  Widget buildCheckBox(String label, String fieldName) {
    widget.provider.controllerByName(fieldName).addListener(() {
      _streamController.add(widget.provider.getValue(fieldName));
    });

    return Row(
      children: [
        Checkbox(
            value: widget.provider.getValue(fieldName).length > 0,
            onChanged: (value) {
              setState(() {
                widget.provider.updateValue(fieldName, value! ? '1' : '');
              });
            }),
        Expanded(child: Text(label, maxLines: 2, overflow: TextOverflow.visible, softWrap: true))
      ],
    );
  }
}

// Step provider
abstract class MyWizardStep with WizardStep {
  Map<String, TextEditingController> _controller;
  Map<String, dynamic> _field;

  MyWizardStep(this._field, this._controller) {
    // print('--new step--');
    for (var item in _field.entries) {
      String name = item.key;
      // print('---trye load $name = ${CV.instance.getValue(name) ?? '-'}');
      _field[name]!.add(CV.instance.getValue(name) ?? '');
      if (_controller[name] != null) {
        if (CV.instance.getValue(name) != null)
          _controller[name]!.text = CV.instance.getValue(name)!;
      }
    }
  }

  String getValue(name) {
    if (!_field.containsKey(name))
      throw Exception('Field $name was not defined in step provider!!!!!!');

    return _field[name]!.value;
  }

  void updateValue(String name, String value) {
    _field[name]!.add(value);
  }

  TextEditingController controllerByName(String field) {
    if (!_controller.containsKey(field)) throw Exception('Empty controller with name $field');
    return _controller[field]!;
  }

  get field => _field;

  // save all fields of the step to CV
  updateCV(CV cv) {
    _field.forEach((key, value) {
      cv.setValue(key, value.value);
      // print('$key=====${value.value}');
    });
    keepInStorage(cv);
    // print(cv.toJson());
  }

/**
 * Keep in local storage
 */
  keepInStorage(CV cv) {
    window.localStorage['cv'] = cv.toJson();
  }
}
