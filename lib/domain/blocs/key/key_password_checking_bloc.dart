import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../logger.dart';
import '../../services/nekoton_service.dart';

part 'key_password_checking_bloc.freezed.dart';

@injectable
class KeyPasswordCheckingBloc extends Bloc<KeyPasswordCheckingEvent, KeyPasswordCheckingState> {
  final NekotonService _nekotonService;
  final _errorsSubject = PublishSubject<String>();

  KeyPasswordCheckingBloc(this._nekotonService) : super(const KeyPasswordCheckingState.initial());

  @override
  Future<void> close() {
    _errorsSubject.close();
    return super.close();
  }

  @override
  Stream<KeyPasswordCheckingState> mapEventToState(KeyPasswordCheckingEvent event) async* {
    try {
      if (event is _Check) {
        final key = _nekotonService.keys.firstWhere((e) => e.publicKey == event.publicKey);

        late final SignInput signInput;

        if (key.isLegacy) {
          signInput = EncryptedKeyPassword(
            publicKey: key.publicKey,
            password: Password.explicit(
              password: event.password,
              cacheBehavior: const PasswordCacheBehavior.remove(),
            ),
          );
        } else {
          signInput = DerivedKeySignParams.byAccountId(
            masterKey: key.masterKey,
            accountId: key.accountId,
            password: Password.explicit(
              password: event.password,
              cacheBehavior: const PasswordCacheBehavior.remove(),
            ),
          );
        }

        final isCorrect = await _nekotonService.checkKeyPassword(signInput);

        yield KeyPasswordCheckingState.success(isCorrect);
      }
    } catch (err, st) {
      logger.e(err, err, st);
      _errorsSubject.add(err.toString());
    }
  }

  Stream<String> get errorsStream => _errorsSubject.stream;
}

@freezed
class KeyPasswordCheckingEvent with _$KeyPasswordCheckingEvent {
  const factory KeyPasswordCheckingEvent.check({
    required String publicKey,
    required String password,
  }) = _Check;
}

@freezed
class KeyPasswordCheckingState with _$KeyPasswordCheckingState {
  const factory KeyPasswordCheckingState.initial() = _Initial;

  const factory KeyPasswordCheckingState.success(bool isCorrect) = _Success;
}
