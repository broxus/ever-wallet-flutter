import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'token_wallet_version_dto.g.dart';

@HiveType(typeId: 7)
enum TokenWalletVersionDto {
  @HiveField(0)
  tip3v1,
  @HiveField(1)
  tip3v2,
  @HiveField(2)
  tip3v3,
  @HiveField(3)
  tip3v4,
}

extension TokenWalletVersionDtoToDomain on TokenWalletVersionDto {
  TokenWalletVersion toModel() => TokenWalletVersion.values[index];
}

extension TokenWalletVersionFromDomain on TokenWalletVersion {
  TokenWalletVersionDto toDto() => TokenWalletVersionDto.values[index];
}
