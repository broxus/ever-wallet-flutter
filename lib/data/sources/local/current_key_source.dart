import 'dart:async';

import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

class CurrentKeySource {
  final _currentKeySubject = BehaviorSubject<KeyStoreEntry?>.seeded(null);

  Stream<KeyStoreEntry?> get currentKeyStream => _currentKeySubject.distinct();

  KeyStoreEntry? get currentKey => _currentKeySubject.value;

  set currentKey(KeyStoreEntry? currentKey) => _currentKeySubject.add(currentKey);

  Future<void> dispose() => _currentKeySubject.close();
}
