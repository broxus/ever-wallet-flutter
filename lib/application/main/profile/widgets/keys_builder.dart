import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/async_value_stream_provider.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:provider/provider.dart';

typedef KeysBuilder = Widget Function(
  Map<KeyStoreEntry, List<KeyStoreEntry>?> keys,
  KeyStoreEntry? currentKey,
);

/// Widget that subscribes to KeysRepository and listens for current key and list of available keys.
/// Just a wrapper around providers to avoid boilerplate code.
class KeysBuilderWidget extends StatelessWidget {
  final KeysBuilder builder;

  const KeysBuilderWidget({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return AsyncValueStreamProvider<Map<KeyStoreEntry, List<KeyStoreEntry>?>>(
      create: (context) => context.read<KeysRepository>().mappedKeysStream,
      builder: (context, child) {
        final keys =
            context.watch<AsyncValue<Map<KeyStoreEntry, List<KeyStoreEntry>?>>>().maybeWhen(
                  ready: (value) => value,
                  orElse: () => <KeyStoreEntry, List<KeyStoreEntry>?>{},
                );

        return AsyncValueStreamProvider<KeyStoreEntry?>(
          create: (context) => context.read<KeysRepository>().currentKeyStream,
          builder: (context, child) {
            final currentKey = context.watch<AsyncValue<KeyStoreEntry?>>().maybeWhen(
                  ready: (value) => value,
                  orElse: () => null,
                );

            return builder(keys, currentKey);
          },
        );
      },
    );
  }
}
