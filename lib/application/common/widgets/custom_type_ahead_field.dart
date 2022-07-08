import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class CustomTypeAheadField extends StatefulWidget {
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
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final FutureOr<Iterable<Object?>> Function(String) suggestionsCallback;
  final Widget Function(BuildContext, Object?) itemBuilder;
  final void Function(Object?) onSuggestionSelected;

  const CustomTypeAheadField({
    Key? key,
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
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    required this.suggestionsCallback,
    required this.itemBuilder,
    required this.onSuggestionSelected,
  }) : super(key: key);

  @override
  State<CustomTypeAheadField> createState() => _CustomTypeAheadFieldState();
}

class _CustomTypeAheadFieldState extends State<CustomTypeAheadField> {
  FormFieldState<String>? field;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(() {
      final value = widget.controller?.text;

      if (value != null) {
        field?.didChange(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) => FormField<String>(
        validator: widget.validator,
        builder: (field) {
          this.field = field;

          return TypeAheadField(
            autoFlipDirection: true,
            hideOnEmpty: true,
            hideOnError: true,
            hideOnLoading: true,
            textFieldConfiguration: TextFieldConfiguration(
              decoration: InputDecoration(
                hintText: widget.hintText,
                prefixIcon: widget.prefixIcon,
                suffixIcon: widget.suffixIcon,
                prefixIconConstraints: const BoxConstraints.tightFor(width: 38),
                suffixIconConstraints: const BoxConstraints.tightFor(width: 38),
                errorStyle: errorStyle(),
                contentPadding: EdgeInsets.zero,
                errorBorder: errorBorder(),
                focusedBorder: field.isValid ? border() : errorBorder(),
                focusedErrorBorder: errorBorder(),
                disabledBorder: field.isValid ? border() : errorBorder(),
                enabledBorder: field.isValid ? border() : errorBorder(),
                border: field.isValid ? border() : errorBorder(),
              ),
              style: style(),
              controller: widget.controller,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              focusNode: widget.focusNode,
              keyboardType: widget.keyboardType ?? TextInputType.text,
              textInputAction: widget.textInputAction,
              autocorrect: widget.autocorrect,
              enableSuggestions: widget.enableSuggestions,
              inputFormatters: widget.inputFormatters,
              cursorWidth: 1,
            ),
            suggestionsCallback: widget.suggestionsCallback,
            itemBuilder: widget.itemBuilder,
            onSuggestionSelected: widget.onSuggestionSelected,
          );
        },
      );

  TextStyle errorStyle() => const TextStyle(
        color: Colors.transparent,
        height: 0,
        fontSize: 0,
      );

  TextStyle style() => const TextStyle(
        color: Colors.black,
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
