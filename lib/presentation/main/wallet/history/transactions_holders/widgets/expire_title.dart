import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ExpireTitle extends StatelessWidget {
  final DateTime date;
  final bool expired;

  const ExpireTitle({
    Key? key,
    required this.date,
    required this.expired,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Text(
        '${expired ? 'Expired' : 'Expires'} at ${DateFormat('MMM d, H:mm').format(date)}',
        style: const TextStyle(
          color: Colors.black45,
        ),
      );
}
