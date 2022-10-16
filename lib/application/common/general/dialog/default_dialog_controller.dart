import 'package:ever_wallet/application/common/general/dialog/dialog_widget.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

/// Controller that allows to display dialogs/loaders etc
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

  /// Show full screen loader
  /// ```dart
  /// final OverlaySupportEntry entry = DefaultDialogController.showFullScreenLoader();
  /// close
  /// entry?.dismiss();
  /// ```
  static OverlaySupportEntry showFullScreenLoader() {
    return showOverlay(
      (context, animationValue) {
        return Opacity(
          opacity: animationValue,
          child: Container(
            color: ColorsRes.modalBarrier,
            child: const Center(
              child: CircularProgressIndicator(color: ColorsRes.neutral750),
            ),
          ),
        );
      },
      duration: Duration.zero,
    );
  }
}
