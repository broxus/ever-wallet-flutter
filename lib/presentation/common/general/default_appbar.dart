import 'package:flutter/material.dart';

import '../../util/extensions/context_extensions.dart';
import 'button/text_button.dart';

/// Type of closing screen
enum CloseType {
  /// top left arrow button
  leading,

  /// top right cross button
  actions,

  /// leading + actions
  multi,

  /// without close buttons
  none,
}

const kMinLeadingButtonWidth = 80.0;
const kAppBarButtonSize = 32.0;
const kAppBarButtonPadding = EdgeInsets.symmetric(vertical: 4);

/// Стандартный аппбар со стрелкой назад
class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DefaultAppBar({
    this.title,
    this.onClosePressed,
    this.onActionsClosePressed,
    this.actions,
    this.leading,
    this.closeType = CloseType.leading,
    this.backgroundColor = Colors.transparent,
    this.centerTitle = false,
    Key? key,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  final Widget? title;

  /// Action when closing with [CloseType.leading] or [CloseType.multi]
  final VoidCallback? onClosePressed;

  /// Action when closing with [CloseType.actions] or [CloseType.multi]
  /// If not specified [onClosePressed] will be used
  final VoidCallback? onActionsClosePressed;

  final List<Widget>? actions;

  final Widget? leading;

  /// Type how to close [DefaultAppBar]
  final CloseType closeType;

  final Color? backgroundColor;

  final bool centerTitle;

  bool get _hasActions => actions?.isNotEmpty ?? false;

  bool get _showLeadingClose => closeType == CloseType.leading || closeType == CloseType.multi;

  bool get _showActionsClose => closeType == CloseType.actions || closeType == CloseType.multi;

  @override
  Widget build(BuildContext context) {
    final themeStyle = context.themeStyle;

    return AppBar(
      title: title,
      centerTitle: centerTitle,
      leadingWidth:
          leading != null || _showLeadingClose ? kMinLeadingButtonWidth : kMinInteractiveDimension,
      leading: leading ??
          (_showLeadingClose
              ? TextPrimaryButton.appBar(
                  onPressed: onClosePressed ?? () => Navigator.of(context).maybePop(),
                  child: Padding(
                    padding: kAppBarButtonPadding,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_back_ios,
                          color: themeStyle.colors.primaryButtonColor,
                          size: 20,
                        ),
                        Text(
                          // TODO: change text
                          'Back',
                          style: themeStyle.styles.basicBoldStyle,
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox(width: kAppBarButtonSize)),
      backgroundColor: backgroundColor,
      elevation: 0.0,
      titleSpacing: 0.0,
      actions: _hasActions
          ? actions
          : [
              if (_showActionsClose)
                TextPrimaryButton(
                  onPressed: onActionsClosePressed ??
                      onClosePressed ??
                      () => Navigator.of(context).maybePop(),
                  padding: kAppBarButtonPadding,
                  child: Icon(Icons.close, color: themeStyle.colors.primaryButtonColor),
                )
              else
                const SizedBox(width: kAppBarButtonSize)
            ],
      automaticallyImplyLeading: false,
    );
  }
}
