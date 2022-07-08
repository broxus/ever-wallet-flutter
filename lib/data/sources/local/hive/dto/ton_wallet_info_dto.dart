import 'package:ever_wallet/data/models/ton_wallet_info.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/contract_state_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/meta.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/ton_wallet_details_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/wallet_type_dto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'ton_wallet_info_dto.freezed.dart';
part 'ton_wallet_info_dto.g.dart';

@freezedDto
class TonWalletInfoDto with _$TonWalletInfoDto {
  @HiveType(typeId: 37)
  const factory TonWalletInfoDto({
    @HiveField(0) required int workchain,
    @HiveField(1) required String address,
    @HiveField(2) required String publicKey,
    @HiveField(3) required WalletTypeDto walletType,
    @HiveField(4) required ContractStateDto contractState,
    @HiveField(5) required TonWalletDetailsDto details,
    @HiveField(6) List<String>? custodians,
  }) = _TonWalletInfoDto;
}

extension TonWalletInfoX on TonWalletInfo {
  TonWalletInfoDto toDto() => TonWalletInfoDto(
        workchain: workchain,
        address: address,
        publicKey: publicKey,
        walletType: walletType.toDto(),
        contractState: contractState.toDto(),
        details: details.toDto(),
      );
}

extension TonWalletInfoDtoX on TonWalletInfoDto {
  TonWalletInfo toDto() => TonWalletInfo(
        workchain: workchain,
        address: address,
        publicKey: publicKey,
        walletType: walletType.toModel(),
        contractState: contractState.toModel(),
        details: details.toModel(),
      );
}
