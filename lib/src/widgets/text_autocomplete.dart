import 'package:flutter/material.dart';

class TextAutocomplete extends StatefulWidget {
  const TextAutocomplete({super.key});

  @override
  State<TextAutocomplete> createState() => _TextAutocompleteState();
}

class _TextAutocompleteState extends State<TextAutocomplete> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<String> _options = [
    'Apple',
    'Banana',
    'Cherry',
    'Date',
    'Elderberry',
    'Fig',
    'Grape',
    'Honeydew'
  ];

  Iterable<String> _currentOptions = const Iterable<String>.empty();
  bool _isOptionsVisible = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
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
    _focusNode.unfocus();
    print('Выбрано: $option');
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: RawAutocomplete<String>(
        focusNode: _focusNode,
        textEditingController: _controller,
        optionsBuilder: (TextEditingValue textEditingValue) {
          return _currentOptions;
        },
        onSelected: (String selection) {
          _handleOptionSelected(selection);
        },
        optionsViewBuilder: (BuildContext context,
            AutocompleteOnSelected<String> onSelected,
            Iterable<String> options) {
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
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Фрукты',
              hintText: 'Начните вводить название фрукта',
            ),
            onSubmitted: (String value) {
              _handleEnterPressed();
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
