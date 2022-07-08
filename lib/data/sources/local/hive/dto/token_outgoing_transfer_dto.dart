import 'package:ever_wallet/data/sources/local/hive/dto/meta.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/transfer_recipient_dto.dart';
import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'token_outgoing_transfer_dto.freezed.dart';
part 'token_outgoing_transfer_dto.g.dart';

@freezedDto
class TokenOutgoingTransferDto with _$TokenOutgoingTransferDto {
  @HiveType(typeId: 24)
  const factory TokenOutgoingTransferDto({
    @HiveField(0) required TransferRecipientDto to,
    @HiveField(1) required String tokens,
  }) = _TokenOutgoingTransferDto;
}

extension TokenOutgoingTransferX on TokenOutgoingTransfer {
  TokenOutgoingTransferDto toDto() => TokenOutgoingTransferDto(
        to: to.toDto(),
        tokens: tokens,
      );
}

extension TokenOutgoingTransferDtoX on TokenOutgoingTransferDto {
  TokenOutgoingTransfer toModel() => TokenOutgoingTransfer(
        to: to.toModel(),
        tokens: tokens,
      );
}
