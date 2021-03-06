import 'package:ever_wallet/application/common/form/value_state.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'form_state.freezed.dart';

@freezed
class FormState with _$FormState {
  const factory FormState({
    required ValueState valueState,
    String? errorText,
  }) = _FormState;

  const FormState._();

  bool get isEmpty => valueState == ValueState.empty;

  bool get isLoading => valueState == ValueState.loading;

  bool get isValid => valueState == ValueState.valid;

  bool get isInvalid => valueState == ValueState.invalid;
}
