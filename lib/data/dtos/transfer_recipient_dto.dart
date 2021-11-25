import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'transfer_recipient_dto.freezed.dart';
part 'transfer_recipient_dto.g.dart';

@freezed
class TransferRecipientDto with _$TransferRecipientDto {
  @HiveType(typeId: 24)
  const factory TransferRecipientDto.ownerWallet({
    @HiveField(0) required String address,
  }) = _OwnerWalletRecipientDto;

  @HiveType(typeId: 25)
  const factory TransferRecipientDto.tokenWallet({
    @HiveField(0) required String address,
  }) = _TokenWalletRecipientDto;

  factory TransferRecipientDto.fromJson(Map<String, dynamic> json) => _$TransferRecipientDtoFromJson(json);
}

extension TransferRecipientDtoToDomain on TransferRecipientDto {
  TransferRecipient toModel() => when(
        ownerWallet: (address) => TransferRecipient.ownerWallet(address: address),
        tokenWallet: (address) => TransferRecipient.tokenWallet(address: address),
      );
}

extension TransferRecipientFromDomain on TransferRecipient {
  TransferRecipientDto toDto() => when(
        ownerWallet: (address) => TransferRecipientDto.ownerWallet(address: address),
        tokenWallet: (address) => TransferRecipientDto.tokenWallet(address: address),
      );
}
