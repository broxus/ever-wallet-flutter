import 'package:flutter/material.dart';

import '../../../util/extensions/context_extensions.dart';

/// PressState for default widgets with ink response
class PushStateInkWidget extends StatelessWidget {
  const PushStateInkWidget({
    Key? key,
    this.onPressed,
    this.child,
    this.onLongPress,
    this.borderRadius = BorderRadius.zero,
    this.pressStateColor,
  }) : super(key: key);

  final Widget? child;
  final Color? pressStateColor;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final presState = pressStateColor ?? context.themeStyle.colors.primaryPressStateColor;

    assert(debugCheckHasMaterial(context));

    return InkResponse(
      splashColor: Colors.transparent,
      highlightColor: presState,
      highlightShape: BoxShape.rectangle,
      onLongPress: onLongPress,
      onTap: onPressed,
      borderRadius: borderRadius,
      child: child,
    );
  }
}
