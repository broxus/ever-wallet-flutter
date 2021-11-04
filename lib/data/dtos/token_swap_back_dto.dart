import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'token_swap_back_dto.freezed.dart';
part 'token_swap_back_dto.g.dart';

@freezed
class TokenSwapBackDto with _$TokenSwapBackDto {
  @HiveType(typeId: 14)
  const factory TokenSwapBackDto({
    @HiveField(0) required String tokens,
    @HiveField(1) required String callbackAddress,
    @HiveField(2) required String callbackPayload,
  }) = _TokenSwapBackDto;
}

extension TokenSwapBackDtoToDomain on TokenSwapBackDto {
  TokenSwapBack toModel() => TokenSwapBack(
        tokens: tokens,
        callbackAddress: callbackAddress,
        callbackPayload: callbackPayload,
      );
}

extension TokenSwapBackFromDomain on TokenSwapBack {
  TokenSwapBackDto toDto() => TokenSwapBackDto(
        tokens: tokens,
        callbackAddress: callbackAddress,
        callbackPayload: callbackPayload,
      );
}
