import 'package:bloc/bloc.dart';
import 'package:ever_wallet/application/bloc/utils.dart';
import 'package:ever_wallet/application/common/form/ew_field_state.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:ever_wallet/data/sources/remote/transport_source.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'password_input_form_bloc.freezed.dart';

class PasswordInputFormBloc extends Bloc<PasswordInputFormEvent, PasswordInputFormState> {
  final KeysRepository _keysRepository;
  final String _publicKey;
  final TransportSource _transportSource;

  PasswordInputFormBloc(
    this._keysRepository,
    this._publicKey,
    this._transportSource,
  ) : super(PasswordInputFormState.empty()) {
    on<_OnPasswordChange>(
      (event, emit) async {
        if (event.value.isEmpty) {
          emit(state.copyWith(passwordFieldState: const EWFieldState.empty()));
          return;
        }

        final isCorrect = await _keysRepository.checkKeyPassword(
          publicKey: _publicKey,
          password: event.value,
          signatureId: await _transportSource.transport.getSignatureId(),
        );

        if (isCorrect) {
          emit(state.copyWith(passwordFieldState: EWFieldState.valid(value: event.value)));
        } else {
          emit(
            state.copyWith(
              passwordFieldState: EWFieldState.invalid(
                value: event.value,
                errorText: 'Invalid password',
              ),
            ),
          );
        }
      },
      transformer: debounceSequential(const Duration(milliseconds: 300)),
    );
  }
}

@freezed
class PasswordInputFormEvent with _$PasswordInputFormEvent {
  const factory PasswordInputFormEvent.onPasswordChange(String value) = _OnPasswordChange;
}

@freezed
class PasswordInputFormState with _$PasswordInputFormState {
  const factory PasswordInputFormState({
    required EWFieldState<String> passwordFieldState,
  }) = _PasswordInputFormState;

  factory PasswordInputFormState.empty() => const PasswordInputFormState(
        passwordFieldState: EWFieldState.empty(),
      );

  const PasswordInputFormState._();

  String? get errorText => passwordFieldState.errorText;
}
