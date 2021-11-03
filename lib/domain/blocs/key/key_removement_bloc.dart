import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../logger.dart';
import '../../services/nekoton_service.dart';

part 'key_removement_bloc.freezed.dart';

@injectable
class KeyRemovementBloc extends Bloc<KeyRemovementEvent, KeyRemovementState> {
  final NekotonService _nekotonService;

  KeyRemovementBloc(this._nekotonService) : super(KeyRemovementStateInitial());

  @override
  Stream<KeyRemovementState> mapEventToState(KeyRemovementEvent event) async* {
    try {
      if (event is _Remove) {
        await _nekotonService.removeKey(event.publicKey);

        yield KeyRemovementStateSuccess();
      }
    } on Exception catch (err, st) {
      logger.e(err, err, st);
      yield KeyRemovementStateError(err);
    }
  }
}

@freezed
class KeyRemovementEvent with _$KeyRemovementEvent {
  const factory KeyRemovementEvent.remove(String publicKey) = _Remove;
}

abstract class KeyRemovementState {}

class KeyRemovementStateInitial extends KeyRemovementState {}

class KeyRemovementStateSuccess extends KeyRemovementState {}

class KeyRemovementStateError extends KeyRemovementState {
  final Exception exception;

  KeyRemovementStateError(this.exception);
}
