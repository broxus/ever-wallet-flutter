import 'package:ever_wallet/application/common/general/dialog/dialog_widget.dart';
import 'package:flutter/material.dart';

class DefaultDialogController {
  static Future<R?> showAlertDialog<R>({
    required BuildContext context,
    String? title,
    String? message,
    String? agreeText,
    String? cancelText,
    void Function(BuildContext context)? onAgreeClicked,
    void Function(BuildContext context)? onDisagreeClicked,
    bool useRootNavigator = true,
  }) {
    return showDialog<R>(
      context: context,
      useRootNavigator: useRootNavigator,
      builder: (ctx) => PlatformAlertDialog(
        alertText: title,
        contentText: message,
        okText: agreeText,
        cancelText: cancelText,
        onAgreeClicked: onAgreeClicked != null ? () => onAgreeClicked(ctx) : null,
        onDisagreeClicked: onDisagreeClicked != null ? () => onDisagreeClicked(ctx) : null,
      ),
    );
  }
}
