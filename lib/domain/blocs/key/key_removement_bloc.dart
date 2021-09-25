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

  KeyRemovementBloc(this._nekotonService) : super(const KeyRemovementState.initial());

  @override
  Stream<KeyRemovementState> mapEventToState(KeyRemovementEvent event) async* {
    yield* event.when(
      removeKey: (String publicKey) async* {
        try {
          await _nekotonService.removeKey(publicKey);

          yield const KeyRemovementState.success();
        } on Exception catch (err, st) {
          logger.e(err, err, st);
          yield KeyRemovementState.error(err.toString());
        }
      },
    );
  }
}

@freezed
class KeyRemovementEvent with _$KeyRemovementEvent {
  const factory KeyRemovementEvent.removeKey(String publicKey) = _RemoveKey;
}

@freezed
class KeyRemovementState with _$KeyRemovementState {
  const factory KeyRemovementState.initial() = _Initial;

  const factory KeyRemovementState.success() = _Success;

  const factory KeyRemovementState.error(String info) = _Error;
}
