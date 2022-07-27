import 'package:ever_wallet/application/common/general/button/text_button.dart';
import 'package:ever_wallet/application/common/general/default_divider.dart';
import 'package:ever_wallet/application/common/general/onboarding_appbar.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

/// Default appbar for authorized zone.
/// When you use that appbar, title should be displayed in other part of UI
class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DefaultAppBar({
    this.onClosePressed,
    this.onActionsClosePressed,
    this.actions,
    this.leading,
    this.closeType = CloseType.leading,
    this.backgroundColor = Colors.transparent,
    Key? key,
    this.backText,
    this.needDivider = true,
    this.backColor,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  /// Color of back arrow and text
  final Color? backColor;

  final String? backText;

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
  final bool needDivider;

  bool get _hasActions => actions?.isNotEmpty ?? false;

  bool get _hasActionsAll => _hasActions || _showActionsClose;

  bool get _showLeadingClose => closeType == CloseType.leading || closeType == CloseType.multi;

  bool get _showActionsClose => closeType == CloseType.actions || closeType == CloseType.multi;

  @override
  Widget build(BuildContext context) {
    final themeStyle = context.themeStyle;
    final mq = MediaQuery.of(context);

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.zero,
      child: Container(
        margin: EdgeInsets.only(top: mq.padding.top + 5),
        height: preferredSize.height,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: leading ??
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
                                        color: backColor ??
                                            themeStyle.colors.textPrimaryTextButtonColor,
                                        size: 20,
                                      ),
                                      if (backText != null)
                                        Text(
                                          backText!,
                                          style: themeStyle.styles.basicStyle.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: backColor ??
                                                themeStyle.colors.textPrimaryTextButtonColor,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              )
                            : const SizedBox(width: kAppBarButtonSize)),
                  ),
                  if (_hasActionsAll)
                    Flexible(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: _hasActions
                            ? actions!
                            : [
                                if (_showActionsClose)
                                  TextPrimaryButton(
                                    onPressed: onActionsClosePressed ??
                                        onClosePressed ??
                                        () => Navigator.of(context).maybePop(),
                                    padding: kAppBarButtonPadding,
                                    child: Icon(
                                      Icons.close,
                                      color: themeStyle.colors.primaryButtonColor,
                                    ),
                                  )
                                else
                                  const SizedBox(width: kAppBarButtonSize)
                              ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            if (needDivider) const DefaultDivider(),
          ],
        ),
      ),
    );
  }
}
