import 'package:flutter/material.dart';

import '../widgets/dropdown_field.dart';
import '../widgets/radio_list_field.dart';
import '../widgets/raw_autocomplete_example.dart';

abstract class StatefulWidgetStep extends StatefulWidget {
  late final MyWizardStep provider;

  StatefulWidgetStep({super.key, required this.provider});
}

/**
 * Base class of steps widget with predefined field text autocomplete, dropdown box and radio list
 */
abstract class StateStep<T extends StatefulWidgetStep> extends State<T> {
  Widget buildTextFieldWithLabel(String label, String hint, String fieldName,
      [List<String>? options]) {
    return RawAutocompleteExample(
      fieldName: fieldName,
      label: label,
      hint: hint,
      provider: widget.provider,
      options: options,
    );
  }

  Widget buildDropdownSection(String label, String hint, String fieldName,
      List<PopupDropdownItem<String>> items) {
    return DropdownField(
      fieldName: fieldName,
      label: label,
      items: items,
      provider: widget.provider,
    );
  }

  Widget buildRadioList(
      String label, String hint, String fieldName, List<String> items) {
    return DynamicRadioList(
        fieldName: fieldName,
        label: label,
        hint: hint,
        items: items,
        provider: widget.provider);
  }
}

class MyWizardStep {
  var _controller;
  var _field;

  MyWizardStep(this._field, this._controller);

  String getValue(name) {
    return _field[name]!.value;
    // return _description.value;
  }

  void updateValue(String name, String value) {
    _field[name]!.add(value);
  }

  controllerByName(String field) {
    return _controller[field];
  }
}
