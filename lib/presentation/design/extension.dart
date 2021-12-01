import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'design.dart';

extension FastMediaQuery on BuildContext {
  MediaQueryData get media => MediaQuery.of(this);

  Size get screenSize => media.size;
  EdgeInsets get safeArea => media.padding;
  EdgeInsets get keyboardInsets => media.viewInsets;
}

extension Capitalize on String {
  String get capitalize =>
      trim().split('.').map((e) => e.isNotEmpty ? e.replaceFirst(e[0], e[0].toUpperCase()) : e).join(' ').trim();
}

extension FormatTransactionTime on DateTime {
  String format() {
    final DateFormat formatter = DateFormat('MM/dd/yy HH:mm');
    final String formatted = formatter.format(this);
    return formatted;
  }
}

extension FloorValue on String {
  String floorValue() {
    final dot = indexOf('.');
    if (dot != -1) {
      if (length - dot > 2) {
        final firstPart = substring(0, dot);
        final secondPart = substring(dot, dot + 3);

        return firstPart + secondPart;
      } else {
        final firstPart = substring(0, dot);
        final secondPart = substring(dot, length).padRight(3, '0');

        return firstPart + secondPart;
      }
    } else {
      return this;
    }
  }
}

extension RemoveZeroes on String {
  String removeZeroes() {
    final dot = indexOf('.');
    if (dot != -1) {
      return replaceAll(RegExp(r'([.]*0+)(?!.*\d)'), '');
    } else {
      return this;
    }
  }
}

extension FormatValue on String {
  String formatValue() {
    String addSpaces(String string) => string.replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );

    if (contains('.')) {
      final values = split('.');
      final firstPart = addSpaces(values.first);
      final lastPart = values.last;

      return [firstPart, lastPart].join('.');
    } else {
      return addSpaces(this);
    }
  }
}

extension Elipse on String {
  String ellipseAddress() => '${substring(0, 6)}...${substring(length - 4, length)}';

  String ellipsePublicKey() => '${substring(0, 4)}...${substring(length - 4, length)}';
}
