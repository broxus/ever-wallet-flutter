import 'package:another_flushbar/flushbar.dart';
import 'package:ever_wallet/application/common/theme.dart';
import 'package:flutter/material.dart';

Flushbar? _previousFlushbar;

Future<void> showCrystalFlushbar(
  BuildContext context, {
  required String message,
  FlushbarPosition flushbarPosition = FlushbarPosition.TOP,
  EdgeInsets? margin,
}) async {
  _previousFlushbar?.dismiss();

  _previousFlushbar = Flushbar(
    messageText: Text(
      message,
      style: const TextStyle(
        color: CrystalColor.chipText,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
    flushbarPosition: flushbarPosition,
    backgroundColor: CrystalColor.primary,
    borderColor: CrystalColor.border,
    margin: const EdgeInsets.symmetric(horizontal: 16) + (margin ?? EdgeInsets.zero),
    duration: const Duration(seconds: 2),
  )..show(context);
}

Future<void> showErrorCrystalFlushbar(
  BuildContext context, {
  required String message,
  FlushbarPosition flushbarPosition = FlushbarPosition.TOP,
  EdgeInsets? margin,
}) async {
  _previousFlushbar?.dismiss();

  _previousFlushbar = Flushbar(
    messageText: Text(
      message,
      style: const TextStyle(
        color: CrystalColor.error,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
    flushbarPosition: flushbarPosition,
    backgroundColor: CrystalColor.primary,
    borderColor: CrystalColor.border,
    margin: const EdgeInsets.symmetric(horizontal: 16) + (margin ?? EdgeInsets.zero),
    duration: const Duration(seconds: 2),
  )..show(context);
}
