import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

class CurrentAccountsSource {
  final _currentAccountsSubject = BehaviorSubject<List<AssetsList>>.seeded([]);

  Stream<List<AssetsList>> get currentAccountsStream =>
      _currentAccountsSubject.distinct((a, b) => listEquals(a, b));

  List<AssetsList> get currentAccounts => _currentAccountsSubject.value;

  set currentAccounts(List<AssetsList> accounts) => _currentAccountsSubject.add(accounts);

  Future<void> dispose() => _currentAccountsSubject.close();
}
