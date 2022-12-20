import 'package:ever_wallet/application/common/general/field/bordered_input.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/generated/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class EWTypeAheadField extends StatefulWidget {
  final double? height;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool autocorrect;
  final bool enableSuggestions;
  final void Function(String)? onSubmitted;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final String? labelText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final SuggestionsCallback<String> suggestionsCallback;
  final ItemBuilder<String> itemBuilder;
  final SuggestionSelectionCallback<String> onSuggestionSelected;
  final Color? enabledBorderColor;
  final Color? inactiveBorderColor;
  final Color? errorColor;

  /// Callback to add button to clear field
  final VoidCallback? onClearField;
  final bool needClearButton;

  final Color? suggestionBackground;
  final TextStyle? textStyle;

  const EWTypeAheadField({
    super.key,
    this.controller,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.onSubmitted,
    this.validator,
    this.onChanged,
    this.inputFormatters,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    required this.suggestionsCallback,
    required this.itemBuilder,
    required this.onSuggestionSelected,
    this.height,
    this.onClearField,
    this.needClearButton = true,
    this.suggestionBackground,
    this.textStyle,
    this.enabledBorderColor,
    this.inactiveBorderColor,
    this.errorColor,
  });

  @override
  State<EWTypeAheadField> createState() => _EWTypeAheadFieldState();
}

class _EWTypeAheadFieldState extends State<EWTypeAheadField> {
  late TextEditingController _controller;
  bool isEmpty = true;
  String currentInputText = '';

  FormFieldState<String>? field;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();

    _controller.addListener(_handleInput);

    _controller.addListener(() {
      final value = _controller.text;
      if (!mounted) return;
      _handleInput();
      field?.didChange(value);
    });
  }

  @override
  void didUpdateWidget(covariant EWTypeAheadField oldWidget) {
    if (widget.controller != null && widget.controller != _controller) {
      _controller.removeListener(_handleInput);
      _controller = widget.controller!;
      _controller.addListener(_handleInput);
    }
    return super.didUpdateWidget(oldWidget);
  }

  void _handleInput() {
    if (!mounted) return;
    final inputText = _controller.text;
    isEmpty = inputText.isEmpty;
    if (currentInputText != inputText) {
      currentInputText = inputText;
    }
  }

  @override
  Widget build(BuildContext context) => FormField<String>(
        validator: widget.validator,
        initialValue: _controller.text,
        builder: (state) {
          final themeStyle = context.themeStyle;
          field = state;

          return SizedBox(
            height: widget.height ?? kBorderedInputHeight,
            child: TypeAheadField<String>(
              autoFlipDirection: true,
              hideOnEmpty: true,
              hideOnError: true,
              hideOnLoading: true,
              textFieldConfiguration: TextFieldConfiguration(
                style: widget.textStyle ?? themeStyle.styles.basicStyle,
                controller: _controller,
                focusNode: widget.focusNode,
                keyboardType: widget.keyboardType ?? TextInputType.text,
                onChanged: widget.onChanged,
                textInputAction: widget.textInputAction ?? TextInputAction.next,
                cursorWidth: 1,
                cursorColor: widget.textStyle?.color ?? themeStyle.styles.basicStyle.color,
                onSubmitted: widget.onSubmitted,
                autocorrect: widget.autocorrect,
                enableSuggestions: widget.enableSuggestions,
                inputFormatters: widget.inputFormatters,
                decoration: InputDecoration(
                  errorText: state.hasError ? '' : null,
                  errorStyle: const TextStyle(fontSize: 0, height: 0),
                  labelText: widget.labelText,
                  labelStyle: widget.textStyle ?? themeStyle.styles.basicStyle,
                  contentPadding: EdgeInsets.zero,
                  suffixIcon: _buildSuffixIcon(),
                  prefixIconConstraints: widget.prefixIcon == null
                      ? const BoxConstraints(maxHeight: 0, maxWidth: 16)
                      : const BoxConstraints(minHeight: kBorderedInputHeight, minWidth: 35),
                  prefixIcon: widget.prefixIcon ?? const SizedBox(width: 16),
                  border: OutlineInputBorder(
                    gapPadding: 1,
                    borderRadius: BorderRadius.circular(0),
                    borderSide: BorderSide(
                      color: widget.inactiveBorderColor ?? themeStyle.colors.inactiveInputColor,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    gapPadding: 1,
                    borderRadius: BorderRadius.circular(0),
                    borderSide:
                        BorderSide(color: widget.inactiveBorderColor ?? ColorsRes.greyLight),
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
                      color: widget.errorColor ?? themeStyle.colors.errorInputColor,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    gapPadding: 1,
                    borderRadius: BorderRadius.circular(0),
                    borderSide: BorderSide(
                      color: widget.errorColor ?? themeStyle.colors.errorInputColor,
                    ),
                  ),
                ),
              ),
              suggestionsCallback: widget.suggestionsCallback,
              itemBuilder: widget.itemBuilder,
              suggestionsBoxDecoration: SuggestionsBoxDecoration(
                color: widget.suggestionBackground ?? ColorsRes.black.withOpacity(0.9),
              ),
              onSuggestionSelected: widget.onSuggestionSelected,
            ),
          );
        },
      );

  Widget _buildSuffixIcon() {
    if (widget.suffixIcon != null) return widget.suffixIcon!;
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
            color: widget.textStyle?.color?.withOpacity(0.45) ??
                context.themeStyle.colors.inactiveInputColor,
          ),
        ),
      ),
    );
  }

  void _clearText() {
    widget.onClearField?.call();
    isEmpty = true;
    _controller.clear();
  }
}
