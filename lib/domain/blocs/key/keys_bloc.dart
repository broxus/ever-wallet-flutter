import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sortedmap/sortedmap.dart';
import 'package:tuple/tuple.dart';

import '../../../logger.dart';
import '../../services/nekoton_service.dart';

part 'keys_bloc.freezed.dart';

@injectable
class KeysBloc extends Bloc<_Event, KeysState> {
  final NekotonService _nekotonService;
  late final StreamSubscription _streamSubscription;
  final _keys = SortedMap<KeyStoreEntry, List<KeyStoreEntry>?>();
  KeyStoreEntry? _currentKey;

  KeysBloc(this._nekotonService) : super(const KeysState.initial()) {
    _streamSubscription =
        Rx.combineLatest2<KeyStoreEntry?, List<KeyStoreEntry>, Tuple2<KeyStoreEntry?, List<KeyStoreEntry>>>(
      _nekotonService.currentKeyStream,
      _nekotonService.keysStream,
      (a, b) => Tuple2(a, b),
    ).listen(
      (Tuple2<KeyStoreEntry?, List<KeyStoreEntry>> tuple) => add(
        _LocalEvent.updateKeys(
          currentKey: tuple.item1,
          keys: tuple.item2,
        ),
      ),
    );
  }

  @override
  Future<void> close() {
    _streamSubscription.cancel();
    return super.close();
  }

  @override
  Stream<KeysState> mapEventToState(_Event event) async* {
    if (event is _LocalEvent) {
      yield* event.when(
        updateKeys: (
          KeyStoreEntry? currentKey,
          List<KeyStoreEntry> keys,
        ) async* {
          try {
            final sortedKeys = _sortKeys(keys);

            _keys
              ..clear()
              ..addAll(sortedKeys);
            _currentKey = currentKey;

            yield KeysState.ready(
              keys: {..._keys},
              currentKey: _currentKey,
            );
          } on Exception catch (err, st) {
            logger.e(err, err, st);
            yield KeysState.error(err.toString());
          }
        },
      );
    }

    if (event is KeysEvent) {
      yield* event.when(
        setCurrentKey: (String publicKey) async* {
          try {
            final key = _nekotonService.keys.firstWhere((e) => e.publicKey == publicKey);

            _nekotonService.currentKey = key;

            _currentKey = key;

            yield KeysState.ready(
              keys: {..._keys},
              currentKey: _currentKey,
            );
          } on Exception catch (err, st) {
            logger.e(err, err, st);
            yield KeysState.error(err.toString());
          }
        },
      );
    }
  }

  Map<KeyStoreEntry, List<KeyStoreEntry>?> _sortKeys(List<KeyStoreEntry> keys) {
    final map = <KeyStoreEntry, List<KeyStoreEntry>?>{};

    for (final key in keys) {
      if (key.publicKey == key.masterKey) {
        if (!map.containsKey(key)) map[key] = null;
      } else {
        final parentKey = keys.firstWhereOrNull((e) => e.publicKey == key.masterKey);

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
  }
}

abstract class _Event {}

@freezed
class _LocalEvent extends _Event with _$_LocalEvent {
  const factory _LocalEvent.updateKeys({
    KeyStoreEntry? currentKey,
    required List<KeyStoreEntry> keys,
  }) = _UpdateKeys;
}

@freezed
class KeysEvent extends _Event with _$KeysEvent {
  const factory KeysEvent.setCurrentKey(String publicKey) = _SetCurrentKey;
}

@freezed
class KeysState with _$KeysState {
  const factory KeysState.initial() = _Initial;

  const factory KeysState.ready({
    required Map<KeyStoreEntry, List<KeyStoreEntry>?> keys,
    KeyStoreEntry? currentKey,
  }) = _Ready;

  const factory KeysState.error(String info) = _Error;
}
