import 'package:ever_wallet/application/common/general/button/push_state_ink_widget.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

const defaultListTileHeight = 64.0;

class EWListTile extends StatelessWidget {
  const EWListTile({
    this.onPressed,
    this.titleWidget,
    this.titleText,
    this.subtitleWidget,
    this.subtitleText,
    this.leading,
    this.trailing,
    this.backgroundColor,
    this.presstateColor,
    this.height = defaultListTileHeight,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16),
    Key? key,
  }) : super(key: key);

  final VoidCallback? onPressed;

  final Widget? titleWidget;
  final String? titleText;

  final Widget? subtitleWidget;
  final String? subtitleText;

  final double height;

  final Widget? leading;
  final Widget? trailing;

  final Color? backgroundColor;
  final Color? presstateColor;
  final EdgeInsets contentPadding;

  @override
  Widget build(BuildContext context) {
    final themeStyle = context.themeStyle;

    return Material(
      color: themeStyle.colors.secondaryBackgroundColor,
      borderRadius: BorderRadius.zero,
      child: PushStateInkWidget(
        onPressed: onPressed,
        pressStateColor: presstateColor,
        child: Container(
          height: height,
          padding: contentPadding,
          child: Row(
            children: [
              if (leading != null) leading!,
              if (leading != null) const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (titleWidget != null)
                      titleWidget!
                    else
                      Text(
                        titleText ?? '',
                        style: themeStyle.styles.basicStyle.copyWith(
                          color: ColorsRes.text,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    if (subtitleWidget != null)
                      subtitleWidget!
                    else if (subtitleText != null)
                      Text(
                        subtitleText!,
                        style: themeStyle.styles.subtitleStyle,
                      ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
