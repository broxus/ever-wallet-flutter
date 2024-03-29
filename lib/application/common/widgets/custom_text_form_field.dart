import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class CustomTextFormField extends StatelessWidget {
  final Key? fieldKey;
  final String name;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool autocorrect;
  final bool enableSuggestions;
  final bool obscureText;
  final void Function(String?)? onSubmitted;
  final String? Function(String?)? validator;
  final void Function(String?)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLength;
  final Color? borderColor;
  final Color? errorBorderColor;
  final Color? cursorColor;

  const CustomTextFormField({
    super.key,
    this.fieldKey,
    required this.name,
    this.controller,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.obscureText = false,
    this.onSubmitted,
    this.validator,
    this.onChanged,
    this.inputFormatters,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLength,
    this.borderColor,
    this.errorBorderColor,
    this.cursorColor,
  });

  @override
  Widget build(BuildContext context) => FormBuilderTextField(
        key: fieldKey,
        name: name,
        autovalidateMode: AutovalidateMode.always,
        controller: controller,
        focusNode: focusNode,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          errorStyle: const TextStyle(
            color: Colors.transparent,
            height: 0,
            fontSize: 0,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          errorBorder: errorBorder(),
          focusedBorder: border(),
          focusedErrorBorder: errorBorder(),
          disabledBorder: border(),
          enabledBorder: border(),
          border: border(),
        ),
        cursorColor: cursorColor ?? Colors.black,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        style: const TextStyle(
          color: Colors.black,
        ),
        autocorrect: autocorrect,
        enableSuggestions: enableSuggestions,
        obscureText: obscureText,
        onSubmitted: onSubmitted,
        validator: validator,
        onChanged: onChanged,
        inputFormatters: inputFormatters,
        cursorWidth: 1,
        maxLength: maxLength,
        buildCounter: (
          context, {
          required int currentLength,
          required bool isFocused,
          required int? maxLength,
        }) =>
            null,
      );

  InputBorder border() => OutlineInputBorder(
        borderSide: BorderSide(
          color: borderColor ?? Colors.black12,
        ),
        borderRadius: BorderRadius.zero,
        gapPadding: 0,
      );

  InputBorder errorBorder() => OutlineInputBorder(
        borderSide: BorderSide(
          color: errorBorderColor ?? Colors.red,
        ),
        borderRadius: BorderRadius.zero,
        gapPadding: 0,
      );
}

class CustomTextFormFieldWithDecoration extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool autofocus;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool autocorrect;
  final bool enableSuggestions;
  final bool obscureText;
  final void Function(String?)? onSubmitted;
  final String? Function(String?)? validator;
  final void Function(String?)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final String? errorText;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLength;
  final Color? borderColor;
  final Color? errorBorderColor;

  const CustomTextFormFieldWithDecoration({
    super.key,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.obscureText = false,
    this.onSubmitted,
    this.validator,
    this.onChanged,
    this.inputFormatters,
    this.errorText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLength,
    this.borderColor,
    this.errorBorderColor,
  });

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        decoration: InputDecoration(
          errorText: errorText,
          hintText: hintText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          errorStyle: const TextStyle(
            color: Colors.transparent,
            height: 0,
            fontSize: 0,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          errorBorder: errorBorder(),
          focusedBorder: border(),
          focusedErrorBorder: errorBorder(),
          disabledBorder: border(),
          enabledBorder: border(),
          border: border(),
        ),
        keyboardType: keyboardType,
        cursorColor: Colors.black,
        textInputAction: textInputAction,
        style: const TextStyle(
          color: Colors.black,
        ),
        autocorrect: autocorrect,
        enableSuggestions: enableSuggestions,
        obscureText: obscureText,
        onSubmitted: onSubmitted,
        onChanged: onChanged,
        inputFormatters: inputFormatters,
        cursorWidth: 1,
        maxLength: maxLength,
        buildCounter: (
          context, {
          required int currentLength,
          required bool isFocused,
          required int? maxLength,
        }) =>
            null,
      );

  InputBorder border() => OutlineInputBorder(
        borderSide: BorderSide(
          color: borderColor ?? Colors.black12,
        ),
        borderRadius: BorderRadius.zero,
        gapPadding: 0,
      );

  InputBorder errorBorder() => OutlineInputBorder(
        borderSide: BorderSide(
          color: errorBorderColor ?? Colors.red,
        ),
        borderRadius: BorderRadius.zero,
        gapPadding: 0,
      );
}
