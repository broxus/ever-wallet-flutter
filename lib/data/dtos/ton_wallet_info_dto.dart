import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../domain/models/ton_wallet_info.dart';
import 'contract_state_dto.dart';
import 'ton_wallet_details_dto.dart';
import 'wallet_type_dto.dart';

part 'ton_wallet_info_dto.freezed.dart';
part 'ton_wallet_info_dto.g.dart';

@freezed
class TonWalletInfoDto with _$TonWalletInfoDto {
  @HiveType(typeId: 9)
  const factory TonWalletInfoDto({
    @HiveField(0) required int workchain,
    @HiveField(1) required String address,
    @HiveField(2) required String publicKey,
    @HiveField(3) required WalletTypeDto walletType,
    @HiveField(4) required ContractStateDto contractState,
    @HiveField(5) required TonWalletDetailsDto details,
    @HiveField(6) required List<String>? custodians,
  }) = _TonWalletInfoDto;
}

extension TonWalletInfoDtoToDomain on TonWalletInfoDto {
  TonWalletInfo toModel() => TonWalletInfo(
        workchain: workchain,
        address: address,
        publicKey: publicKey,
        walletType: walletType.toModel(),
        contractState: contractState.toModel(),
        details: details.toModel(),
        custodians: custodians,
      );
}

extension TonWalletInfoFromDomain on TonWalletInfo {
  TonWalletInfoDto toDto() => TonWalletInfoDto(
        workchain: workchain,
        address: address,
        publicKey: publicKey,
        walletType: walletType.toDto(),
        contractState: contractState.toDto(),
        details: details.toDto(),
        custodians: custodians,
      );
}
