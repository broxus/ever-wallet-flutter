import 'package:ever_wallet/application/common/general/default_appbar.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

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

const kAppBarButtonSize = 32.0;
const kAppBarButtonPadding = EdgeInsets.symmetric(horizontal: 8, vertical: 4);

/// Default appbar for onboarding screens
class OnboardingAppBar extends StatelessWidget implements PreferredSizeWidget {
  const OnboardingAppBar({
    this.onClosePressed,
    this.onActionsClosePressed,
    this.actions,
    this.leading,
    this.closeType = CloseType.leading,
    this.backgroundColor = Colors.transparent,
    this.backColor,
    super.key,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  /// Action when closing with [CloseType.leading] or [CloseType.multi]
  final VoidCallback? onClosePressed;

  /// Action when closing with [CloseType.actions] or [CloseType.multi]
  /// If not specified [onClosePressed] will be used
  final VoidCallback? onActionsClosePressed;

  final List<Widget>? actions;

  final Widget? leading;

  /// Type how to close [OnboardingAppBar]
  final CloseType closeType;

  final Color? backgroundColor;

  final Color? backColor;

  @override
  Widget build(BuildContext context) {
    return DefaultAppBar(
      backText: context.localization.back_word,
      backgroundColor: backgroundColor,
      closeType: closeType,
      actions: actions,
      leading: leading,
      onActionsClosePressed: onActionsClosePressed,
      onClosePressed: onClosePressed,
      needDivider: false,
      backColor: backColor ?? context.themeStyle.colors.primaryButtonColor,
    );
  }
}
