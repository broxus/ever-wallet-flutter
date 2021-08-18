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
  final _keys = SortedMap<KeySubject, List<KeySubject>?>();
  KeySubject? _currentKey;

  KeysBloc(this._nekotonService) : super(const KeysState.initial()) {
    _streamSubscription = Rx.combineLatest2<List<KeySubject>, KeySubject?, Tuple2<List<KeySubject>, KeySubject?>>(
      _nekotonService.keysStream,
      _nekotonService.currentKeyStream,
      (a, b) => Tuple2(a, b),
    ).listen(
      (Tuple2<List<KeySubject>, KeySubject?> tuple) => add(
        _LocalEvent.updateKeys(
          keys: tuple.item1,
          currentKey: tuple.item2,
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
          List<KeySubject> keys,
          KeySubject? currentKey,
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
        setCurrentKey: (KeySubject keySubject) async* {
          try {
            _nekotonService.setCurrentKey(keySubject);

            _currentKey = keySubject;

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

  Map<KeySubject, List<KeySubject>?> _sortKeys(List<KeySubject> keys) {
    final map = <KeySubject, List<KeySubject>?>{};

    for (final key in keys) {
      if (key.value.publicKey == key.value.masterKey) {
        if (!map.containsKey(key)) map[key] = null;
      } else {
        final parentKey = keys.firstWhereOrNull((e) => e.value.publicKey == key.value.masterKey);

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
    required List<KeySubject> keys,
    required KeySubject? currentKey,
  }) = _UpdateKeys;
}

@freezed
class KeysEvent extends _Event with _$KeysEvent {
  const factory KeysEvent.setCurrentKey(KeySubject keySubject) = _SetCurrentKey;
}

@freezed
class KeysState with _$KeysState {
  const factory KeysState.initial() = _Initial;

  const factory KeysState.ready({
    required Map<KeySubject, List<KeySubject>?> keys,
    required KeySubject? currentKey,
  }) = _Ready;

  const factory KeysState.error(String info) = _Error;
}
