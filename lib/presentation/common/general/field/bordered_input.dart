import 'package:flutter/material.dart';

import '../../../../generated/assets.gen.dart';
import '../../../util/extensions/context_extensions.dart';

const _inputHeight = 46.0;
const _openKeyboardDuration = Duration(milliseconds: 20);

class BorderedInput extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? hint;

  /// Callback to add button to clear field
  final VoidCallback? onClearField;
  final bool needClearButton;

  final Widget? prefix;
  final Widget? suffix;
  final TextInputType? textInputType;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;

  const BorderedInput({
    Key? key,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.hint,
    this.onClearField,
    this.needClearButton = true,
    this.prefix,
    this.suffix,
    this.textInputType,
    this.onChanged,
    this.textInputAction,
  }) : super(key: key);

  @override
  State<BorderedInput> createState() => _BorderedInputState();
}

class _BorderedInputState extends State<BorderedInput> {
  late TextEditingController _controller;
  bool isEmpty = true;
  String currentInputText = '';

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();

    _controller.addListener(_handleInput);
    if (widget.autofocus) {
      Future<void>.delayed(_openKeyboardDuration).then(
        (_) => widget.focusNode?.requestFocus(),
      );
    }
    _handleInput();
  }

  @override
  void didUpdateWidget(covariant BorderedInput oldWidget) {
    if (widget.controller != null && widget.controller != _controller) {
      _controller.removeListener(_handleInput);
      _controller = widget.controller!;
      _controller.addListener(_handleInput);
    }
    return super.didUpdateWidget(oldWidget);
  }

  void _handleInput() {
    setState(() {
      final inputText = _controller.text;
      isEmpty = inputText.isEmpty;
      if (currentInputText != inputText) {
        currentInputText = inputText;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeStyle = context.themeStyle;

    return SizedBox(
      height: _inputHeight,
      child: TextFormField(
        style: themeStyle.styles.basicStyle,
        controller: _controller,
        focusNode: widget.focusNode,
        keyboardType: widget.textInputType,
        onChanged: widget.onChanged,
        textInputAction: widget.textInputAction ?? TextInputAction.next,
        cursorWidth: 1,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          suffixIcon: _buildSuffixIcon(),
          prefixIconConstraints: const BoxConstraints(
            minHeight: _inputHeight,
            minWidth: 35,
          ),
          prefixIcon: widget.prefix,
          border: OutlineInputBorder(
            gapPadding: 1,
            borderSide: BorderSide(
              color: themeStyle.colors.inactiveInputColor,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            gapPadding: 1,
            borderSide: BorderSide(
              color: themeStyle.colors.activeInputColor,
            ),
          ),
          errorBorder: OutlineInputBorder(
            gapPadding: 1,
            borderSide: BorderSide(
              color: themeStyle.colors.errorInputColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuffixIcon() {
    if (widget.suffix != null) return widget.suffix!;
    if (widget.needClearButton && !isEmpty) {
      return _buildClearIcon();
    }

    return const SizedBox.shrink();
  }

  Widget _buildClearIcon() {
    return GestureDetector(
      onTap: _clearText,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 30, maxWidth: 30),
        padding: const EdgeInsets.only(left: 8.0),
        child: Center(
          child: Assets.images.iconCross.svg(
            color: context.themeStyle.colors.inactiveInputColor,
          ),
        ),
      ),
    );
  }

  void _clearText() {
    widget.onClearField?.call();
    setState(() {
      isEmpty = true;
      _controller.clear();
    });
  }
}
