import 'package:ever_wallet/data/sources/local/hive/dto/meta.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'transfer_recipient_dto.freezed.dart';
part 'transfer_recipient_dto.g.dart';

@freezedDto
class TransferRecipientDto with _$TransferRecipientDto {
  @HiveType(typeId: 46)
  const factory TransferRecipientDto.ownerWallet(@HiveField(0) String data) =
      _TransferRecipientDtoOwnerWallet;

  @HiveType(typeId: 47)
  const factory TransferRecipientDto.tokenWallet(@HiveField(0) String data) =
      _TransferRecipientDtoTokenWallet;
}

extension TransferRecipientX on TransferRecipient {
  TransferRecipientDto toDto() => when(
        ownerWallet: (data) => TransferRecipientDto.ownerWallet(data),
        tokenWallet: (data) => TransferRecipientDto.tokenWallet(data),
      );
}

extension TransferRecipientDtoX on TransferRecipientDto {
  TransferRecipient toModel() => when(
        ownerWallet: (data) => TransferRecipient.ownerWallet(data),
        tokenWallet: (data) => TransferRecipient.tokenWallet(data),
      );
}
