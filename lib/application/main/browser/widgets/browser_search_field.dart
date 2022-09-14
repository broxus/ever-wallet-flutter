import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/styles.dart';
import 'package:flutter/material.dart';

class BrowserSearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focus;
  final String hintText;
  final ValueChanged<String>? onSubmitted;
  final Widget suffixIcon;

  const BrowserSearchField({
    required this.controller,
    required this.focus,
    required this.hintText,
    required this.suffixIcon,
    this.onSubmitted,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        focusNode: focus,
        style: StylesRes.basicText.copyWith(
          color: ColorsRes.black,
          fontWeight: FontWeight.normal,
        ),
        keyboardType: TextInputType.text,
        onSubmitted: onSubmitted,
        textInputAction: TextInputAction.search,
        cursorColor: ColorsRes.bluePrimary400,
        autocorrect: false,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: StylesRes.basicText.copyWith(color: ColorsRes.neutral500),
          suffixIcon: suffixIcon,
          fillColor: ColorsRes.neutral750,
          filled: true,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}
