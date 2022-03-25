import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class DateTitle extends StatelessWidget {
  final DateTime date;

  const DateTitle({
    Key? key,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Text(
        DateFormat('MMM d, H:mm').format(date),
      );
}
