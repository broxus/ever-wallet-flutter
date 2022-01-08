import 'package:freezed_annotation/freezed_annotation.dart';

part 'ton_wallet_prepare_confirm_transaction_params.freezed.dart';

@freezed
class TonWalletPrepareConfirmTransactionParams with _$TonWalletPrepareConfirmTransactionParams {
  factory TonWalletPrepareConfirmTransactionParams({
    required String publicKey,
    required String address,
    required String transactionId,
  }) = _TonWalletPrepareConfirmTransactionParams;
}
