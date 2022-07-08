import 'package:ever_wallet/data/sources/local/hive/dto/meta.dart';
import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'token_incoming_transfer_dto.freezed.dart';
part 'token_incoming_transfer_dto.g.dart';

@freezedDto
class TokenIncomingTransferDto with _$TokenIncomingTransferDto {
  @HiveType(typeId: 23)
  const factory TokenIncomingTransferDto({
    @HiveField(0) required String tokens,
    @HiveField(1) required String senderAddress,
  }) = _TokenIncomingTransferDto;
}

extension TokenIncomingTransferX on TokenIncomingTransfer {
  TokenIncomingTransferDto toDto() => TokenIncomingTransferDto(
        tokens: tokens,
        senderAddress: senderAddress,
      );
}

extension TokenIncomingTransferDtoX on TokenIncomingTransferDto {
  TokenIncomingTransfer toModel() => TokenIncomingTransfer(
        tokens: tokens,
        senderAddress: senderAddress,
      );
}
