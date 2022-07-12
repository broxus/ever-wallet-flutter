import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'multisig_type_dto.g.dart';

@HiveType(typeId: 21)
enum MultisigTypeDto {
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
}

extension MultisigTypeX on MultisigType {
  MultisigTypeDto toDto() {
    switch (this) {
      case MultisigType.safeMultisigWallet:
        return MultisigTypeDto.safeMultisigWallet;
      case MultisigType.safeMultisigWallet24h:
        return MultisigTypeDto.safeMultisigWallet24h;
      case MultisigType.setcodeMultisigWallet:
        return MultisigTypeDto.setcodeMultisigWallet;
      case MultisigType.setcodeMultisigWallet24h:
        return MultisigTypeDto.setcodeMultisigWallet24h;
      case MultisigType.bridgeMultisigWallet:
        return MultisigTypeDto.bridgeMultisigWallet;
      case MultisigType.surfWallet:
        return MultisigTypeDto.surfWallet;
    }
  }
}

extension MultisigTypeDtoX on MultisigTypeDto {
  MultisigType toModel() {
    switch (this) {
      case MultisigTypeDto.safeMultisigWallet:
        return MultisigType.safeMultisigWallet;
      case MultisigTypeDto.safeMultisigWallet24h:
        return MultisigType.safeMultisigWallet24h;
      case MultisigTypeDto.setcodeMultisigWallet:
        return MultisigType.setcodeMultisigWallet;
      case MultisigTypeDto.setcodeMultisigWallet24h:
        return MultisigType.setcodeMultisigWallet24h;
      case MultisigTypeDto.bridgeMultisigWallet:
        return MultisigType.bridgeMultisigWallet;
      case MultisigTypeDto.surfWallet:
        return MultisigType.surfWallet;
    }
  }
}
