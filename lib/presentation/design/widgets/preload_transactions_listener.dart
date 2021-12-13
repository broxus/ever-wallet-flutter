import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

class PreloadTransactionsListener extends StatefulWidget {
  final Widget child;
  final TransactionId? prevTransactionId;
  final void Function() onLoad;

  const PreloadTransactionsListener({
    Key? key,
    required this.child,
    required this.prevTransactionId,
    required this.onLoad,
  }) : super(key: key);

  @override
  _PreloadTransactionsListenerState createState() => _PreloadTransactionsListenerState();
}

class _PreloadTransactionsListenerState extends State<PreloadTransactionsListener> {
  TransactionId? lastPrevTransactionId;

  @override
  Widget build(BuildContext context) => NotificationListener<ScrollUpdateNotification>(
        onNotification: (ScrollUpdateNotification notification) {
          if (widget.prevTransactionId == null) {
            return false;
          }

          final pixels = notification.metrics.pixels;
          final maxScrollExtent = notification.metrics.maxScrollExtent;
          final prevTransactionId = widget.prevTransactionId;

          if (pixels > maxScrollExtent - MediaQuery.of(context).size.longestSide / 3 &&
              prevTransactionId != lastPrevTransactionId) {
            lastPrevTransactionId = prevTransactionId;
            widget.onLoad();
          }

          return false;
        },
        child: widget.child,
      );
}
