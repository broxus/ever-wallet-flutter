import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomPopupItem {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final void Function()? onTap;

  const CustomPopupItem({
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });
}
