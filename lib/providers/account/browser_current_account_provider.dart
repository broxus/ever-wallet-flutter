import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../data/repositories/accounts_repository.dart';
import '../../injection.dart';

final browserCurrentAccountProvider = StateNotifierProvider.autoDispose<BrowserCurrentAccountNotifier, AssetsList?>(
  (ref) => BrowserCurrentAccountNotifier(),
);

class BrowserCurrentAccountNotifier extends StateNotifier<AssetsList?> {
  late final StreamSubscription _streamSubscription;

  BrowserCurrentAccountNotifier() : super(null) {
    _streamSubscription =
        getIt.get<AccountsRepository>().currentAccountsStream.listen((event) => _currentAccountsStreamListener(event));
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  Future<void> setCurrent(String? address) async =>
      state = getIt.get<AccountsRepository>().currentAccounts.firstWhereOrNull((e) => e.address == address);

  void _currentAccountsStreamListener(List<AssetsList> event) {
    if (state == null || event.every((e) => e.address != state?.address)) {
      state = event.firstOrNull;
    }
  }
}
