import 'package:ever_wallet/data/sources/local/hive/dto/meta.dart';
import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'token_swap_back_dto.freezed.dart';
part 'token_swap_back_dto.g.dart';

@freezedDto
class TokenSwapBackDto with _$TokenSwapBackDto {
  @HiveType(typeId: 25)
  const factory TokenSwapBackDto({
    @HiveField(0) required String tokens,
    @HiveField(1) required String callbackAddress,
    @HiveField(2) required String callbackPayload,
  }) = _TokenSwapBackDto;
}

extension TokenSwapBackX on TokenSwapBack {
  TokenSwapBackDto toDto() => TokenSwapBackDto(
        tokens: tokens,
        callbackAddress: callbackAddress,
        callbackPayload: callbackPayload,
      );
}

extension TokenSwapBackDtoX on TokenSwapBackDto {
  TokenSwapBack toModel() => TokenSwapBack(
        tokens: tokens,
        callbackAddress: callbackAddress,
        callbackPayload: callbackPayload,
      );
}
