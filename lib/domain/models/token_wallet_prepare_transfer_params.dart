import 'package:freezed_annotation/freezed_annotation.dart';

part 'token_wallet_prepare_transfer_params.freezed.dart';

@freezed
class TokenWalletPrepareTransferParams with _$TokenWalletPrepareTransferParams {
  factory TokenWalletPrepareTransferParams({
    required String owner,
    required String rootTokenContract,
    required String destination,
    required String amount,
    required bool notifyReceiver,
    String? payload,
  }) = _TokenWalletPrepareTransferParams;
}
