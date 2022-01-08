import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../data/services/nekoton_service.dart';
import '../../../injection.dart';

final keysProvider = StreamProvider<Map<KeyStoreEntry, List<KeyStoreEntry>?>>(
  (ref) => getIt.get<NekotonService>().keysStream.map((e) {
    final map = <KeyStoreEntry, List<KeyStoreEntry>?>{};

    for (final key in e) {
      if (key.publicKey == key.masterKey) {
        if (!map.containsKey(key)) map[key] = null;
      } else {
        final parentKey = e.firstWhereOrNull((e) => e.publicKey == key.masterKey);

        if (parentKey != null) {
          if (map[parentKey] != null) {
            map[parentKey]!.addAll([key]);
          } else {
            map[parentKey] = [key];
          }
        }
      }
    }

    return map;
  }),
);
