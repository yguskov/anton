import 'package:flutter/material.dart';

class TextFieldComplete extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final List<String> options;

  final String? label;
  final String? hint;

  // void Function(String)? onSelected;

  const TextFieldComplete({
    super.key,
    this.label,
    this.hint,
    // TextField parameters
    this.controller,
    this.focusNode,
    // this.onSelected,
    this.options = const [
      'Apple',
      'Banana',
      'Cherry',
      'Date',
      'Elderberry',
      'Fig',
      'Grape',
      'Honeydew'
    ],
  });

  @override
  State<TextFieldComplete> createState() => _TextFieldCompleteState();
}

class _TextFieldCompleteState extends State<TextFieldComplete> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> _options = [];

// Переменная для хранения текущих опций
  Iterable<String> _currentOptions = const Iterable<String>.empty();
  bool _isOptionsVisible = false;

  @override
  void initState() {
    super.initState();
    _options = widget.options;

    _controller.addListener(_onTextChanged);
    // Слушатель изменений текста
    _controller.addListener(() {
      print('Текст изменен: ${_controller.text}');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return _options.where((String option) {
              return option
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            });
          },
          onSelected: (String selection) {
            print('Выбрано: $selection');
            // _controller.text = selection;
          },
          fieldViewBuilder: (BuildContext context,
              TextEditingController textEditingController,
              FocusNode focusNode,
              VoidCallback onFieldSubmitted) {
            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              maxLines: 3,
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
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 16,
              ),
              onSubmitted: (String value) {
                print('Что-то нажали');
                // Обработка нажатия Enter
                _handleEnterPressed(value);
              },
            );
          },
        ),
/*           const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // Очистка через контроллер
            _controller.clear();
          },
          child: const Text('Очистить'),
        ), */
      ],
    );
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

  void _handleEnterPressed(String value) {
    print('выбираем по Enter');
    if (_currentOptions.isNotEmpty) {
      _handleOptionSelected(_currentOptions.first);
    } else {
      _focusNode.unfocus();
    }
  }
}
