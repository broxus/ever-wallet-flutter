import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../data/services/nekoton_service.dart';
import '../../../logger.dart';

part 'key_password_checking_bloc.freezed.dart';

@injectable
class KeyPasswordCheckingBloc extends Bloc<KeyPasswordCheckingEvent, KeyPasswordCheckingState> {
  final NekotonService _nekotonService;

  KeyPasswordCheckingBloc(this._nekotonService) : super(const KeyPasswordCheckingState.initial());

  @override
  Stream<KeyPasswordCheckingState> mapEventToState(KeyPasswordCheckingEvent event) async* {
    try {
      if (event is _Check) {
        final key = _nekotonService.keys.firstWhereOrNull((e) => e.publicKey == event.publicKey);

        if (key == null) {
          throw KeyNotFoundException();
        }

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
    } on Exception catch (err, st) {
      logger.e(err, err, st);
      yield KeyPasswordCheckingState.error(err);
    }
  }
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

  const factory KeyPasswordCheckingState.error(Exception exception) = _Error;

  const KeyPasswordCheckingState._();

  @override
  bool operator ==(Object other) => false;

  @override
  int get hashCode => 0;
}
