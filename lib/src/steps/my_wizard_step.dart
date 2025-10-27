import 'dart:async';
import 'dart:js_interop';

import 'package:example/src/widgets/just_text_field.dart';
import 'package:flutter/material.dart';

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

  Widget buildDropdownSection(String label, String hint, String fieldName,
      List<PopupDropdownItem<String>> items) {
    return DropdownField(
      fieldName: fieldName,
      label: label,
      items: items,
      provider: widget.provider,
    );
  }

  Widget buildRadioList(String label, String fieldName, List<String> items) {
    return DynamicRadioList(
        fieldName: fieldName,
        label: label,
        items: items,
        provider: widget.provider);
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
        const SizedBox(
          width: 25,
        ),
        Expanded(
            child: Text(
                'Я хочу обмениваться с сообществом и получать информирование об уровне зарплат в моём регионе',
                maxLines: 2,
                overflow: TextOverflow.visible,
                softWrap: true))
      ],
    );
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

  TextEditingController controllerByName(String field) {
    if (!_controller.containsKey(field))
      throw Exception('Empty controller with name $field');
    return _controller[field];
  }
}
