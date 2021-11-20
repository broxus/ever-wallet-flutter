import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool autocorrect;
  final bool enableSuggestions;
  final bool obscureText;
  final void Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const CustomTextFormField({
    Key? key,
    this.controller,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.obscureText = false,
    this.onFieldSubmitted,
    this.validator,
    this.onChanged,
    this.inputFormatters,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => TextFormField(
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
        onFieldSubmitted: onFieldSubmitted,
        validator: validator,
        onChanged: onChanged,
        inputFormatters: inputFormatters,
        cursorWidth: 1,
      );

  InputBorder border() => const OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.black12,
        ),
        borderRadius: BorderRadius.all(Radius.zero),
        gapPadding: 0,
      );

  InputBorder errorBorder() => const OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.red,
        ),
        borderRadius: BorderRadius.all(Radius.zero),
        gapPadding: 0,
      );
}
