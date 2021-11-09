import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../logger.dart';
import '../services/nekoton_service.dart';

part 'connection_bloc.freezed.dart';

@injectable
class ConnectionBloc extends Bloc<_Event, ConnectionData> {
  final NekotonService _nekotonService;
  final _errorsSubject = PublishSubject<Exception>();
  StreamSubscription? _streamSubscription;

  ConnectionBloc(this._nekotonService) : super(_nekotonService.transport.connectionData) {
    _streamSubscription =
        _nekotonService.transportStream.listen((event) => add(_LocalEvent.update(event.connectionData)));
  }

  @override
  Future<void> close() {
    _errorsSubject.close();
    _streamSubscription?.cancel();
    return super.close();
  }

  @override
  Stream<ConnectionData> mapEventToState(_Event event) async* {
    try {
      if (event is _UpdateTransport) {
        await _nekotonService.updateTransport(event.connectionData);
      } else if (event is _Update) {
        yield event.connectionData;
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
  const factory _LocalEvent.update(ConnectionData connectionData) = _Update;
}

@freezed
class ConnectionEvent extends _Event with _$ConnectionEvent {
  const factory ConnectionEvent.updateTransport(ConnectionData connectionData) = _UpdateTransport;
}
