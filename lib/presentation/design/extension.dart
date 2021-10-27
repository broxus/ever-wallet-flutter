import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'design.dart';

extension FastMediaQuery on BuildContext {
  MediaQueryData get media => MediaQuery.of(this);

  Size get screenSize => media.size;
  EdgeInsets get safeArea => media.padding;
  EdgeInsets get keyboardInsets => media.viewInsets;
}

extension StringX on String {
  String get capitalize =>
      trim().split('.').map((e) => e.isNotEmpty ? e.replaceFirst(e[0], e[0].toUpperCase()) : e).join(' ').trim();
}

extension DoubleX on double {
  String toStringAsCrypto({
    int minimumFractionDigits = 2,
    int maximumFractionDigits = 9,
    bool allowMinusSign = true,
    bool allowPlusSign = false,
    String? currency,
  }) {
    final buffer = StringBuffer("###,###,##0");

    if (minimumFractionDigits > 0 || maximumFractionDigits > 0) buffer.write('.');

    for (var i = 0; i < minimumFractionDigits; i++) {
      buffer.write('0');
    }

    final additionalFractionDigits = maximumFractionDigits - minimumFractionDigits;
    if (additionalFractionDigits > 0) {
      for (var i = 0; i < additionalFractionDigits; i++) {
        buffer.write('#');
      }
    }

    final formatter = NumberFormat(buffer.toString(), 'en_EN');
    final formattedValue = formatter.format(this).replaceFirst(formatter.symbols.MINUS_SIGN, '');

    buffer.clear();

    if (sign > 0 && allowPlusSign) {
      buffer.write(formatter.symbols.PLUS_SIGN);
      buffer.write(' ');
    } else if (sign < 0 && allowMinusSign) {
      buffer.write(formatter.symbols.MINUS_SIGN);
      buffer.write(' ');
    }
    buffer.write(formattedValue);

    if (currency != null) {
      buffer.write(' ');
      buffer.write(currency);
    }

    return buffer.toString();
  }
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
    final dot = indexOf(".");
    if (dot != -1) {
      if (length - dot > 2) {
        final firstPart = substring(0, dot);
        final secondPart = substring(dot, dot + 3);

        return firstPart + secondPart;
      } else {
        final firstPart = substring(0, dot);
        final secondPart = substring(dot, length).padRight(3, "0");

        return firstPart + secondPart;
      }
    } else {
      return this;
    }
  }
}

extension RemoveZeroes on String {
  String removeZeroes() {
    final dot = indexOf(".");
    if (dot != -1) {
      return replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "");
    } else {
      return this;
    }
  }
}

extension ElipseValue on String {
  String elipseValue() {
    if (length > 12) {
      return "${substring(0, 12)}...";
    } else {
      return this;
    }
  }
}

extension Elipse on String {
  String elipseAddress() => '${substring(0, 6)}...${substring(length - 4, length)}';

  String elipsePublicKey() => '${substring(0, 4)}...${substring(length - 4, length)}';
}
