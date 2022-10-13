import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Listener that allow appbar to be scrolled when user scrolls inside WebView
/// [value] - height of appbar that should be visible
class BrowserAppBarScrollListener extends ValueNotifier<double> {
  BrowserAppBarScrollListener() : super(.0);
  static const appBarHeight = 65.0;

  final browserFlexibleKey = GlobalKey();
  double _prevValue = 0.0;

  /// Timer that signalize about webView scrolling progress.
  /// WebView can continue scrolling even if user removes finger from the screen, so to jump appbar
  /// correctly, it waits for some delay when scrolling finish
  Timer? _scrollTimer;
  static const _scrollDelay = Duration(milliseconds: 500);
  bool _isHolding = false;

  void webViewScrolled(int dY) {
    /// delta could be from 1.0 to 150.0 so to move appbar smoothly it is reduces
    final delta = (dY - _prevValue) / 8;

    final render = browserFlexibleKey.currentContext?.findRenderObject();
    final height = render?.semanticBounds.size.height ?? appBarHeight;
    final userScrollDirection = delta > 0 ? ScrollDirection.reverse : ScrollDirection.forward;

    if (delta > 0 && value > -height && userScrollDirection == ScrollDirection.reverse) {
      var newPosition = value - delta;
      if (newPosition < -height) newPosition = -height;
      value = newPosition;
    } else if (delta < 0 && value < 0 && userScrollDirection == ScrollDirection.forward) {
      var newPosition = value - delta;
      if (newPosition > 0) newPosition = 0;
      value = newPosition;
    }

    _prevValue = dY.toDouble();
    _scrollTimer?.cancel();
    _scrollTimer = Timer(_scrollDelay, _jumpToNearestPosition);
  }

  void startHolding() => _isHolding = true;

  void stopHolding() => _isHolding = false;

  /// When user stops holding finger, appbar jumps to the nearest position (top or bottom) so the
  /// appbar won't stay at any middle position
  void _jumpToNearestPosition() {
    if (_isHolding) return;

    if (value < -appBarHeight / 2) {
      value = -appBarHeight;
    } else {
      value = 0;
    }
  }
}
