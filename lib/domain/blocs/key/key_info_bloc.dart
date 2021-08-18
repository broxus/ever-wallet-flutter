import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../logger.dart';

part 'key_info_bloc.freezed.dart';

@injectable
class KeyInfoBloc extends Bloc<KeyInfoEvent, KeyInfoState> {
  final KeySubject? _keySubject;
  late final StreamSubscription _streamSubscription;

  KeyInfoBloc(@factoryParam this._keySubject) : super(KeyInfoState.ready(_keySubject!.value.name)) {
    _streamSubscription = _keySubject!.listen((value) => add(KeyInfoEvent.updateName(value.name)));
  }

  @override
  Future<void> close() {
    _streamSubscription.cancel();
    return super.close();
  }

  @override
  Stream<KeyInfoState> mapEventToState(KeyInfoEvent event) async* {
    yield* event.when(
      updateName: (String name) async* {
        try {
          yield KeyInfoState.ready(name);
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
  const factory KeyInfoEvent.updateName(String name) = _UpdateName;
}

@freezed
class KeyInfoState with _$KeyInfoState {
  const factory KeyInfoState.ready(String name) = _Ready;

  const factory KeyInfoState.error(String info) = _Error;
}
