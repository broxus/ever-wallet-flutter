import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'ton_wallet_multisig_pending_transaction.freezed.dart';

@freezed
class TonWalletMultisigPendingTransaction with _$TonWalletMultisigPendingTransaction {
  const factory TonWalletMultisigPendingTransaction({
    required String lt,
    String? prevTransactionLt,
    required String creator,
    required List<String> confirmations,
    required List<String> custodians,
    required bool isOutgoing,
    required String value,
    required String address,
    required String walletAddress,
    required DateTime date,
    required String fees,
    required String hash,
    String? comment,
    DePoolOnRoundCompleteNotification? dePoolOnRoundCompleteNotification,
    DePoolReceiveAnswerNotification? dePoolReceiveAnswerNotification,
    TokenWalletDeployedNotification? tokenWalletDeployedNotification,
    WalletInteractionInfo? walletInteractionInfo,
    required int signsReceived,
    required int signsRequired,
    required String transactionId,
    required List<String> publicKeys,
    required bool canConfirm,
    required DateTime expireAt,
  }) = _TonWalletMultisigPendingTransaction;
}
