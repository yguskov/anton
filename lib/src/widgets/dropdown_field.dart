import 'package:flutter/material.dart';

class DropdownField extends StatefulWidget {
  final String fieldName;
  final String label;
  final items;
  final String? hint;
  final provider;

  const DropdownField({
    super.key,
    required this.fieldName,
    required this.label,
    this.hint,
    required this.items,
    required this.provider,
  });

  @override
  State<StatefulWidget> createState() => _DropdownFieldState();
}

class _DropdownFieldState extends State<DropdownField> {
  // late final _controller;

  @override
  void initState() {
    super.initState();
    // _controller = widget.provider.controllerByName(widget.fieldName);
    // _controller.addListener(_onTextChanged);
    // onValueChanged = (_) {
    //   print(_controller.text);
    //   widget.provider.updateDescription(_controller.text);
    // };
  }

  @override
  Widget build(BuildContext context) {
    PopupDropdownWithCheckmark<String> dropdown =
        PopupDropdownWithCheckmark<String>(
            value: widget.provider.getValue(widget.fieldName),
            items: widget.items,
            hint: widget.hint ?? 'Выберите из списка',
            onSelected: (value) {
              setState(() {
                widget.provider.updateValue(widget.fieldName, value);
              });
            });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
            widget.label,
            style: TextStyle(
              // fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 8),
        dropdown,
      ],
    );
  }
}

class PopupDropdownWithCheckmark<T> extends StatelessWidget {
  final T? value;
  final List<PopupDropdownItem<T>> items;
  final ValueChanged<T> onSelected;
  final String hint;
  final double elevation;

  const PopupDropdownWithCheckmark({
    Key? key,
    required this.value,
    required this.items,
    required this.onSelected,
    this.hint = 'Выберите значение',
    this.elevation = 8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedItem = items.firstWhere(
      (item) => item.value == value,
      orElse: () => PopupDropdownItem<T>(
        value: items.first.value,
        label: hint,
      ),
    );

    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[600]!, width: 1),
          borderRadius: BorderRadius.circular(4),
          color: Colors.grey[200]),
      child: PopupMenuButton<T>(
        elevation: elevation,
        onSelected: onSelected,
        itemBuilder: (BuildContext context) {
          return items.map((item) {
            return PopupMenuItem<T>(
              value: item.value,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item.label),
                  if (value == item.value)
                    Icon(Icons.check, color: Theme.of(context).primaryColor),
                ],
              ),
            );
          }).toList();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value != null ? selectedItem.label : hint,
                  style: TextStyle(
                    color:
                        (value ?? '') != '' ? Colors.black : Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ),
              Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
            ],
          ),
        ),
      ),
    );
  }
}

class PopupDropdownItem<T> {
  final T value;
  final String label;

  PopupDropdownItem({
    required this.value,
    required this.label,
  });
}
