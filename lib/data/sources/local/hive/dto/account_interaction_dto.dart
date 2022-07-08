import 'package:ever_wallet/data/models/account_interaction.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/wallet_contract_type_dto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'account_interaction_dto.freezed.dart';
part 'account_interaction_dto.g.dart';

@freezed
class AccountInteractionDto with _$AccountInteractionDto {
  @HiveType(typeId: 222)
  const factory AccountInteractionDto({
    @HiveField(0) required String address,
    @HiveField(1) required String publicKey,
    @HiveField(2) required WalletContractTypeDto contractType,
  }) = _AccountInteractionDto;
}

extension AccountInteractionX on AccountInteraction {
  AccountInteractionDto toDto() => AccountInteractionDto(
        address: address,
        publicKey: publicKey,
        contractType: contractType.toDto(),
      );
}

extension AccountInteractionDtoX on AccountInteractionDto {
  AccountInteraction toModel() => AccountInteraction(
        address: address,
        publicKey: publicKey,
        contractType: contractType.toModel(),
      );
}
