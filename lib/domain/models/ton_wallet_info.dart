import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'ton_wallet_info.freezed.dart';

@freezed
class TonWalletInfo with _$TonWalletInfo {
  const factory TonWalletInfo({
    required String address,
    required ContractState contractState,
    required WalletType walletType,
    required TonWalletDetails details,
    required String publicKey,
  }) = _TonWalletInfo;
}
