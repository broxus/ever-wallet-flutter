import 'package:ever_wallet/application/common/form/value_state.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'field_state.freezed.dart';

@freezed
class FieldState with _$FieldState {
  const factory FieldState({
    required ValueState valueState,
    required String value,
    String? errorText,
  }) = _FieldState;

  const FieldState._();

  bool get isEmpty => valueState == ValueState.empty;

  bool get isLoading => valueState == ValueState.loading;

  bool get isValid => valueState == ValueState.valid;

  bool get isInvalid => valueState == ValueState.invalid;
}
