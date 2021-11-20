import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'token_wallet_info.freezed.dart';

@freezed
class TokenWalletInfo with _$TokenWalletInfo {
  const factory TokenWalletInfo({
    required String owner,
    required String address,
    required Symbol symbol,
    required TokenWalletVersion version,
    required String balance,
    required ContractState contractState,
  }) = _TokenWalletInfo;
}
