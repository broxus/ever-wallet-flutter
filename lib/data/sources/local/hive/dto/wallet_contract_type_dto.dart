import 'package:ever_wallet/data/models/wallet_contract_type.dart';
import 'package:hive/hive.dart';

part 'wallet_contract_type_dto.g.dart';

@HiveType(typeId: 221)
enum WalletContractTypeDto {
  @HiveField(0)
  safeMultisigWallet,
  @HiveField(1)
  safeMultisigWallet24h,
  @HiveField(2)
  setcodeMultisigWallet,
  @HiveField(3)
  setcodeMultisigWallet24h,
  @HiveField(4)
  bridgeMultisigWallet,
  @HiveField(5)
  surfWallet,
  @HiveField(6)
  walletV3,
  @HiveField(7)
  highloadWalletV2,
}

extension WalletContractTypeX on WalletContractType {
  WalletContractTypeDto toDto() {
    switch (this) {
      case WalletContractType.safeMultisigWallet:
        return WalletContractTypeDto.safeMultisigWallet;
      case WalletContractType.safeMultisigWallet24h:
        return WalletContractTypeDto.safeMultisigWallet24h;
      case WalletContractType.setcodeMultisigWallet:
        return WalletContractTypeDto.setcodeMultisigWallet;
      case WalletContractType.setcodeMultisigWallet24h:
        return WalletContractTypeDto.setcodeMultisigWallet24h;
      case WalletContractType.bridgeMultisigWallet:
        return WalletContractTypeDto.bridgeMultisigWallet;
      case WalletContractType.surfWallet:
        return WalletContractTypeDto.surfWallet;
      case WalletContractType.walletV3:
        return WalletContractTypeDto.walletV3;
      case WalletContractType.highloadWalletV2:
        return WalletContractTypeDto.highloadWalletV2;
    }
  }
}

extension WalletContractTypeDtoX on WalletContractTypeDto {
  WalletContractType toModel() {
    switch (this) {
      case WalletContractTypeDto.safeMultisigWallet:
        return WalletContractType.safeMultisigWallet;
      case WalletContractTypeDto.safeMultisigWallet24h:
        return WalletContractType.safeMultisigWallet24h;
      case WalletContractTypeDto.setcodeMultisigWallet:
        return WalletContractType.setcodeMultisigWallet;
      case WalletContractTypeDto.setcodeMultisigWallet24h:
        return WalletContractType.setcodeMultisigWallet24h;
      case WalletContractTypeDto.bridgeMultisigWallet:
        return WalletContractType.bridgeMultisigWallet;
      case WalletContractTypeDto.surfWallet:
        return WalletContractType.surfWallet;
      case WalletContractTypeDto.walletV3:
        return WalletContractType.walletV3;
      case WalletContractTypeDto.highloadWalletV2:
        return WalletContractType.highloadWalletV2;
    }
  }
}
