import 'package:flutter/material.dart';

import '../../../util/extensions/context_extensions.dart';

const kPrimaryButtonHeight = 40.0;

/// Default button in the app.
/// Typically you do not need to specify text style or background color. It is picked up from theme.
///
/// Simple usages:
/// ```
/// PrimaryButton(text: 'MyButton', onPressed: (){})
/// ```dart
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    this.text,
    this.onPressed,
    this.isOpacity = false,
    this.icon,
    Key? key,
    this.style,
    this.child,
    this.focusNode,
    this.radius,
    this.backgroundColor,
    this.height = kPrimaryButtonHeight,
    this.padding,
    this.presstateColor,
    this.splashColor,
  }) : super(key: key);

  final String? text;
  final VoidCallback? onPressed;
  final TextStyle? style;
  final bool isOpacity;
  final Widget? icon;

  final Widget? child;
  final FocusNode? focusNode;
  final BorderRadius? radius;
  final double? height;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final Color? presstateColor;
  final Color? splashColor;

  @override
  Widget build(BuildContext context) {
    final palette = context.themeStyle;

    final textStyle = style ??
        (isOpacity ? palette.styles.secondaryButtonStyle : palette.styles.primaryButtonStyle);
    final bgColor = backgroundColor ??
        (isOpacity ? palette.colors.secondaryButtonColor : palette.colors.primaryButtonColor);

    Widget _child;
    if (child == null) {
      final _textWidget = Text(text ?? '', style: textStyle);
      _child = Padding(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16.0),
        child: icon == null
            ? _textWidget
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon!,
                  const SizedBox(width: 12),
                  _textWidget,
                ],
              ),
      );
    } else {
      _child = child!;
    }

    return SizedBox(
      height: height,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: radius ?? BorderRadius.zero,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            focusNode: focusNode,
            customBorder: RoundedRectangleBorder(
              borderRadius: radius ?? BorderRadius.zero,
            ),
            highlightColor: presstateColor,
            splashColor: splashColor,
            onTap: onPressed,
            child: Center(child: _child),
          ),
        ),
      ),
    );
  }
}
