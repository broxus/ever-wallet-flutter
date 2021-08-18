import 'package:flutter/foundation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

extension TonTransactionDataToComment on TransactionAdditionalInfo {
  String? toComment() => when(
        comment: (value) => value,
        dePoolOnRoundComplete: (notification) => 'Round complete, reward: ${notification.reward.toTokens()}',
        dePoolReceiveAnswer: (notification) => 'DePool answer, comment: ${notification.comment}',
        tokenWalletDeployed: (notification) => 'Token wallet deployed, contract: ${notification.rootTokenContract}',
        ethEventStatusChanged: (status) => 'ETH status changed: ${describeEnum(status)}',
        tonEventStatusChanged: (status) => 'TON status changed: ${describeEnum(status)}',
        walletInteraction: (info) => info.knownPayload?.when(
          comment: (value) => value,
          tokenOutgoingTransfer: (_) => null,
          tokenSwapBack: (_) => null,
        ),
      );
}

extension TokenTransactionDataToComment on TokenWalletTransaction {
  String? toComment() => maybeWhen(
        swapBack: (tokenSwapBack) => 'Swap back',
        accept: (value) => 'Accepted',
        transferBounced: (value) => 'Transfer bounced',
        swapBackBounced: (value) => 'Swap back bounced',
        orElse: () => null,
      );
}
