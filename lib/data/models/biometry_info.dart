import 'package:freezed_annotation/freezed_annotation.dart';

part 'biometry_info.freezed.dart';

@freezed
class BiometryInfo with _$BiometryInfo {
  const factory BiometryInfo({
    @Default(false) bool isAvailable,
    @Default(false) bool isEnabled,
  }) = _BiometryInfo;
}
