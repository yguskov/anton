import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomAutocomplete extends StatefulWidget {
  final List<String> options;
  final ValueChanged<String>? onSelected;

  // Все параметры TextField
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final InputDecoration? decoration;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final TextDirection? textDirection;
  final bool readOnly;
  final bool? showCursor;
  final bool autofocus;
  final String obscuringCharacter;
  final bool obscureText;
  final bool autocorrect;
  final SmartDashesType? smartDashesType;
  final SmartQuotesType? smartQuotesType;
  final bool enableSuggestions;
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final int? maxLength;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final VoidCallback? onTap;
  final VoidCallback? onTapOutside;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final AppPrivateCommandCallback? onAppPrivateCommand;
  final List<TextInputFormatter>? inputFormatters;
  final bool? enabled;
  final double cursorWidth;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final Color? cursorColor;
  final BoxHeightStyle selectionHeightStyle;
  final BoxWidthStyle selectionWidthStyle;
  final Brightness? keyboardAppearance;
  final EdgeInsets scrollPadding;
  final bool? enableInteractiveSelection;
  final TextSelectionControls? selectionControls;
  final Widget? Function(BuildContext,
      {required int currentLength,
      required bool isFocused,
      required int? maxLength})? buildCounter;
  final ScrollPhysics? scrollPhysics;
  final Iterable<String>? autofillHints;
  final AutovalidateMode? autovalidateMode;
  final ScrollController? scrollController;
  final String? restorationId;
  final bool enableIMEPersonalizedLearning;
  final MouseCursor? mouseCursor;
  final SpellCheckConfiguration? spellCheckConfiguration;
  final TextMagnifierConfiguration? magnifierConfiguration;

  const CustomAutocomplete({
    super.key,
    this.options = const [],
    this.onSelected,

    // TextField parameters
    this.controller,
    this.focusNode,
    this.decoration = const InputDecoration(),
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.strutStyle,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.textDirection,
    this.readOnly = false,
    this.showCursor,
    this.autofocus = false,
    this.obscuringCharacter = '•',
    this.obscureText = false,
    this.autocorrect = true,
    this.smartDashesType,
    this.smartQuotesType,
    this.enableSuggestions = true,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.maxLength,
    this.maxLengthEnforcement,
    this.onTap,
    this.onTapOutside,
    this.onChanged,
    this.onSubmitted,
    this.onAppPrivateCommand,
    this.inputFormatters,
    this.enabled,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorColor,
    this.selectionHeightStyle = BoxHeightStyle.tight,
    this.selectionWidthStyle = BoxWidthStyle.tight,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.enableInteractiveSelection = true,
    this.selectionControls,
    this.buildCounter,
    this.scrollPhysics,
    this.autofillHints,
    this.autovalidateMode,
    this.scrollController,
    this.restorationId,
    this.enableIMEPersonalizedLearning = true,
    this.mouseCursor,
    this.spellCheckConfiguration,
    this.magnifierConfiguration,
  });

  @override
  State<CustomAutocomplete> createState() => _CustomAutocompleteState();
}

class _CustomAutocompleteState extends State<CustomAutocomplete> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  List<String> _filteredOptions = [];
  bool _showSuggestions = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  // Стандартные опции
  final List<String> _defaultOptions = [
    'Москва',
    'Санкт-Петербург',
    'Новосибирск',
    'Екатеринбург',
    'Казань',
    'Нижний Новгород',
    'Челябинск',
    'Самара',
    'Омск',
    'Ростов-на-Дону',
    'Уфа',
    'Красноярск',
    'Воронеж',
    'Пермь'
  ];

  List<String> get _allOptions {
    return widget.options.isNotEmpty ? widget.options : _defaultOptions;
  }

  @override
  void initState() {
    super.initState();

    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();

    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChange);
  }

  void _onTextChanged() {
    print("++++ text changed +++++");
    if (widget.obscureText) {
      _removeOverlay();
      return;
    }

    final query = _controller.text.trim().toLowerCase();

    if (query.isEmpty) {
      _removeOverlay();
      return;
    }

    setState(() {
      _filteredOptions = _allOptions
          .where((option) => option.toLowerCase().contains(query))
          .take(10)
          .toList();
    });

    if (_filteredOptions.isNotEmpty) {
      _showOverlay();
    } else {
      _removeOverlay();
    }

    widget.onChanged?.call(_controller.text);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _removeOverlay();
    } else if (_controller.text.isNotEmpty &&
        _filteredOptions.isNotEmpty &&
        !widget.obscureText) {
      _showOverlay();
    }
  }

  void _showOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
      return;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: _getTextFieldWidth(context),
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 4),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Theme.of(context).dialogBackgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _filteredOptions.length,
                itemBuilder: (context, index) {
                  final option = _filteredOptions[index];
                  final query = _controller.text.toLowerCase();
                  return _buildSuggestionItem(option, query);
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _showSuggestions = true);
  }

  void _removeOverlay() {
    print('-------------------------------------');
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    setState(() => _showSuggestions = false);
  }

  double _getTextFieldWidth(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox?;
    return renderBox?.size.width ?? MediaQuery.of(context).size.width - 32;
  }

  Widget _buildSuggestionItem(String option, String query) {
    final optionLower = option.toLowerCase();
    final queryIndex = optionLower.indexOf(query);

    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(
          Icons.location_on,
          size: 20,
          color: Theme.of(context).primaryColor,
        ),
        title: queryIndex >= 0
            ? RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                  ),
                  children: [
                    TextSpan(text: option.substring(0, queryIndex)),
                    TextSpan(
                      text: option.substring(
                          queryIndex, queryIndex + query.length),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    TextSpan(text: option.substring(queryIndex + query.length)),
                  ],
                ),
              )
            : Text(
                option,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
        onTap: () => _selectOption(option),
        dense: true,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  void _selectOption(String option) {
    // ОСНОВНОЕ ИСПРАВЛЕНИЕ: Устанавливаем текст в контроллер
    // _controller.text = option;
    // _controller.selection = TextSelection.collapsed(offset: option.length);

    _controller.value = TextEditingValue(
      text: option,
      selection: TextSelection.collapsed(offset: option.length),
    );

    print('_onSlect ${_controller.value}');
    _removeOverlay();
    // Вызываем callback'и
    widget.onSelected?.call(option);
    widget.onChanged?.call(option);

    // Убираем фокус
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        children: [
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            decoration: widget.decoration,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            textCapitalization: widget.textCapitalization,
            style: widget.style,
            strutStyle: widget.strutStyle,
            textAlign: widget.textAlign,
            textAlignVertical: widget.textAlignVertical,
            textDirection: widget.textDirection,
            readOnly: widget.readOnly,
            showCursor: widget.showCursor,
            autofocus: widget.autofocus,
            obscuringCharacter: widget.obscuringCharacter,
            obscureText: widget.obscureText,
            autocorrect: widget.autocorrect,
            smartDashesType: widget.smartDashesType,
            smartQuotesType: widget.smartQuotesType,
            enableSuggestions: widget.enableSuggestions,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            expands: widget.expands,
            maxLength: widget.maxLength,
            maxLengthEnforcement: widget.maxLengthEnforcement,
            onTap: widget.onTap,
            onTapOutside: (event) {
              print("++++ outside +++++");
              _removeOverlay();
              widget.onTapOutside?.call();
            },
            onChanged: widget.onChanged != null
                ? (value) {
                    // Обрабатываем в _onTextChanged
                  }
                : null,
            onSubmitted: (value) {
              print("++++ submit +++++");
              _removeOverlay();
              widget.onSubmitted?.call(value);
            },
            onAppPrivateCommand: widget.onAppPrivateCommand,
            inputFormatters: widget.inputFormatters,
            enabled: widget.enabled,
            cursorWidth: widget.cursorWidth,
            cursorHeight: widget.cursorHeight,
            cursorRadius: widget.cursorRadius,
            cursorColor: widget.cursorColor,
            selectionHeightStyle: widget.selectionHeightStyle,
            selectionWidthStyle: widget.selectionWidthStyle,
            keyboardAppearance: widget.keyboardAppearance,
            scrollPadding: widget.scrollPadding,
            enableInteractiveSelection: widget.enableInteractiveSelection,
            selectionControls: widget.selectionControls,
            buildCounter: widget.buildCounter,
            scrollPhysics: widget.scrollPhysics,
            autofillHints: widget.autofillHints,
            // autovalidateMode: widget.autovalidateMode,
            scrollController: widget.scrollController,
            restorationId: widget.restorationId,
            enableIMEPersonalizedLearning: widget.enableIMEPersonalizedLearning,
            mouseCursor: widget.mouseCursor,
            spellCheckConfiguration: widget.spellCheckConfiguration,
            magnifierConfiguration: widget.magnifierConfiguration,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }
}

/*

2. Исправление ширины подсказок:
dart
// Добавляем GlobalKey для TextField
final GlobalKey _textFieldKey = GlobalKey();

// В build методе:
TextField(
  key: _textFieldKey, // Ключ для измерения
  // ...
)

// Метод для получения ширины:
double _getTextFieldWidth() {
  try {
    final renderBox = _textFieldKey.currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.size.width ?? 300;
  } catch (e) {
    return 300;
  }
}

// В Overlay ограничиваем ширину:
Container(
  constraints: BoxConstraints(
    maxHeight: 200,
    maxWidth: textFieldWidth, // Такая же ширина как у TextField
  ),
  // ...
)
*/