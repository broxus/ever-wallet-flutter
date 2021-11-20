import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'ton_wallet_info.freezed.dart';

@freezed
class TonWalletInfo with _$TonWalletInfo {
  const factory TonWalletInfo({
    required int workchain,
    required String address,
    required String publicKey,
    required WalletType walletType,
    required ContractState contractState,
    required TonWalletDetails details,
    required List<String>? custodians,
  }) = _TonWalletInfo;
}
