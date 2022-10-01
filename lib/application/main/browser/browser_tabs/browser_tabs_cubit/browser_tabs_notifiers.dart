import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:ever_wallet/data/models/browser_tabs_dto.dart';
import 'package:flutter/foundation.dart';

class BrowserTabsList {
  BrowserTabsList(this._tabs, this._lastActiveIndex);

  int _lastActiveIndex;

  int get lastActiveIndex => _lastActiveIndex;

  set lastActiveIndex(int value) {
    _lastActiveIndex = value;
    _tabs.forEach((tab) => tab.isTabActive = tab.currentIndex == _lastActiveIndex);
  }

  final List<BrowserTabNotifier> _tabs;

  List<BrowserTabNotifier> get tabs => List.unmodifiable(_tabs);

  List<BrowserTab> get tabsDto => List.unmodifiable(_tabs.map((e) => e._tab));

  void addTab(BrowserTab browserTab) {
    _tabs.add(BrowserTabNotifier(browserTab, _tabs.length, true));
    lastActiveIndex = _tabs.length - 1;
  }

  // ignore: use_setters_to_change_properties
  void updateCurrentTab(BrowserTab newTabData) =>
      _tabs[lastActiveIndex]._updateTabWithNotification(newTabData);

  void updateCurrentTabData(int scrollPosition, Uint8List? screenshot) {
    _tabs[lastActiveIndex].tab = _tabs[lastActiveIndex].tab.copyWith(
          lastScrollPosition: scrollPosition,
          screenshot: screenshot,
        );
  }

  /// Remote tab by index and returns new index
  int removeTab(int tabIndex) {
    final prevIndex = lastActiveIndex;
    _tabs.removeAt(tabIndex).dispose();

    int newIndex;
    // "!" - deleted, "." - current
    // 0, .1, !2 - index didn't change
    if (prevIndex < tabIndex) {
      newIndex = prevIndex;
      // 0, !1, .2 - index moved to deleted position (all tabs shifted)
    } else if (_tabs.length > tabIndex) {
      newIndex = tabIndex;
      // 0, .!1 or .!0, 1 - select last tab
    } else if (_tabs.isNotEmpty) {
      newIndex = _tabs.length - 1;
      // no tabs in list
    } else {
      newIndex = -1;
    }
    lastActiveIndex = newIndex;
    _tabs.forEachIndexed((i, t) => t.currentIndex = i);
    return newIndex;
  }

  void closeAllTabs() {
    while (_tabs.isNotEmpty) {
      _tabs.removeLast().dispose();
    }
  }
}

/// This notifier guarantees that all webViews won't be updated if one of webView changes
class BrowserTabNotifier extends ChangeNotifier {
  BrowserTabNotifier(this._tab, this._currentIndex, this._isTabActive);

  final webViewTabKey = UniqueKey();

  int _currentIndex;
  bool _isTabActive;
  BrowserTab _tab;

  int get currentIndex => _currentIndex;

  set isTabActive(bool value) {
    _isTabActive = value;
    notifyListeners();
  }

  bool get isTabActive => _isTabActive;

  set currentIndex(int value) {
    _currentIndex = value;
    notifyListeners();
  }

  // ignore: unnecessary_getters_setters
  BrowserTab get tab => _tab;

  set tab(BrowserTab value) => _tab = value;

  void _updateTabWithNotification(BrowserTab tab) {
    _tab = tab;
    notifyListeners();
  }
}
