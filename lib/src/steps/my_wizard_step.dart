import 'dart:async';
import 'dart:html';

import 'package:example/models/cv.dart';
import 'package:example/src/constants.dart';
import 'package:example/src/widgets/action_bar.dart';
import 'package:example/src/widgets/bottom_bar.dart';
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
 * @book Base class of steps state with predefined field text autocomplete, dropdown box and radio list
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
        hasError: widget.provider.hasError(fieldName));
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

  Widget listCard(
      BoxConstraints constraints, List<Map<String, String>> dutyList, _onSelect, cardItem) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => _onSelect(null),
      child: Wrap(
        spacing: cardSpace10,
        runSpacing: cardSpace10,
        children: List.generate(dutyList.length, (index) {
          return MouseRegion(
            cursor: MaterialStateMouseCursor.clickable,
            child: GestureDetector(
              onTap: () => _onSelect(index),
              child: SizedBox(
                width: constraints.maxWidth > screenSide600
                    ? (constraints.maxWidth - 2 * cardSpace10) / 2
                    : constraints.maxWidth,
                child: cardItem(dutyList[index], index),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget buildLayout(BuildContext context, List<Widget> rows, [Widget? listCard]) {
    rows.add(ActionBar());
    rows = List.generate(
      rows.length,
      (index) => _wrapBorder(rows[index], index),
    );
    rows.insert(0, _borderUp());
    rows.add(_borderBottom());

    // rows.add(_borderBottom());
    return LayoutBuilder(builder: (context, constraints) {
      print('Whole page width = ${constraints.maxWidth}');
      const double formColPadding = 10;
      final narrow = constraints.maxWidth <= baseScreenWidth; // 820 1060
      double maxColWidth = baseScreenWidth / 2 - formColPadding;
      return ListView(children: [
        Expanded(
          child: Container(
            color: const Color(0xfff9fafb),
            padding: const EdgeInsets.all(formColPadding),
            child: Align(
              alignment: Alignment.topRight,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight -
                      bottomHeight -
                      2 * formColPadding, // @FIXME if bottom in two rows should be - 2 * bottomHeight
                  maxWidth: baseScreenWidth,
                ),
                child: narrow
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        // mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // 1 form column
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              // minHeight: constraints.maxHeight - bottomHeight - 20,
                              maxWidth: baseScreenWidth,
                            ),
                            child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: rows),
                          ),
                          // 2 blocks column
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              // minHeight: constraints.maxHeight - bottomHeight - 20,
                              // minWidth: baseScreenWidth,
                              maxWidth: baseScreenWidth,
                            ),
                            child: Container(
                                padding: EdgeInsets.only(left: 0, top: 2 * formColPadding),
                                child: listCard ?? Container()),
                          ),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // 1 form column
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              // minHeight: constraints.maxHeight - bottomHeight - 20,
                              maxWidth: maxColWidth,
                            ),
                            child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: rows),
                          ),
                          // 2 blocks column
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              // minHeight: constraints.maxHeight - bottomHeight - 20,
                              minWidth: maxColWidth,
                              maxWidth: maxColWidth,
                            ),
                            child: Container(
                                padding: EdgeInsets.only(
                                    left: 2 * formColPadding, top: 2 * formColPadding),
                                child: listCard ?? Container()),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
        BottomBar()
      ]);
    });
  }

  static const Color borderColor = Color(0xFFAAAAAA);
  static const double borderWidth = 1.0;

  Widget _borderUp() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(5),
        ),
        color: Colors.white,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const SizedBox(height: 16),
          Positioned(
            bottom: -borderWidth,
            left: 0,
            right: 0,
            child: Container(
              height: borderWidth,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _borderBottom() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(5),
        ),
        color: Colors.white,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const SizedBox(height: 16),
          // Белая полоска, перекрывающая верхнюю границу
          Positioned(
            top: -borderWidth, // Смещаем вверх на толщину границы
            left: 0, // Смещаем влево, чтобы закрыть углы
            right: 0, // Смещаем вправо, чтобы закрыть углы
            child: Container(
              height: borderWidth, // Делаем высоту в 2 раза больше
              color: Colors.white, // Тот же цвет, что и фон
            ),
          ),
        ],
      ),
    );
  }

  Widget _wrapBorder(Widget child, int? index) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(
            color: borderColor,
            width: borderWidth,
          ),
          right: BorderSide(
            color: borderColor,
            width: borderWidth,
          ),
        ),
      ),
      child: child,
    );
  }
}

// Step provider
abstract class MyWizardStep with WizardStep {
  Map<String, TextEditingController> _controller;
  Map<String, dynamic> _field;
  Map<String, bool> _hasError = {};

  get field => _field;

  MyWizardStep(this._field, this._controller) {
    for (var item in _field.entries) {
      String name = item.key;
      _field[name]!.add(CV.instance.getValue(name) ?? '');
      if (_controller[name] != null) {
        if (CV.instance.getValue(name) != null)
          _controller[name]!.text = CV.instance.getValue(name)!;

        _controller[name]!.addListener(() {
          if (_controller[name]!.text != '') clearError(name);
        });
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

  // save all fields of the step to CV
  updateCV(CV cv) {
    _field.forEach((key, value) {
      cv.setValue(key, value.value);
    });
    keepInStorage(cv);
  }

  reloadDataFromCV(CV cv) {
    for (var item in _field.entries) {
      String name = item.key;
      _field[name]!.add(cv.getValue(name) ?? '');
      if (_controller[name] != null) {
        if (cv.getValue(name) != null) _controller[name]!.text = cv.getValue(name)!;
      }
    }
  }

/**
 * Keep in local storage
 */
  keepInStorage(CV cv) {
    window.localStorage['cv'] = cv.toJson();
  }

  bool verifyData() {
    return true;
  }

  void addError(String fieldName) {
    _hasError[fieldName] = true;
  }

  bool hasError(String fieldName) {
    return _hasError[fieldName] ?? false;
  }

  void clearError(String name) {
    _hasError.remove(name);
  }

  bool get hasAnyError => _hasError.isNotEmpty;
}
