import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../../../../data/repositories/keys_repository.dart';
import '../../../../../../../injection.dart';
import '../../../../../common/form/field_state.dart';
import '../../../../../common/form/form_state.dart';
import '../../../../../common/form/value_state.dart';

part 'password_enter_page_notifier.freezed.dart';

class PasswordEnterPageNotifier extends ChangeNotifier {
  final _keystoreRepository = getIt.get<KeysRepository>();
  final _passwordInputSubject = PublishSubject<String>();
  final String _publicKey;
  var _state = PasswordEnterPageFieldState.empty();

  PasswordEnterPageNotifier(this._publicKey) {
    _passwordInputSubject
        .debounce((e) => TimerStream(e, const Duration(milliseconds: 300)))
        .asyncMap((e) => _validatePassword(e))
        .listen((e) {
      _state = _state.copyWith(passwordState: e);
      notifyListeners();
    });
  }

  PasswordEnterPageFieldState get state => _state;

  void onPasswordChange(String value) {
    if (!_state.passwordState.isLoading) {
      _state = _state.copyWith.passwordState(valueState: ValueState.loading);
      notifyListeners();
    }
    _passwordInputSubject.add(value);
  }

  Future<FieldState> _validatePassword(String value) async {
    if (value.isEmpty) {
      return FieldState(
        valueState: ValueState.empty,
        value: value,
      );
    }

    final isCorrect = await _keystoreRepository.checkKeyPassword(
      publicKey: _publicKey,
      password: value,
    );

    return isCorrect
        ? FieldState(
            valueState: ValueState.valid,
            value: value,
          )
        : FieldState(
            valueState: ValueState.invalid,
            value: value,
            errorText: 'Invalid password',
          );
  }
}

@freezed
class PasswordEnterPageFieldState with _$PasswordEnterPageFieldState {
  const factory PasswordEnterPageFieldState({
    required FieldState passwordState,
  }) = _PasswordEnterPageFieldState;

  factory PasswordEnterPageFieldState.empty() => const PasswordEnterPageFieldState(
        passwordState: FieldState(
          valueState: ValueState.empty,
          value: '',
        ),
      );

  const PasswordEnterPageFieldState._();

  FormState get formState => FormState(
        valueState: passwordState.valueState,
        errorText: passwordState.errorText,
      );
}
