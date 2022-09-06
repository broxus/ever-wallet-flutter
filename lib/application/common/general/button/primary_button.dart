import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

const kPrimaryButtonHeight = 50.0;

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
    this.isTransparent = false,
    this.icon,
    Key? key,
    this.style,
    this.child,
    this.focusNode,
    this.radius,
    this.backgroundColor,
    this.height = kPrimaryButtonHeight,
    this.padding,
    this.fillWidth = true,
    this.presstateColor,
  }) : super(key: key);

  final String? text;
  final VoidCallback? onPressed;
  final TextStyle? style;
  final bool isTransparent;
  final Widget? icon;

  final Widget? child;
  final FocusNode? focusNode;
  final BorderRadius? radius;
  final double? height;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final Color? presstateColor;
  final bool fillWidth;

  @override
  Widget build(BuildContext context) {
    final palette = context.themeStyle;

    final textStyle = style ??
        (isTransparent ? palette.styles.secondaryButtonStyle : palette.styles.primaryButtonStyle);
    final bgColor = backgroundColor ??
        (isTransparent ? palette.colors.secondaryButtonColor : palette.colors.primaryButtonColor);
    final pressColor = presstateColor ??
        (isTransparent
            ? palette.colors.secondaryPressStateColor
            : palette.colors.primaryPressStateColor);

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
                  if (text != null) const SizedBox(width: 12),
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
            splashColor: pressColor,
            onTap: onPressed,
            child: fillWidth
                ? Center(child: _child)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [_child],
                  ),
          ),
        ),
      ),
    );
  }
}
