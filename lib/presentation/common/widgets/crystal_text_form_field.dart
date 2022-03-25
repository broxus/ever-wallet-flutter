import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../generated/fonts.gen.dart';
import '../theme.dart';

class CrystalTextFormField extends StatelessWidget {
  static const kEmptyErrorStyle = TextStyle(
    height: 0,
    color: Colors.transparent,
  );
  static const kErrorStyle = TextStyle(
    fontSize: 12,
    letterSpacing: 0.4,
    color: CrystalColor.error,
  );
  static const kTextStyle = TextStyle(
    fontSize: 16,
    letterSpacing: 0.25,
    fontFamily: FontFamily.pt,
    color: CrystalColor.fontDark,
    fontWeight: FontWeight.w400,
  );
  static const kHintStyle = TextStyle(
    fontSize: 16,
    letterSpacing: 0.25,
    fontFamily: FontFamily.pt,
    color: CrystalColor.fontSecondaryDark,
    fontWeight: FontWeight.w400,
  );
  static const kInputBorder = OutlineInputBorder(
    borderSide: BorderSide(color: CrystalColor.divider),
    borderRadius: BorderRadius.zero,
  );
  static const kContentPadding = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 18,
  );
  final TextEditingController? controller;
  final String? initialValue;
  final FocusNode? focusNode;
  final List<TextInputFormatter> formatters;
  final String hintText;
  final TextStyle style;
  final TextStyle hintStyle;
  final TextStyle errorStyle;
  final String obscuringCharacter;
  final bool autofocus;
  final bool autocorrect;
  final bool enabled;
  final bool enableInteractiveSelection;
  final bool enableSuggestions;
  final bool expands;
  final bool obscureText;
  final bool readOnly;
  final bool showCursor;
  final Color? cursorColor;
  final double cursorWidth;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final int? maxLines;
  final int? minLines;
  final int maxLength;
  final TextCapitalization capitalization;
  final TextInputAction inputAction;
  final TextInputType? keyboardType;
  final TextSelectionControls? selectionControls;
  final ToolbarOptions? toolbarOptions;
  final ScrollPhysics? scrollPhysics;
  final EdgeInsets scrollPadding;
  final EdgeInsets? contentPadding;
  final Brightness? keyboardAppearance;
  final VoidCallback? onTap;
  final void Function(String)? onChanged;
  final VoidCallback? onEditingComplete;
  final void Function(String)? onFieldSubmitted;
  final void Function(String?)? onSaved;
  final Widget? suffix;
  final BoxConstraints? suffixConstraints;
  final Widget? prefix;
  final BoxConstraints? prefixConstraints;
  final InputBorder? border;
  final Iterable<String>? autofillHints;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final Color backgroundColor;

  const CrystalTextFormField({
    Key? key,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.scrollPhysics,
    this.selectionControls,
    this.toolbarOptions,
    this.keyboardType,
    this.keyboardAppearance,
    this.autofillHints,
    this.prefix,
    this.prefixConstraints,
    this.suffix,
    this.suffixConstraints,
    this.onTap,
    this.onChanged,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.onSaved,
    this.validator,
    this.autovalidateMode,
    this.maxLength = 256,
    this.minLines,
    this.maxLines = 1,
    this.obscuringCharacter = '•',
    this.hintText = ' ',
    this.formatters = const [],
    this.errorStyle = kEmptyErrorStyle,
    this.hintStyle = kHintStyle,
    this.style = kTextStyle,
    this.border = kInputBorder,
    this.cursorHeight,
    this.cursorWidth = 1,
    this.cursorColor = CrystalColor.cursorColor,
    this.cursorRadius = Radius.zero,
    this.inputAction = TextInputAction.next,
    this.capitalization = TextCapitalization.none,
    this.scrollPadding = EdgeInsets.zero,
    this.autofocus = false,
    this.autocorrect = true,
    this.enabled = true,
    this.enableInteractiveSelection = true,
    this.enableSuggestions = false,
    this.expands = false,
    this.obscureText = false,
    this.readOnly = false,
    this.showCursor = true,
    this.contentPadding,
    this.backgroundColor = Colors.transparent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: backgroundColor,
        child: TextFormField(
          validator: validator,
          autovalidateMode: autovalidateMode,
          enabled: enabled,
          controller: controller,
          initialValue: initialValue,
          focusNode: focusNode,
          inputFormatters: formatters,
          autofocus: autofocus,
          autocorrect: autocorrect,
          maxLines: maxLines,
          minLines: minLines,
          expands: expands,
          maxLength: maxLength,
          obscureText: obscureText,
          obscuringCharacter: obscuringCharacter,
          style: style,
          textCapitalization: capitalization,
          textInputAction: inputAction,
          enableSuggestions: enableSuggestions,
          enableInteractiveSelection: enableInteractiveSelection,
          showCursor: showCursor,
          scrollPadding: scrollPadding,
          scrollPhysics: scrollPhysics,
          selectionControls: selectionControls,
          keyboardAppearance: keyboardAppearance,
          toolbarOptions: toolbarOptions,
          keyboardType: keyboardType,
          cursorColor: cursorColor,
          cursorWidth: cursorWidth,
          cursorHeight: cursorHeight,
          cursorRadius: cursorRadius,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChanged,
          onEditingComplete: onEditingComplete,
          onFieldSubmitted: onFieldSubmitted,
          onSaved: onSaved,
          autofillHints: autofillHints,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: hintStyle,
            isCollapsed: true,
            counterText: '',
            contentPadding: contentPadding ??
                EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: (style.fontSize ?? 16) - 2,
                ),
            errorStyle: errorStyle,
            border: border,
            enabledBorder: border,
            focusedBorder: border,
            errorBorder: border?.copyWith(borderSide: const BorderSide(color: CrystalColor.error)),
            focusedErrorBorder: border?.copyWith(borderSide: const BorderSide(color: CrystalColor.error)),
            suffixIcon: suffix,
            suffixIconConstraints: suffixConstraints,
            prefixIcon: prefix,
            prefixIconConstraints: prefixConstraints,
          ),
        ),
      );
}
