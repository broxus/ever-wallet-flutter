import 'package:freezed_annotation/freezed_annotation.dart';

part 'async_value.freezed.dart';

@freezed
class AsyncValue<T> with _$AsyncValue<T> {
  const factory AsyncValue.loading() = _Loading<T>;

  const factory AsyncValue.ready(T value) = _Ready<T>;

  const factory AsyncValue.error(Object? error) = _Error<T>;
}
