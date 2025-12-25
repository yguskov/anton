import 'dart:js_interop';

import 'package:example/src/steps/my_wizard_step.dart';
import 'package:flutter/material.dart';

class RawAutocompleteExample extends StatefulWidget {
  final String? hint;
  final focusNode; // @FIXME think about it!
  final String? label;
  final String fieldName;
  final List<String>? options;
  final MyWizardStep provider;

  const RawAutocompleteExample({
    super.key,
    required this.fieldName,
    this.label,
    this.hint,
    this.options,
    // TextField parameters
    required this.provider,
    this.focusNode,
  });

  // TextEditingController get controller => provider.controllerByName(fieldName);

  @override
  State<RawAutocompleteExample> createState() => _RawAutocompleteExampleState();
}

class _RawAutocompleteExampleState extends State<RawAutocompleteExample> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  List<String> _options = [];

  Iterable<String> _currentOptions = const Iterable<String>.empty();
  bool _isOptionsVisible = false;

  var onValueChanged;

  @override
  void initState() {
    super.initState();
    _controller = widget.provider.controllerByName(widget.fieldName);
    _controller.addListener(_onTextChanged);
    _options = widget.options ?? [];
    onValueChanged = (_) {
      print(_controller.text);
      widget.provider.updateValue(widget.fieldName, _controller.text);
    };
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void _onTextChanged() {
    final text = _controller.text;
    if (text.isEmpty) {
      setState(() {
        _currentOptions = const Iterable<String>.empty();
        _isOptionsVisible = false;
      });
    } else {
      setState(() {
        _currentOptions = _options.where(
            (option) => option.toLowerCase().contains(text.toLowerCase()));
        _isOptionsVisible = _currentOptions.isNotEmpty;
      });
    }
  }

  void _handleOptionSelected(String option) {
    setState(() {
      _controller.text = option;
      _isOptionsVisible = false;
    });
    widget.provider.updateValue(widget.fieldName, option);
    _focusNode.unfocus();
  }

  void _handleEnterPressed() {
    if (_currentOptions.isNotEmpty) {
      _handleOptionSelected(_currentOptions.first);
    } else {
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    if (widget.label != null) {
      children.add(Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
        decoration: BoxDecoration(
          color: Color.fromRGBO(37, 46, 63, 1),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(3),
            topRight: Radius.circular(3),
            bottomLeft: Radius.circular(1),
            bottomRight: Radius.circular(1),
          ),
        ),
        child: Text(
          widget.label!,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ));
      children.add(const SizedBox(height: 4));
    }

    children.add(RawAutocomplete<String>(
      focusNode: _focusNode,
      textEditingController: _controller,
      optionsBuilder: (TextEditingValue textEditingValue) {
        return _currentOptions;
      },
      onSelected: (String selection) {
        _handleOptionSelected(selection);
      },
      optionsViewBuilder: (BuildContext context,
          AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
        if (!_isOptionsVisible || options.isEmpty) {
          return const SizedBox.shrink();
        }

        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: SizedBox(
              height: 200.0,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final String option = options.elementAt(index);
                  return ListTile(
                    title: Text(option),
                    onTap: () {
                      onSelected(option);
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
      fieldViewBuilder: (BuildContext context,
          TextEditingController textEditingController,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted) {
        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          maxLines: 1,
          decoration: InputDecoration(
            hintText: widget.hint,
            filled: true,
            fillColor: Colors.grey[200],
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[600]!, width: 1.5),
              borderRadius: const BorderRadius.all(
                Radius.circular(4),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[800]!, width: 2.0),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(6),
                bottomRight: Radius.circular(6),
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          onSubmitted: (String value) {
            _handleEnterPressed();
          },
          onChanged: onValueChanged,
        );
      },
    ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  @override
  void dispose() {
    // _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}

/*
Pure autocomplete may be it's better for one line elements
      Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text == '') {
            return const Iterable<String>.empty();
          }
          return _options.where((String option) {
            return option.toLowerCase().contains(
                  textEditingValue.text.toLowerCase(),
                );
          });
        },
        onSelected: (String selection) {
          debugPrint('You just selected $selection');
        },
      ),

*/
