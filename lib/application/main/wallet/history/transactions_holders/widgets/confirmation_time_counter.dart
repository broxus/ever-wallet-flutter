import 'dart:async';

import 'package:duration/duration.dart';
import 'package:flutter/material.dart';

class ConfirmationTimeCounter extends StatefulWidget {
  final DateTime expireAt;

  const ConfirmationTimeCounter({
    Key? key,
    required this.expireAt,
  }) : super(key: key);

  @override
  _ConfirmationTimeCounterState createState() => _ConfirmationTimeCounterState();
}

class _ConfirmationTimeCounterState extends State<ConfirmationTimeCounter> {
  late Duration remaining;

  @override
  void initState() {
    super.initState();
    remaining = widget.expireAt.difference(DateTime.now());

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() => remaining = widget.expireAt.difference(DateTime.now()));

      if (remaining.isNegative) {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) => Text(
        '${prettyDuration(
          remaining,
          abbreviated: true,
        )} left for confirmation',
        style: const TextStyle(
          color: Colors.black45,
        ),
      );
}
