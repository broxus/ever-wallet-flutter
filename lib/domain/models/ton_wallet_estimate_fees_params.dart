import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'ton_wallet_estimate_fees_params.freezed.dart';

@freezed
class TonWalletEstimateFeesParams with _$TonWalletEstimateFeesParams {
  factory TonWalletEstimateFeesParams({
    required String address,
    required UnsignedMessage message,
    @Default('0') String amount,
  }) = _TonWalletEstimateFeesParams;
}
