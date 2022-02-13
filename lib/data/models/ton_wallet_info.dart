import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'ton_wallet_info.freezed.dart';
part 'ton_wallet_info.g.dart';

@freezed
class TonWalletInfo with _$TonWalletInfo {
  @HiveType(typeId: 220)
  const factory TonWalletInfo({
    @HiveField(0) required int workchain,
    @HiveField(1) required String address,
    @HiveField(2) required String publicKey,
    @HiveField(3) required WalletType walletType,
    @HiveField(4) required ContractState contractState,
    @HiveField(5) required TonWalletDetails details,
    @HiveField(6) List<String>? custodians,
  }) = _TonWalletInfo;

  factory TonWalletInfo.fromJson(Map<String, dynamic> json) => _$TonWalletInfoFromJson(json);
}
