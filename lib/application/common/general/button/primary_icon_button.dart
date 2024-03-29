import 'package:ever_wallet/application/common/general/button/push_state_ink_widget.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:flutter/material.dart';

class PrimaryIconButton extends StatelessWidget {
  const PrimaryIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.innerPadding = const EdgeInsets.all(8),
    this.outerPadding = const EdgeInsets.all(8),
    this.backgroundColor = Colors.transparent,
    this.presstateColor = ColorsRes.neutral750,
    this.decoration,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color presstateColor;

  /// Padding from icon to edge of press state
  final EdgeInsets innerPadding;

  /// Padding from outer widgets to edge of press state
  final EdgeInsets outerPadding;

  /// Allow add some border
  final BoxDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(90),
      color: backgroundColor,
      child: Padding(
        padding: outerPadding,
        child: DecoratedBox(
          decoration: decoration ?? const BoxDecoration(),
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
      ),
    );
  }
}
