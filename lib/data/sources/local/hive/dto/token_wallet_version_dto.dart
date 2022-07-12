import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'token_wallet_version_dto.g.dart';

@HiveType(typeId: 35)
enum TokenWalletVersionDto {
  @HiveField(0)
  oldTip3v4,
  @HiveField(1)
  tip3,
}

extension TokenWalletVersionX on TokenWalletVersion {
  TokenWalletVersionDto toDto() {
    switch (this) {
      case TokenWalletVersion.oldTip3v4:
        return TokenWalletVersionDto.oldTip3v4;
      case TokenWalletVersion.tip3:
        return TokenWalletVersionDto.tip3;
    }
  }
}

extension TokenWalletVersionDtoX on TokenWalletVersionDto {
  TokenWalletVersion toModel() {
    switch (this) {
      case TokenWalletVersionDto.oldTip3v4:
        return TokenWalletVersion.oldTip3v4;
      case TokenWalletVersionDto.tip3:
        return TokenWalletVersion.tip3;
    }
  }
}
