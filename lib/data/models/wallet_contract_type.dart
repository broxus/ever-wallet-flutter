import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'wallet_contract_type.g.dart';

@HiveType(typeId: 221)
@JsonEnum(fieldRename: FieldRename.pascal)
enum WalletContractType {
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
  @HiveField(8)
  everWallet,
  @HiveField(9)
  multisig2,
}
