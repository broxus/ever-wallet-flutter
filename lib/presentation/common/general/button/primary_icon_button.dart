import 'package:flutter/material.dart';

import '../../../util/colors.dart';
import 'push_state_ink_widget.dart';

class PrimaryIconButton extends StatelessWidget {
  const PrimaryIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.innerPadding = const EdgeInsets.all(8),
    this.outerPadding = const EdgeInsets.all(8),
    this.backgroundColor = Colors.transparent,
    this.presstateColor = ColorsRes.greyOpacity,
  }) : super(key: key);

  final Widget icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color presstateColor;

  /// Padding from icon to edge of press state
  final EdgeInsets innerPadding;

  /// Padding from outer widgets to edge of press state
  final EdgeInsets outerPadding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      child: Padding(
        padding: outerPadding,
        child: PushStateInkWidget(
          pressStateColor: presstateColor,
          borderRadius: BorderRadius.circular(90),
          onPressed: onPressed,
          child: Padding(
            padding: innerPadding,
            child: icon,
          ),
        ),
      ),
    );
  }
}
