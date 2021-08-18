import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../logger.dart';
import '../../services/nekoton_service.dart';

part 'key_password_check_bloc.freezed.dart';

@injectable
class KeyPasswordCheckBloc extends Bloc<KeyPasswordCheckEvent, KeyPasswordCheckState> {
  final NekotonService _nekotonService;

  KeyPasswordCheckBloc(this._nekotonService) : super(const KeyPasswordCheckState.initial());

  @override
  Stream<KeyPasswordCheckState> mapEventToState(KeyPasswordCheckEvent event) async* {
    yield* event.when(
      checkPassword: (
        String publicKey,
        String password,
      ) async* {
        try {
          final keySubject = _nekotonService.keys.firstWhere((e) => e.value.publicKey == publicKey);

          late final SignInput signInput;

          if (keySubject.value.isLegacy) {
            signInput = EncryptedKeyPassword(
              publicKey: keySubject.value.publicKey,
              password: Password.explicit(
                password: password,
                cacheBehavior: const PasswordCacheBehavior.remove(),
              ),
            );
          } else {
            signInput = DerivedKeySignParams.byAccountId(
              masterKey: keySubject.value.masterKey,
              accountId: keySubject.value.accountId,
              password: Password.explicit(
                password: password,
                cacheBehavior: const PasswordCacheBehavior.remove(),
              ),
            );
          }

          final isCorrect = await _nekotonService.checkKeyPassword(signInput);

          yield KeyPasswordCheckState.ready(
            isCorrect: isCorrect,
            password: password,
          );
        } on Exception catch (err, st) {
          logger.e(err, err, st);
        }
      },
    );
  }
}

@freezed
class KeyPasswordCheckEvent with _$KeyPasswordCheckEvent {
  const factory KeyPasswordCheckEvent.checkPassword({
    required String publicKey,
    required String password,
  }) = _CheckPassword;
}

@freezed
class KeyPasswordCheckState with _$KeyPasswordCheckState {
  const factory KeyPasswordCheckState.initial() = _Initial;

  const factory KeyPasswordCheckState.ready({
    required bool isCorrect,
    required String password,
  }) = _Ready;
}
