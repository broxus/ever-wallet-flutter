import 'package:ever_wallet/application/common/general/button/text_button.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

/// alert dialog that checks platform itself
class PlatformAlertDialog extends StatelessWidget {
  const PlatformAlertDialog({
    this.onAgreeClicked,
    this.onDisagreeClicked,
    this.alertText,
    this.titleWidget,
    this.contentText,
    this.contentWidget,
    this.cancelText,
    this.okText,
    Key? key,
  }) : super(key: key);
  final String? alertText;
  final Widget? titleWidget;
  final String? contentText;
  final Widget? contentWidget;
  final String? cancelText;
  final String? okText;
  final VoidCallback? onAgreeClicked;
  final VoidCallback? onDisagreeClicked;

  @override
  Widget build(BuildContext context) {
    // final platform = Theme.of(context).platform;

    // return platform == TargetPlatform.iOS
    //     ? _buildCupertinoDialog(context)
    return _buildMaterialDialog(context);
  }

  // Widget _buildCupertinoDialog(BuildContext context) {
  //   final themeStyle = context.themeStyle;
  //   final localization = context.localization;
  //   final alertText = this.alertText;
  //   final contentText = this.contentText;
  //
  //   return CupertinoAlertDialog(
  //     title: titleWidget ??
  //         (alertText == null ? null : Text(alertText, style: themeStyle.styles.basicStyle)),
  //     content: contentWidget ??
  //         (contentText != null ? Text(contentText, style: themeStyle.styles.basicStyle) : null),
  //     actions: <Widget>[
  //       if (onDisagreeClicked != null)
  //         CupertinoDialogAction(
  //           onPressed: onDisagreeClicked,
  //           child: Text(
  //             cancelText ?? localization.cancel,
  //             style: themeStyle.styles.secondaryButtonStyle,
  //           ),
  //         ),
  //       CupertinoDialogAction(
  //         onPressed: onAgreeClicked,
  //         child: Text(
  //           okText ?? localization.ok,
  //           style: themeStyle.styles.secondaryButtonStyle,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildMaterialDialog(BuildContext context) {
    final themeStyle = context.themeStyle;
    final localization = context.localization;
    final alertText = this.alertText;
    final contentText = this.contentText;

    return AlertDialog(
      backgroundColor: themeStyle.colors.primaryBackgroundColor,
      title: titleWidget ??
          (alertText == null
              ? null
              : Text(
                  alertText,
                  style: themeStyle.styles.basicStyle,
                )),
      content: contentWidget ??
          (contentText != null ? Text(contentText, style: themeStyle.styles.basicStyle) : null),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
      actionsOverflowAlignment: OverflowBarAlignment.center,
      actions: <Widget>[
        if (onDisagreeClicked != null)
          TextPrimaryButton(
            fillWidth: false,
            onPressed: onDisagreeClicked,
            style: themeStyle.styles.basicStyle,
            text: cancelText ?? localization.cancel,
          ),
        TextPrimaryButton(
          fillWidth: false,
          onPressed: onAgreeClicked,
          style: themeStyle.styles.basicStyle,
          text: okText ?? localization.ok,
        )
      ],
    );
  }
}
