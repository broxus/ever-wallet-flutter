import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import 'accounts_provider.dart';

final currentAccountProvider = StateNotifierProvider.autoDispose<CurrentAccountNotifier, AssetsList?>((ref) {
  final notifier = CurrentAccountNotifier(ref.read);

  ref.onDispose(
    ref.listen<AsyncValue<List<AssetsList>>>(
      accountsProvider,
      notifier.callback,
      fireImmediately: true,
    ),
  );

  return notifier;
});

class CurrentAccountNotifier extends StateNotifier<AssetsList?> {
  final Reader read;

  CurrentAccountNotifier(this.read) : super(null);

  Future<void> setCurrent(String? address) async {
    final accounts = await read(accountsProvider.future);

    state = accounts.firstWhereOrNull((e) => e.address == address);
  }

  void callback(AsyncValue<List<AssetsList>>? previous, AsyncValue<List<AssetsList>> next) {
    final accounts = next.asData?.value ?? [];
    final currentAccount = accounts.firstWhereOrNull((e) => e.address == state?.address) ?? accounts.firstOrNull;

    state = currentAccount;
  }
}
