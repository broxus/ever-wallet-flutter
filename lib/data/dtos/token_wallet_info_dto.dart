import 'package:crystal/data/dtos/contract_state_dto.dart';
import 'package:crystal/data/dtos/symbol_dto.dart';
import 'package:crystal/data/dtos/token_wallet_version_dto.dart';
import 'package:crystal/domain/models/token_wallet_info.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'token_wallet_info_dto.freezed.dart';
part 'token_wallet_info_dto.g.dart';

@freezed
class TokenWalletInfoDto with _$TokenWalletInfoDto {
  @HiveType(typeId: 2)
  const factory TokenWalletInfoDto({
    @HiveField(0) required String address,
    @HiveField(1) required String balance,
    @HiveField(2) required ContractStateDto contractState,
    @HiveField(3) required String owner,
    @HiveField(4) required SymbolDto symbol,
    @HiveField(5) required TokenWalletVersionDto version,
    @HiveField(6) required String ownerPublicKey,
  }) = _TokenWalletInfoDto;
}

extension TokenWalletInfoDtoToDomain on TokenWalletInfoDto {
  TokenWalletInfo toModel() => TokenWalletInfo(
        address: address,
        balance: balance,
        contractState: contractState.toModel(),
        owner: owner,
        symbol: symbol.toModel(),
        version: version.toModel(),
        ownerPublicKey: ownerPublicKey,
      );
}

extension TokenWalletInfoFromDomain on TokenWalletInfo {
  TokenWalletInfoDto toDto() => TokenWalletInfoDto(
        address: address,
        balance: balance,
        contractState: contractState.toDto(),
        owner: owner,
        symbol: symbol.toDto(),
        version: version.toDto(),
        ownerPublicKey: ownerPublicKey,
      );
}
