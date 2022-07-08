import 'package:ever_wallet/data/sources/local/hive/dto/meta.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/multisig_type_dto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'wallet_type_dto.freezed.dart';
part 'wallet_type_dto.g.dart';

@freezedDto
class WalletTypeDto with _$WalletTypeDto {
  @HiveType(typeId: 51)
  const factory WalletTypeDto.multisig(@HiveField(0) MultisigTypeDto data) = _WalletTypeDtoMultisig;

  @HiveType(typeId: 52)
  const factory WalletTypeDto.walletV3() = _WalletTypeDtoWalletV3;

  @HiveType(typeId: 53)
  const factory WalletTypeDto.highloadWalletV2() = _WalletTypeDtoHighloadWalletV2;
}

extension WalletTypeX on WalletType {
  WalletTypeDto toDto() => when(
        multisig: (data) => WalletTypeDto.multisig(data.toDto()),
        walletV3: () => const WalletTypeDto.walletV3(),
        highloadWalletV2: () => const WalletTypeDto.highloadWalletV2(),
      );
}

extension WalletTypeDtoX on WalletTypeDto {
  WalletType toModel() => when(
        multisig: (data) => WalletType.multisig(data.toModel()),
        walletV3: () => const WalletType.walletV3(),
        highloadWalletV2: () => const WalletType.highloadWalletV2(),
      );
}
