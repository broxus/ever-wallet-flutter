import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../generated/assets.gen.dart';
import '../../../util/colors.dart';
import '../../../util/extensions/context_extensions.dart';

const kBorderedInputHeight = 46.0;
const _openKeyboardDuration = Duration(milliseconds: 20);

class BorderedInput extends StatefulWidget {
  final double? height;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? label;

  /// Callback to add button to clear field
  final VoidCallback? onClearField;
  final bool needClearButton;

  final Widget? prefix;
  final Widget? suffix;
  final TextInputType? textInputType;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;

  /// To display only error border return empty string
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onSubmitted;

  final bool obscureText;
  final String? errorText;
  final TextStyle? textStyle;
  final List<TextInputFormatter>? formatters;
  final Color? cursorColor;
  final AutovalidateMode? autovalidateMode;

  /// If error must not be displayed (to avoid bottom space) set false
  final bool needError;

  const BorderedInput({
    Key? key,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.label,
    this.onClearField,
    this.needClearButton = true,
    this.prefix,
    this.suffix,
    this.textInputType,
    this.onChanged,
    this.textInputAction,
    this.validator,
    this.onSubmitted,
    this.height,
    this.obscureText = false,
    this.errorText,
    this.textStyle,
    this.formatters,
    this.cursorColor,
    this.autovalidateMode,
    this.needError = true,
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
    if (!mounted) return;
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

    return FormField<String>(
      validator: widget.validator,
      initialValue: _controller.text,
      autovalidateMode: widget.autovalidateMode,
      builder: (state) {
        final errorStyle = themeStyle.styles.captionStyle;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: widget.height ?? kBorderedInputHeight,
              child: TextField(
                style: widget.textStyle ?? themeStyle.styles.basicStyle,
                controller: _controller,
                focusNode: widget.focusNode,
                keyboardType: widget.textInputType,
                onChanged: widget.onChanged,
                textInputAction: widget.textInputAction ?? TextInputAction.next,
                cursorWidth: 1,
                cursorColor: widget.cursorColor,
                onSubmitted: widget.onSubmitted,
                obscureText: widget.obscureText,
                inputFormatters: widget.formatters,
                decoration: InputDecoration(
                  errorText: state.hasError ? '' : null,
                  errorStyle: const TextStyle(fontSize: 0, height: 0),
                  labelText: widget.label,
                  labelStyle: widget.textStyle ?? themeStyle.styles.basicStyle,
                  contentPadding: EdgeInsets.zero,
                  suffixIcon: _buildSuffixIcon(),
                  prefixIconConstraints: widget.prefix == null
                      ? const BoxConstraints(maxHeight: 0, maxWidth: 16)
                      : const BoxConstraints(minHeight: kBorderedInputHeight, minWidth: 35),
                  prefixIcon: widget.prefix ?? const SizedBox(width: 16),
                  border: OutlineInputBorder(
                    gapPadding: 1,
                    borderRadius: BorderRadius.circular(0),
                    borderSide: BorderSide(
                      color: themeStyle.colors.inactiveInputColor,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    gapPadding: 1,
                    borderRadius: BorderRadius.circular(0),
                    borderSide: const BorderSide(color: ColorsRes.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    gapPadding: 1,
                    borderRadius: BorderRadius.circular(0),
                    borderSide: BorderSide(
                      color: themeStyle.colors.activeInputColor,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    gapPadding: 1,
                    borderRadius: BorderRadius.circular(0),
                    borderSide: BorderSide(
                      color: themeStyle.colors.errorInputColor,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    gapPadding: 1,
                    borderRadius: BorderRadius.circular(0),
                    borderSide: BorderSide(
                      color: themeStyle.colors.errorInputColor,
                    ),
                  ),
                ),
              ),
            ),
            if (widget.needError)
              if (state.hasError && state.errorText!.isNotEmpty || widget.errorText != null)
                Text(
                  widget.errorText ?? state.errorText!,
                  style: errorStyle.copyWith(color: themeStyle.colors.errorTextColor),
                )
              else
                SizedBox(height: errorStyle.fontSize! * errorStyle.height!),
          ],
        );
      },
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
