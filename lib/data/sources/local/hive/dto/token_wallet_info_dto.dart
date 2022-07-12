import 'package:ever_wallet/data/models/token_wallet_info.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/contract_state_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/meta.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/symbol_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/token_wallet_version_dto.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'token_wallet_info_dto.freezed.dart';
part 'token_wallet_info_dto.g.dart';

@freezedDto
class TokenWalletInfoDto with _$TokenWalletInfoDto {
  @HiveType(typeId: 27)
  const factory TokenWalletInfoDto({
    @HiveField(0) required String owner,
    @HiveField(1) required String address,
    @HiveField(2) required SymbolDto symbol,
    @HiveField(3) required TokenWalletVersionDto version,
    @HiveField(4) required String balance,
    @HiveField(5) required ContractStateDto contractState,
  }) = _TokenWalletInfoDto;
}

extension TokenWalletInfoX on TokenWalletInfo {
  TokenWalletInfoDto toDto() => TokenWalletInfoDto(
        owner: owner,
        address: address,
        symbol: symbol.toDto(),
        version: version.toDto(),
        balance: balance,
        contractState: contractState.toDto(),
      );
}

extension TokenWalletInfoDtoX on TokenWalletInfoDto {
  TokenWalletInfo toModel() => TokenWalletInfo(
        owner: owner,
        address: address,
        symbol: symbol.toModel(),
        version: version.toModel(),
        balance: balance,
        contractState: contractState.toModel(),
      );
}
