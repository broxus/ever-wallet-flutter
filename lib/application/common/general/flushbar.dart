import 'package:another_flushbar/flushbar.dart';
import 'package:ever_wallet/application/common/general/button/text_button.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/application/util/styles.dart';
import 'package:ever_wallet/application/utils.dart';
import 'package:flutter/material.dart';

export 'package:another_flushbar/flushbar.dart';

const kFlushbarDisplayDuration = Duration(seconds: 2);

Flushbar? _previousFlushbar;

Future<void> showFlushbar(
  BuildContext context, {
  required String message,
  FlushbarPosition flushbarPosition = FlushbarPosition.TOP,
  EdgeInsets margin = const EdgeInsets.symmetric(vertical: 8),
}) async {
  _previousFlushbar?.dismiss();

  final theme = context.themeStyle;

  _previousFlushbar = Flushbar(
    messageText: Text(
      message,
      style: theme.styles.basicStyle,
    ),
    flushbarPosition: flushbarPosition,
    borderRadius: BorderRadius.circular(10),
    backgroundColor: theme.colors.primaryBackgroundColor,
    margin: const EdgeInsets.symmetric(horizontal: 16) + margin,
    duration: kFlushbarDisplayDuration,
  )..show(context);
}

Future<void> showErrorFlushbar(
  BuildContext context, {
  required String message,
  FlushbarPosition flushbarPosition = FlushbarPosition.TOP,
  EdgeInsets margin = const EdgeInsets.symmetric(vertical: 16),
}) async {
  _previousFlushbar?.dismiss();

  final theme = context.themeStyle;

  _previousFlushbar = Flushbar(
    messageText: Text(
      message,
      style: theme.styles.basicStyle.copyWith(color: theme.colors.errorTextColor),
    ),
    borderRadius: BorderRadius.circular(10),
    flushbarPosition: flushbarPosition,
    backgroundColor: theme.colors.primaryBackgroundColor,
    margin: const EdgeInsets.symmetric(horizontal: 16) + margin,
    duration: kFlushbarDisplayDuration,
  )..show(context);
}

Future<void> showFlushbarWithAction({
  required BuildContext context,
  required String text,
  required String actionText,
  required VoidCallback action,
  FlushbarPosition flushbarPosition = FlushbarPosition.BOTTOM,
  EdgeInsets margin = const EdgeInsets.symmetric(vertical: 8),
}) async {
  _previousFlushbar?.dismiss();

  _previousFlushbar = Flushbar(
    messageText: Text(
      text.overflow,
      style: StylesRes.regular16.copyWith(color: ColorsRes.black),
      maxLines: 1,
    ),
    mainButton: TextPrimaryButton(
      onPressed: () {
        action();
        _previousFlushbar?.dismiss();
      },
      text: actionText,
      style: StylesRes.buttonText.copyWith(color: ColorsRes.bluePrimary400),
      fillWidth: false,
    ),
    flushbarPosition: flushbarPosition,
    borderRadius: BorderRadius.circular(10),
    backgroundColor: ColorsRes.neutral950,
    margin: const EdgeInsets.symmetric(horizontal: 16) + margin,
    duration: const Duration(seconds: 3),
  )..show(context);
}
