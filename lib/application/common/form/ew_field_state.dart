import 'package:freezed_annotation/freezed_annotation.dart';

part 'ew_field_state.freezed.dart';

@freezed
class EWFieldState<T> with _$EWFieldState<T> {
  const factory EWFieldState.empty() = _Empty<T>;

  const factory EWFieldState.valid({
    required T value,
  }) = _Valid<T>;

  const factory EWFieldState.invalid({
    required T value,
    required String errorText,
  }) = _Invalid<T>;

  const EWFieldState._();

  T? get value => when(
        empty: () => null,
        valid: (value) => value,
        invalid: (value, errorText) => value,
      );

  String? get errorText => when(
        empty: () => null,
        valid: (value) => null,
        invalid: (value, errorText) => errorText,
      );
}
