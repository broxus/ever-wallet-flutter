import 'package:crystal/data/dtos/contract_state_dto.dart';
import 'package:crystal/data/dtos/ton_wallet_details_dto.dart';
import 'package:crystal/data/dtos/wallet_type_dto.dart';
import 'package:crystal/domain/models/ton_wallet_info.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ton_wallet_info_dto.freezed.dart';
part 'ton_wallet_info_dto.g.dart';

@freezed
class TonWalletInfoDto with _$TonWalletInfoDto {
  @HiveType(typeId: 9)
  const factory TonWalletInfoDto({
    @HiveField(0) required String address,
    @HiveField(1) required ContractStateDto contractState,
    @HiveField(2) required WalletTypeDto walletType,
    @HiveField(3) required TonWalletDetailsDto details,
    @HiveField(4) required String publicKey,
  }) = _TonWalletInfoDto;
}

extension TonWalletInfoDtoToDomain on TonWalletInfoDto {
  TonWalletInfo toModel() => TonWalletInfo(
        address: address,
        contractState: contractState.toModel(),
        walletType: walletType.toModel(),
        details: details.toModel(),
        publicKey: publicKey,
      );
}

extension TonWalletInfoFromDomain on TonWalletInfo {
  TonWalletInfoDto toDto() => TonWalletInfoDto(
        address: address,
        contractState: contractState.toDto(),
        walletType: walletType.toDto(),
        details: details.toDto(),
        publicKey: publicKey,
      );
}
