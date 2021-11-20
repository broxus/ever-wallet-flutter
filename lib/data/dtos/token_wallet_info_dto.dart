import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

import '../../domain/models/token_wallet_info.dart';
import 'contract_state_dto.dart';
import 'symbol_dto.dart';
import 'token_wallet_version_dto.dart';

part 'token_wallet_info_dto.freezed.dart';
part 'token_wallet_info_dto.g.dart';

@freezed
class TokenWalletInfoDto with _$TokenWalletInfoDto {
  @HiveType(typeId: 2)
  const factory TokenWalletInfoDto({
    @HiveField(0) required String owner,
    @HiveField(1) required String address,
    @HiveField(2) required SymbolDto symbol,
    @HiveField(3) required TokenWalletVersionDto version,
    @HiveField(4) required String balance,
    @HiveField(5) required ContractStateDto contractState,
  }) = _TokenWalletInfoDto;
}

extension TokenWalletInfoDtoToDomain on TokenWalletInfoDto {
  TokenWalletInfo toModel() => TokenWalletInfo(
        owner: owner,
        address: address,
        symbol: symbol.toModel(),
        version: version.toModel(),
        balance: balance,
        contractState: contractState.toModel(),
      );
}

extension TokenWalletInfoFromDomain on TokenWalletInfo {
  TokenWalletInfoDto toDto() => TokenWalletInfoDto(
        owner: owner,
        address: address,
        symbol: symbol.toDto(),
        version: version.toDto(),
        balance: balance,
        contractState: contractState.toDto(),
      );
}
