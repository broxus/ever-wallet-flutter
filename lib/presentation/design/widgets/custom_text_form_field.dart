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

  const CustomTextFormField({
    Key? key,
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
  }) : super(key: key);

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

  InputBorder border() => const OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.black12,
        ),
        borderRadius: BorderRadius.zero,
        gapPadding: 0,
      );

  InputBorder errorBorder() => const OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.red,
        ),
        borderRadius: BorderRadius.zero,
        gapPadding: 0,
      );
}
