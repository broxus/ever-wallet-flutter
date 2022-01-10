import 'package:flutter/material.dart';

import '../../../../../../design/design.dart';

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
