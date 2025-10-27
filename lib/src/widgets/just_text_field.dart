import 'dart:js_interop';

import 'package:flutter/material.dart';

class JustTextField extends StatefulWidget {
  final String? hint;
  final controller;
  final focusNode;
  final String? label;
  final String fieldName;
  final provider;

  const JustTextField({
    super.key,
    required this.fieldName,
    this.label,
    this.hint,
    required this.provider,
    this.controller,
    this.focusNode,
  });

  @override
  State<JustTextField> createState() => _JustTextFieldState();
}

class _JustTextFieldState extends State<JustTextField> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  // var onValueChanged;

  @override
  void initState() {
    super.initState();
    _controller = widget.provider.controllerByName(widget.fieldName);
    // onValueChanged = (_) {
    //   print(_controller.text);
    //   widget.provider.updateValue(widget.fieldName, _controller.text);
    // };
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> rows = [];

    if (!widget.label.isNull) {
      rows.add(Container(
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
          widget.label ?? '',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ));

      rows.add(const SizedBox(height: 4));
    }

    rows.add(TextField(
      controller: _controller,
      focusNode: _focusNode,
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
      // onChanged: onValueChanged,
    ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
  }

  @override
  void dispose() {
    // _controller.dispose();
    // _focusNode.dispose();
    super.dispose();
  }
}
