import 'package:freezed_annotation/freezed_annotation.dart';

part 'ton_wallet_prepare_transfer_params.freezed.dart';

@freezed
class TonWalletPrepareTransferParams with _$TonWalletPrepareTransferParams {
  factory TonWalletPrepareTransferParams({
    required String address,
    required String publicKey,
    required String destination,
    required String amount,
    String? body,
    @Default(true) bool isComment,
  }) = _TonWalletPrepareTransferParams;
}
