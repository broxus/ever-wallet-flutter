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
    super.key,
    this.style,
    this.child,
    this.focusNode,
    this.radius,
    this.backgroundColor,
    this.height = kPrimaryButtonHeight,
    this.padding,
    this.fillWidth = true,
    this.presstateColor,
    this.border,
  });

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
  final BoxBorder? border;

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

    Widget child;
    if (this.child == null) {
      final textWidget = Text(text ?? '', style: textStyle);
      child = Padding(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16.0),
        child: icon == null
            ? textWidget
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon!,
                  if (text != null) const SizedBox(width: 12),
                  textWidget,
                ],
              ),
      );
    } else {
      child = this.child!;
    }

    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: radius ?? BorderRadius.zero,
          border: border,
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
                ? Center(child: child)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [child],
                  ),
          ),
        ),
      ),
    );
  }
}
