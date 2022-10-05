import 'package:ever_wallet/application/common/theme.dart';
import 'package:flutter/material.dart';

class ValueTitle extends StatelessWidget {
  final String value;
  final String currency;
  final bool isOutgoing;

  const ValueTitle({
    super.key,
    required this.value,
    required this.currency,
    required this.isOutgoing,
  });

  @override
  Widget build(BuildContext context) => Text(
        '${isOutgoing ? '-' : ''}$value $currency',
        style: TextStyle(
          color: isOutgoing ? CrystalColor.error : CrystalColor.success,
          fontWeight: FontWeight.w600,
        ),
      );
}
