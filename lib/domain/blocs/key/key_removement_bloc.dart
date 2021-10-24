import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import '../../../logger.dart';
import '../../services/nekoton_service.dart';

part 'key_removement_bloc.freezed.dart';

@injectable
class KeyRemovementBloc extends Bloc<KeyRemovementEvent, KeyRemovementState> {
  final NekotonService _nekotonService;
  final _errorsSubject = PublishSubject<String>();

  KeyRemovementBloc(this._nekotonService) : super(const KeyRemovementState.initial());

  @override
  Future<void> close() {
    _errorsSubject.close();
    return super.close();
  }

  @override
  Stream<KeyRemovementState> mapEventToState(KeyRemovementEvent event) async* {
    try {
      if (event is _Remove) {
        await _nekotonService.removeKey(event.publicKey);

        yield const KeyRemovementState.success();
      }
    } catch (err, st) {
      logger.e(err, err, st);
      _errorsSubject.add(err.toString());
    }
  }

  Stream<String> get errorsStream => _errorsSubject.stream;
}

@freezed
class KeyRemovementEvent with _$KeyRemovementEvent {
  const factory KeyRemovementEvent.remove(String publicKey) = _Remove;
}

@freezed
class KeyRemovementState with _$KeyRemovementState {
  const factory KeyRemovementState.initial() = _Initial;

  const factory KeyRemovementState.success() = _Success;
}
