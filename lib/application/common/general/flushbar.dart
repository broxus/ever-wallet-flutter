import 'package:another_flushbar/flushbar.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
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
