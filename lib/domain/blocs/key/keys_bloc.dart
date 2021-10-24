import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import '../../../logger.dart';
import '../../services/nekoton_service.dart';

part 'keys_bloc.freezed.dart';

@injectable
class KeysBloc extends Bloc<_Event, KeysState> {
  final NekotonService _nekotonService;
  final _errorsSubject = PublishSubject<String>();
  late final StreamSubscription _streamSubscription;

  KeysBloc(this._nekotonService) : super(const KeysState()) {
    _streamSubscription =
        Rx.combineLatest2<KeyStoreEntry?, List<KeyStoreEntry>, Tuple2<KeyStoreEntry?, List<KeyStoreEntry>>>(
      _nekotonService.currentKeyStream,
      _nekotonService.keysStream,
      (a, b) => Tuple2(a, b),
    ).listen(
      (Tuple2<KeyStoreEntry?, List<KeyStoreEntry>> tuple) => add(
        _LocalEvent.update(
          keys: tuple.item2,
          currentKey: tuple.item1,
        ),
      ),
    );
  }

  @override
  Future<void> close() {
    _errorsSubject.close();
    _streamSubscription.cancel();
    return super.close();
  }

  @override
  Stream<KeysState> mapEventToState(_Event event) async* {
    try {
      if (event is _Update) {
        final sortedKeys = _sortKeys(event.keys);

        yield KeysState(
          keys: sortedKeys,
          currentKey: event.currentKey,
        );
      } else if (event is _SetCurrent) {
        final key = _nekotonService.keys.firstWhere((e) => e.publicKey == event.publicKey);

        _nekotonService.currentKey = key;

        yield KeysState(
          keys: state.keys,
          currentKey: key,
        );
      }
    } catch (err, st) {
      logger.e(err, err, st);
      _errorsSubject.add(err.toString());
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

  Stream<String> get errorsStream => _errorsSubject.stream;
}

abstract class _Event {}

@freezed
class _LocalEvent extends _Event with _$_LocalEvent {
  const factory _LocalEvent.update({
    required List<KeyStoreEntry> keys,
    KeyStoreEntry? currentKey,
  }) = _Update;
}

@freezed
class KeysEvent extends _Event with _$KeysEvent {
  const factory KeysEvent.setCurrent(String? publicKey) = _SetCurrent;
}

@freezed
class KeysState with _$KeysState {
  const factory KeysState({
    @Default({}) Map<KeyStoreEntry, List<KeyStoreEntry>?> keys,
    KeyStoreEntry? currentKey,
  }) = _KeysState;
}
