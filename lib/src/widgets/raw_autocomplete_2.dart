import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RawAutocomplete2 extends StatefulWidget {
  const RawAutocomplete2({super.key});

  @override
  State<RawAutocomplete2> createState() => _RawAutocomplete2State();
}

class _RawAutocomplete2State extends State<RawAutocomplete2> {
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
  int _highlightedIndex = -1;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      setState(() {
        _isOptionsVisible = false;
        _highlightedIndex = -1;
      });
    }
  }

  void _onTextChanged() {
    final text = _controller.text;
    if (text.isEmpty) {
      setState(() {
        _currentOptions = const Iterable<String>.empty();
        _isOptionsVisible = false;
        _highlightedIndex = -1;
      });
    } else {
      setState(() {
        _currentOptions = _options.where(
            (option) => option.toLowerCase().contains(text.toLowerCase()));
        _isOptionsVisible = _currentOptions.isNotEmpty;
        _highlightedIndex = _isOptionsVisible ? 0 : -1;
      });
    }
  }

  void _handleOptionSelected(String option) {
    setState(() {
      _controller.text = option;
      _isOptionsVisible = false;
      _highlightedIndex = -1;
    });
    _focusNode.unfocus();
    print('Выбрано: $option');
  }

  void _handleEnterPressed() {
    if (_highlightedIndex >= 0 && _highlightedIndex < _currentOptions.length) {
      _handleOptionSelected(_currentOptions.elementAt(_highlightedIndex));
    } else if (_currentOptions.isNotEmpty) {
      _handleOptionSelected(_currentOptions.first);
    } else {
      _focusNode.unfocus();
    }
  }

  void _handleArrowDown() {
    if (_currentOptions.isNotEmpty) {
      setState(() {
        _highlightedIndex = (_highlightedIndex + 1) % _currentOptions.length;
      });
      _ensureVisible(_highlightedIndex);
    }
  }

  void _handleArrowUp() {
    if (_currentOptions.isNotEmpty) {
      setState(() {
        _highlightedIndex = _highlightedIndex <= 0
            ? _currentOptions.length - 1
            : _highlightedIndex - 1;
      });
      _ensureVisible(_highlightedIndex);
    }
  }

  void _ensureVisible(int index) {
    // Здесь можно добавить прокрутку к выделенному элементу
    // Для простоты оставляем базовую реализацию
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
                      tileColor: _highlightedIndex == index
                          ? Theme.of(context).focusColor
                          : Colors.transparent,
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
          return FocusableActionDetector(
            descendantsAreFocusable: false,
            shortcuts: {
              LogicalKeySet(LogicalKeyboardKey.arrowDown):
                  const _ArrowDownIntent(),
              LogicalKeySet(LogicalKeyboardKey.arrowUp): const _ArrowUpIntent(),
            },
            actions: {
              _ArrowDownIntent: CallbackAction<_ArrowDownIntent>(
                onInvoke: (intent) => _handleArrowDown(),
              ),
              _ArrowUpIntent: CallbackAction<_ArrowUpIntent>(
                onInvoke: (intent) => _handleArrowUp(),
              ),
            },
            child: TextField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Фрукты',
                hintText: 'Начните вводить название фрукта',
                suffixIcon: Icon(Icons.arrow_drop_down),
              ),
              onSubmitted: (String value) {
                _handleEnterPressed();
              },
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}

class _ArrowDownIntent extends Intent {
  const _ArrowDownIntent();
}

class _ArrowUpIntent extends Intent {
  const _ArrowUpIntent();
}
