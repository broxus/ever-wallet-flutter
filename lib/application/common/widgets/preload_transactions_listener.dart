import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class PreloadTransactionsListener extends StatefulWidget {
  final ScrollController scrollController;
  final void Function() onNotification;
  final Widget child;

  const PreloadTransactionsListener({
    Key? key,
    required this.scrollController,
    required this.onNotification,
    required this.child,
  }) : super(key: key);

  @override
  State<PreloadTransactionsListener> createState() => _PreloadTransactionsListenerState();
}

class _PreloadTransactionsListenerState extends State<PreloadTransactionsListener> {
  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_scrollControllerListener);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_scrollControllerListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;

  void _scrollControllerListener() {
    if (!mounted) return;

    final isDown = widget.scrollController.position.userScrollDirection == ScrollDirection.reverse;
    final pixels = widget.scrollController.position.pixels;
    final maxScrollExtent = widget.scrollController.position.maxScrollExtent;
    final loadingZone = MediaQuery.of(context).size.longestSide / 4;

    if (isDown && pixels > maxScrollExtent - loadingZone) widget.onNotification();
  }
}
