import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'ton_wallet_multisig_ordinary_transaction.freezed.dart';

@freezed
class TonWalletMultisigOrdinaryTransaction with _$TonWalletMultisigOrdinaryTransaction {
  const factory TonWalletMultisigOrdinaryTransaction({
    required String lt,
    String? prevTransactionLt,
    required String creator,
    required List<String> confirmations,
    required List<String> custodians,
    required bool isOutgoing,
    required String value,
    required String address,
    required DateTime date,
    required String fees,
    required String hash,
    String? comment,
    DePoolOnRoundCompleteNotification? dePoolOnRoundCompleteNotification,
    DePoolReceiveAnswerNotification? dePoolReceiveAnswerNotification,
    TokenWalletDeployedNotification? tokenWalletDeployedNotification,
    WalletInteractionInfo? walletInteractionInfo,
  }) = _TonWalletMultisigOrdinaryTransaction;
}
