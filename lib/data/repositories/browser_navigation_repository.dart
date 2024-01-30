import 'dart:async';

import 'package:rxdart/subjects.dart';

class BrowserNavigationRepository {
  final _subject = BehaviorSubject<BrowserNavigation>();

  Stream<BrowserNavigation> get navigationStream => _subject;

  BrowserNavigation? get value => _subject.valueOrNull;

  Future<void> dispose() async {
    await _subject.close();
  }

  void navigate(String url) {
    _subject.add(
      BrowserNavigation(url: url),
    );
  }
}

class BrowserNavigation {
  final String url;

  BrowserNavigation({
    required this.url,
  });
}
