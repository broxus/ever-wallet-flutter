import 'package:ever_wallet/application/common/async_value.dart';
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
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamProvider<AsyncValue<Map<KeyStoreEntry, List<KeyStoreEntry>?>>>(
      create: (context) =>
          context.read<KeysRepository>().mappedKeysStream.map((event) => AsyncValue.ready(event)),
      initialData: const AsyncValue.loading(),
      catchError: (context, error) => AsyncValue.error(error),
      builder: (context, child) {
        final keys =
            context.watch<AsyncValue<Map<KeyStoreEntry, List<KeyStoreEntry>?>>>().maybeWhen(
                  ready: (value) => value,
                  orElse: () => <KeyStoreEntry, List<KeyStoreEntry>?>{},
                );

        return StreamProvider<AsyncValue<KeyStoreEntry?>>(
          create: (context) => context
              .read<KeysRepository>()
              .currentKeyStream
              .map((event) => AsyncValue.ready(event)),
          initialData: const AsyncValue.loading(),
          catchError: (context, error) => AsyncValue.error(error),
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
