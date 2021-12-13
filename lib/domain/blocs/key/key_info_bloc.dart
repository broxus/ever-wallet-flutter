import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../data/services/nekoton_service.dart';
import '../../../logger.dart';

part 'key_info_bloc.freezed.dart';

@injectable
class KeyInfoBloc extends Bloc<_Event, KeyStoreEntry?> {
  final NekotonService _nekotonService;
  final _errorsSubject = PublishSubject<Exception>();
  StreamSubscription? _streamSubscription;

  KeyInfoBloc(this._nekotonService) : super(null);

  @override
  Future<void> close() {
    _errorsSubject.close();
    _streamSubscription?.cancel();
    return super.close();
  }

  @override
  Stream<KeyStoreEntry?> mapEventToState(_Event event) async* {
    try {
      if (event is _Load) {
        final key = _nekotonService.keys.firstWhereOrNull((e) => e.publicKey == event.publicKey);

        if (key == null) {
          throw KeyNotFoundException();
        }

        _streamSubscription?.cancel();
        _streamSubscription = _nekotonService.keysStream
            .expand((e) => e)
            .where((e) => e.publicKey == event.publicKey)
            .distinct()
            .listen((value) => add(_LocalEvent.update(value)));
      } else if (event is _Update) {
        yield event.key;
      }
    } on Exception catch (err, st) {
      logger.e(err, err, st);
      _errorsSubject.add(err);
    }
  }

  Stream<Exception> get errorsStream => _errorsSubject.stream;
}

abstract class _Event {}

@freezed
class _LocalEvent extends _Event with _$_LocalEvent {
  const factory _LocalEvent.update(KeyStoreEntry key) = _Update;
}

@freezed
class KeyInfoEvent extends _Event with _$KeyInfoEvent {
  const factory KeyInfoEvent.load(String publicKey) = _Load;
}
