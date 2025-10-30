import 'package:flutter/material.dart';

class DynamicRadioList extends StatefulWidget {
  final String fieldName;
  final String label;
  final List<String> items;
  late final double? optionFontSize;
  late final double? optionHeight;

  final provider;

  DynamicRadioList(
      {super.key,
      required this.fieldName,
      required this.label,
      required this.items,
      this.optionHeight,
      this.optionFontSize,
      this.provider});

  @override
  _DynamicRadioListState createState() => _DynamicRadioListState();
}

class _DynamicRadioListState extends State<DynamicRadioList> {
  late List<String> _options;
  String? _selectedValue;
  late final TextEditingController _otherController;

  void _initValue(String? value) {
    if (widget.items.contains(value ?? '')) {
      _otherController.text = '';
      _selectedValue = value ?? '';
    } else {
      _otherController.text = value ?? '';
    }
  }

  @override
  void initState() {
    super.initState();
    _otherController = new TextEditingController();
    _options = widget.items;

    _initValue(widget.provider.getValue(widget.fieldName));

    // _controller = widget.provider.controllerByName(widget.fieldName);
    // _controller.addListener(_onTextChanged);
    // onValueChanged = (_) {
    //   print(_controller.text);
    //   widget.provider.updateDescription(_controller.text);
    // };
  }

  @override
  Widget build(BuildContext context) {
    const leftPadding = 20.0;

    Widget radioList = ListView.builder(
      padding: EdgeInsets.only(left: leftPadding, top: 0, bottom: 0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _options.length,
      itemBuilder: (context, index) {
        return Container(
          height: widget.optionHeight,
          child: RadioListTile<String>(
            title: Text(_options[index],
                style: TextStyle(height: widget.optionFontSize),
                textHeightBehavior: TextHeightBehavior(
                    applyHeightToFirstAscent: false,
                    applyHeightToLastDescent: false,
                    leadingDistribution: TextLeadingDistribution.even)),
            // contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            dense: true,
            // materialTapTargetSize: ,
            value: _options[index],
            groupValue: _selectedValue,
            onChanged: (value) {
              setState(() {
                _otherController.text = '';
                _selectedValue = value;
                widget.provider.updateValue(widget.fieldName, value);
              });
            },
          ),
        );
      },
    );

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
        SizedBox(height: 2),
        radioList,
        Padding(
          padding: const EdgeInsets.only(left: leftPadding, top: 15),
          child: TextField(
            // autofillHints: ['fix', 'other'],
            controller: _otherController,
            // focusNode: focusNode,
            maxLines: 1,
            // style: TextStyle(height: 10, fontSize: 8),
            decoration: InputDecoration(
              hintText: 'Другое',
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
                borderRadius: const BorderRadius.all(Radius.circular(6)),
              ),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            ),
            // onSubmitted: (String value) {
            //   _handleEnterPressed();
            // },
            onChanged: (value) {
              setState(() {
                _selectedValue = value;
                widget.provider.updateValue(widget.fieldName, value);
              });
            },
          ),
        )
      ],
    );
  }
}
