import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

import '../../common/extensions.dart';

extension KnownPayloadX on KnownPayload {
  Tuple2<String, Map<String, String>>? toRepresentableData() => when(
        comment: (value) => value.isNotEmpty
            ? Tuple2(
                'Comment',
                {
                  'Comment': value,
                },
              )
            : null,
        tokenOutgoingTransfer: (tokenOutgoingTransfer) => Tuple2(
          'Token outgoing transfer',
          {
            ...tokenOutgoingTransfer.to.when(
              ownerWallet: (address) => {
                'Owner wallet': address,
              },
              tokenWallet: (address) => {
                'Token wallet': address,
              },
            ),
            'Tokens': tokenOutgoingTransfer.tokens,
          },
        ),
        tokenSwapBack: (tokenSwapBack) => Tuple2(
          'Token swap back',
          {
            'Tokens': tokenSwapBack.tokens,
            'Callback address': tokenSwapBack.callbackAddress,
            'Callback payload': tokenSwapBack.callbackPayload,
          },
        ),
      );
}

extension WalletInteractionMethodX on WalletInteractionMethod {
  Tuple2<String, Map<String, String>> toRepresentableData() => when(
        walletV3Transfer: () => const Tuple2(
          'WalletV3 transfer',
          <String, String>{},
        ),
        multisig: (multisigTransaction) => multisigTransaction.when(
          send: (multisigSendTransaction) => Tuple2(
            'Multisig send transaction',
            {
              'Destination': multisigSendTransaction.dest,
              'Value': '${multisigSendTransaction.value.toTokens().removeZeroes().formatValue()} EVER',
              'Bounce': multisigSendTransaction.bounce ? 'Yes' : 'No',
              'Flags': multisigSendTransaction.flags.toString(),
              'Payload': multisigSendTransaction.payload,
            },
          ),
          submit: (multisigSubmitTransaction) => Tuple2(
            'Multisig submit transaction',
            {
              'Custodian': multisigSubmitTransaction.custodian,
              'Destination': multisigSubmitTransaction.dest,
              'Value': '${multisigSubmitTransaction.value.toTokens().removeZeroes().formatValue()} EVER',
              'Bounce': multisigSubmitTransaction.bounce ? 'Yes' : 'No',
              'All balance': multisigSubmitTransaction.allBalance ? 'Yes' : 'No',
              'Payload': multisigSubmitTransaction.payload,
              'Transaction ID': multisigSubmitTransaction.transId,
            },
          ),
          confirm: (multisigConfirmTransaction) => Tuple2(
            'Multisig confirm transaction',
            {
              'Custodian': multisigConfirmTransaction.custodian,
              'Transaction ID': multisigConfirmTransaction.transactionId,
            },
          ),
        ),
      );
}

extension WalletInteractionInfoX on WalletInteractionInfo {
  Map<String, String> toRepresentableData() {
    final knownPayloadData = knownPayload?.toRepresentableData();
    final methodData = method.toRepresentableData();

    return {
      if (recipient != null) 'Recipient': recipient!,
      if (knownPayload != null) ...{
        'Known payload': knownPayloadData!.item1,
        ...knownPayloadData.item2,
      },
      'Method': methodData.item1,
      ...methodData.item2,
    };
  }
}

extension TokenWalletDeployedNotificationX on TokenWalletDeployedNotification {
  Map<String, String> toRepresentableData() => {
        'Root token contract': rootTokenContract,
      };
}

extension DePoolReceiveAnswerNotificationX on DePoolReceiveAnswerNotification {
  Map<String, String> toRepresentableData() => {
        'Error code': errorCode.toString(),
        'Comment': comment,
      };
}

extension DePoolOnRoundCompleteNotificationX on DePoolOnRoundCompleteNotification {
  Map<String, String> toRepresentableData() => {
        'Round ID': roundId,
        'Reward': '${reward.toTokens().removeZeroes().formatValue()} EVER',
        'Ordinary stake': '${ordinaryStake.toTokens().removeZeroes().formatValue()} EVER',
        'Vesting stake': '${vestingStake.toTokens().removeZeroes().formatValue()} EVER',
        'Lock stake': '${lockStake.toTokens().removeZeroes().formatValue()} EVER',
        'Reinvest': reinvest ? 'Yes' : 'No',
        'Reason': reason.toString(),
      };
}
