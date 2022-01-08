import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'ton_wallet_send_params.freezed.dart';

@freezed
class TonWalletSendParams with _$TonWalletSendParams {
  factory TonWalletSendParams({
    required String address,
    required UnsignedMessage message,
    required String publicKey,
    required String password,
  }) = _TonWalletSendParams;
}
