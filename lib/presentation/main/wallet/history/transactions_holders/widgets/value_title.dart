import 'package:flutter/material.dart';

import '../../../../../common/theme.dart';

class ValueTitle extends StatelessWidget {
  final String value;
  final String currency;
  final bool isOutgoing;

  const ValueTitle({
    Key? key,
    required this.value,
    required this.currency,
    required this.isOutgoing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Text(
        '${isOutgoing ? '-' : ''}$value $currency',
        style: TextStyle(
          color: isOutgoing ? CrystalColor.error : CrystalColor.success,
          fontWeight: FontWeight.w600,
        ),
      );
}
