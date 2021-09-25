import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../logger.dart';
import '../../services/nekoton_service.dart';

part 'key_info_bloc.freezed.dart';

@injectable
class KeyInfoBloc extends Bloc<KeyInfoEvent, KeyInfoState> {
  final NekotonService _nekotonService;
  final String? _publicKey;
  late final StreamSubscription _streamSubscription;

  KeyInfoBloc(
    this._nekotonService,
    @factoryParam this._publicKey,
  ) : super(KeyInfoState.ready(_nekotonService.keys.firstWhere((e) => e.publicKey == _publicKey!).name)) {
    _streamSubscription = _nekotonService.keysStream.transform<KeyStoreEntry>(StreamTransformer.fromHandlers(
      handleData: (data, sink) {
        final entry = data.firstWhereOrNull((e) => e.publicKey == _publicKey!);

        if (entry != null) {
          sink.add(entry);
        }
      },
    )).listen((value) => add(KeyInfoEvent.update(value)));
  }

  @override
  Future<void> close() {
    _streamSubscription.cancel();
    return super.close();
  }

  @override
  Stream<KeyInfoState> mapEventToState(KeyInfoEvent event) async* {
    yield* event.when(
      update: (KeyStoreEntry key) async* {
        try {
          yield KeyInfoState.ready(key.name);
        } on Exception catch (err, st) {
          logger.e(err, err, st);
          yield KeyInfoState.error(err.toString());
        }
      },
    );
  }
}

@freezed
class KeyInfoEvent with _$KeyInfoEvent {
  const factory KeyInfoEvent.update(KeyStoreEntry key) = _Update;
}

@freezed
class KeyInfoState with _$KeyInfoState {
  const factory KeyInfoState.ready(String name) = _Ready;

  const factory KeyInfoState.error(String info) = _Error;
}
