import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

class PreloadTransactionsListener extends StatefulWidget {
  final Widget child;
  final TransactionId? prevTransId;
  final void Function() onLoad;

  const PreloadTransactionsListener({
    Key? key,
    required this.child,
    required this.prevTransId,
    required this.onLoad,
  }) : super(key: key);

  @override
  _PreloadTransactionsListenerState createState() => _PreloadTransactionsListenerState();
}

class _PreloadTransactionsListenerState extends State<PreloadTransactionsListener> {
  TransactionId? lastPrevTransId;

  @override
  Widget build(BuildContext context) => NotificationListener<ScrollUpdateNotification>(
        onNotification: (ScrollUpdateNotification notification) {
          if (widget.prevTransId == null) {
            return false;
          }

          final pixels = notification.metrics.pixels;
          final maxScrollExtent = notification.metrics.maxScrollExtent;
          final prevTransId = widget.prevTransId;

          if (pixels > maxScrollExtent && prevTransId != lastPrevTransId) {
            lastPrevTransId = prevTransId;
            widget.onLoad();
          }
          return false;
        },
        child: widget.child,
      );
}
