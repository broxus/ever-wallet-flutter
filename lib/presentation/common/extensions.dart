import 'dart:math';

import 'constants.dart';

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

extension Ellipse on String {
  String ellipseAddress() => '${substring(0, 6)}...${substring(length - 4, length)}';

  String ellipsePublicKey() => '${substring(0, 4)}...${substring(length - 4, length)}';
}

extension TokensConvert on String {
  String toTokens([int decimals = kTonDecimals]) {
    final radix = BigInt.from(pow(10, decimals));

    final number = BigInt.parse(this);

    final lead = number ~/ radix;
    final leadStr = lead.toString();

    final trail = number % radix;
    var trailStr = trail.toString();

    if (trailStr.length > decimals) {
      trailStr = trailStr.substring(0, decimals);
    }

    trailStr = trailStr.padLeft(decimals, '0');

    return '$leadStr.$trailStr';
  }

  String fromTokens([int decimals = kTonDecimals]) {
    final radix = BigInt.from(pow(10, decimals));

    final dot = indexOf('.');

    if (dot != -1) {
      final integerStr = substring(0, dot);
      final integer = BigInt.parse(integerStr);

      var decimalStr = substring(dot + 1);
      decimalStr =
          decimalStr.length > decimals ? decimalStr.substring(0, decimals) : decimalStr.padRight(decimals, '0');

      if (integer > BigInt.zero) {
        return '$integer$decimalStr';
      } else {
        final result = BigInt.parse(decimalStr);
        return result.toString();
      }
    } else {
      final result = BigInt.parse(this) * radix;
      return result.toString();
    }
  }
}

extension ToDateTime on int {
  DateTime toDateTime() => DateTime.fromMillisecondsSinceEpoch(this * Duration.millisecondsPerSecond);
}
