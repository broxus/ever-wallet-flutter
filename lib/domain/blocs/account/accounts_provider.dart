import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../data/services/nekoton_service.dart';
import '../../../injection.dart';

final accountsProvider = StreamProvider<List<AssetsList>>(
  (ref) => Rx.combineLatest3<KeyStoreEntry?, List<AssetsList>, Map<String, List<String>>, List<AssetsList>>(
    getIt.get<NekotonService>().currentKeyStream,
    getIt.get<NekotonService>().accountsStream,
    getIt.get<NekotonService>().externalAccountsStream,
    (a, b, c) {
      final currentKey = a;

      List<AssetsList> internalAccounts = [];
      List<AssetsList> externalAccounts = [];

      if (currentKey != null) {
        final externalAddresses = c[a?.publicKey] ?? [];

        internalAccounts = b.where((e) => e.publicKey == a?.publicKey).toList();
        externalAccounts =
            b.where((e) => e.publicKey != a?.publicKey && externalAddresses.any((el) => el == e.address)).toList();
      }

      return [
        ...internalAccounts,
        ...externalAccounts,
      ]..sort((a, b) => a.name.compareTo(b.name));
    },
  ),
);
