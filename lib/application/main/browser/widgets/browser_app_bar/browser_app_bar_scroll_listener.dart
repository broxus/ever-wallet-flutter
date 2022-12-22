import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Listener that allow appbar to be scrolled when user scrolls inside WebView
/// [value] - height of appbar that should be visible
class BrowserAppBarScrollListener extends ValueNotifier<double> {
  BrowserAppBarScrollListener(this.pullToRefreshController) : super(.0);
  static const appBarHeight = 65.0;
  final PullToRefreshController pullToRefreshController;

  final browserFlexibleKey = GlobalKey();
  int _prevValue = 0;

  Future<void> webViewScrolled(int dY) async {
    final isRefreshing = await pullToRefreshController.isRefreshing();
    final insignificantDistance = (dY - _prevValue).abs() < 100;

    if (insignificantDistance || isRefreshing) return;

    if (dY > _prevValue) {
      value = -appBarHeight;
      pullToRefreshController.setEnabled(false);
    } else {
      value = 0;
      pullToRefreshController.setEnabled(true);
    }

    _prevValue = dY;
  }
}
