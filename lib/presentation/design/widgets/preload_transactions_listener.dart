import 'package:flutter/material.dart';

class PreloadTransactionsListener extends StatelessWidget {
  final Widget child;
  final void Function() onNotification;

  const PreloadTransactionsListener({
    Key? key,
    required this.child,
    required this.onNotification,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => NotificationListener<ScrollUpdateNotification>(
        onNotification: (ScrollUpdateNotification notification) {
          final isDown = notification.dragDetails?.primaryDelta?.sign == -1.0;
          final pixels = notification.metrics.pixels;
          final maxScrollExtent = notification.metrics.maxScrollExtent;
          final loadingZone = MediaQuery.of(context).size.longestSide / 3;

          if (isDown && pixels > maxScrollExtent - loadingZone) onNotification();

          return false;
        },
        child: child,
      );
}
