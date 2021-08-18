import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

import '../design.dart';

class CrystalFlushbar {
  static Future<void> show(
    BuildContext context, {
    required String message,
  }) async {
    await Flushbar(
      messageText: Text(
        message,
        style: const TextStyle(
          color: CrystalColor.chipText,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: CrystalColor.grayBackground,
      duration: const Duration(seconds: 2),
    ).show(context);
  }

  static Future<void> showError(
    BuildContext context, {
    required String message,
  }) async {
    await Flushbar(
      messageText: Text(
        message,
        style: const TextStyle(
          color: CrystalColor.error,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: CrystalColor.grayBackground,
      duration: const Duration(seconds: 2),
    ).show(context);
  }
}
