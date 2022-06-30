import 'package:flutter/cupertino.dart';

import '../../../util/extensions/context_extensions.dart';

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
    return _buildCupertinoDialog(context);
  }

  Widget _buildCupertinoDialog(BuildContext context) {
    final themeStyle = context.themeStyle;
    final localization = context.localization;
    final alertText = this.alertText;
    final contentText = this.contentText;

    return CupertinoAlertDialog(
      title: titleWidget ??
          (alertText == null
              ? null
              : Text(
                  alertText,
                  style: themeStyle.styles.basicStyle,
                )),
      content: contentWidget ??
          (contentText != null ? Text(contentText, style: themeStyle.styles.basicStyle) : null),
      actions: <Widget>[
        if (onDisagreeClicked != null)
          CupertinoDialogAction(
            onPressed: onDisagreeClicked,
            child: Text(
              cancelText ?? localization.cancel,
              style: themeStyle.styles.secondaryButtonStyle,
            ),
          ),
        CupertinoDialogAction(
          onPressed: onAgreeClicked,
          child: Text(
            okText ?? localization.ok,
            style: themeStyle.styles.secondaryButtonStyle,
          ),
        ),
      ],
    );
  }

// Widget _buildMaterialDialog(BuildContext context) {
//   final themeStyle = context.themeStyle;
//   final localization = context.localization;
//   final alertText = this.alertText;
//   final contentText = this.contentText;
//
//   return AlertDialog(
//     backgroundColor: themeStyle.colors.primaryBackgroundColor,
//     title: titleWidget ??
//         (alertText == null
//             ? null
//             : Text(
//                 alertText,
//                 style: themeStyle.styles.basicStyle,
//               )),
//     content: contentWidget ??
//         (contentText != null ? Text(contentText, style: themeStyle.styles.basicStyle) : null),
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.all(Radius.circular(16.0)),
//     ),
//     actions: <Widget>[
//       if (onDisagreeClicked != null)
//         TextPrimaryButton(
//           onPressed: onDisagreeClicked,
//           child: Text(cancelText ?? localization.cancel),
//         ),
//       TextPrimaryButton(
//         onPressed: onAgreeClicked,
//         child: Text(okText ?? localization.ok),
//       )
//     ],
//   );
// }
}
