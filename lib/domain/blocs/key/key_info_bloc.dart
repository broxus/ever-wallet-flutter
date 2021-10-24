import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../logger.dart';
import '../../services/nekoton_service.dart';

part 'key_info_bloc.freezed.dart';

@injectable
class KeyInfoBloc extends Bloc<_Event, KeyInfoState?> {
  final NekotonService _nekotonService;
  final _errorsSubject = PublishSubject<String>();
  StreamSubscription? _streamSubscription;

  KeyInfoBloc(this._nekotonService) : super(null);

  @override
  Future<void> close() {
    _errorsSubject.close();
    _streamSubscription?.cancel();
    return super.close();
  }

  @override
  Stream<KeyInfoState?> mapEventToState(_Event event) async* {
    try {
      if (event is _Load) {
        _streamSubscription?.cancel();
        _streamSubscription = _nekotonService.keysStream
            .expand((e) => e)
            .where((e) => e.publicKey == event.publicKey)
            .listen((value) => add(_LocalEvent.update(value)));
      } else if (event is _Update) {
        yield KeyInfoState(event.key);
      }
    } catch (err, st) {
      logger.e(err, err, st);
      _errorsSubject.add(err.toString());
    }
  }

  Stream<String> get errorsStream => _errorsSubject.stream;
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

@freezed
class KeyInfoState with _$KeyInfoState {
  const factory KeyInfoState(KeyStoreEntry key) = _KeyInfoState;
}
