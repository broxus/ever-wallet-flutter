import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'wallet_type_dto.g.dart';

@HiveType(typeId: 3)
enum WalletTypeDto {
  @HiveField(0)
  safeMultisigWallet,
  @HiveField(1)
  safeMultisigWallet24h,
  @HiveField(2)
  setcodeMultisigWallet,
  @HiveField(3)
  bridgeMultisigWallet,
  @HiveField(4)
  surfWallet,
  @HiveField(5)
  walletV3,
}

extension WalletTypeDtoToDomain on WalletTypeDto {
  WalletType toModel() {
    switch (this) {
      case WalletTypeDto.safeMultisigWallet:
        return const WalletType.multisig(multisigType: MultisigType.safeMultisigWallet);
      case WalletTypeDto.safeMultisigWallet24h:
        return const WalletType.multisig(multisigType: MultisigType.safeMultisigWallet24h);
      case WalletTypeDto.setcodeMultisigWallet:
        return const WalletType.multisig(multisigType: MultisigType.setcodeMultisigWallet);
      case WalletTypeDto.bridgeMultisigWallet:
        return const WalletType.multisig(multisigType: MultisigType.bridgeMultisigWallet);
      case WalletTypeDto.surfWallet:
        return const WalletType.multisig(multisigType: MultisigType.surfWallet);
      case WalletTypeDto.walletV3:
        return const WalletType.walletV3();
    }
  }
}

extension WalletTypeFromDomain on WalletType {
  WalletTypeDto toDto() => when(
        multisig: (multisigType) => WalletTypeDto.values[multisigType.index],
        walletV3: () => WalletTypeDto.walletV3,
      );
}
