import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTitle extends StatelessWidget {
  final DateTime date;

  const DateTitle({
    super.key,
    required this.date,
  });

  @override
  Widget build(BuildContext context) => Text(
        DateFormat('MMM d, H:mm').format(date),
      );
}
