import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

import '../../common/constants.dart';
import '../../common/extensions.dart';

extension KnownPayloadX on KnownPayload {
  Tuple2<String, Map<String, String>>? toRepresentableData(BuildContext context) => when(
        comment: (value) => value.isNotEmpty
            ? Tuple2(
                AppLocalizations.of(context)!.comment,
                {
                  AppLocalizations.of(context)!.comment: value,
                },
              )
            : null,
        tokenOutgoingTransfer: (tokenOutgoingTransfer) => Tuple2(
          AppLocalizations.of(context)!.token_incoming_transfer,
          {
            ...tokenOutgoingTransfer.to.when(
              ownerWallet: (address) => {
                AppLocalizations.of(context)!.owner_wallet: address,
              },
              tokenWallet: (address) => {
                AppLocalizations.of(context)!.token_wallet: address,
              },
            ),
            AppLocalizations.of(context)!.tokens: tokenOutgoingTransfer.tokens,
          },
        ),
        tokenSwapBack: (tokenSwapBack) => Tuple2(
          AppLocalizations.of(context)!.token_swap_back,
          {
            AppLocalizations.of(context)!.tokens: tokenSwapBack.tokens,
            AppLocalizations.of(context)!.callback_address: tokenSwapBack.callbackAddress,
            AppLocalizations.of(context)!.callback_payload: tokenSwapBack.callbackPayload,
          },
        ),
      );
}

extension WalletInteractionMethodX on WalletInteractionMethod {
  Tuple2<String, Map<String, String>> toRepresentableData(BuildContext context) => when(
        walletV3Transfer: () => Tuple2(
          AppLocalizations.of(context)!.wallet_v3_transfer,
          <String, String>{},
        ),
        multisig: (multisigTransaction) => multisigTransaction.when(
          send: (multisigSendTransaction) => Tuple2(
            AppLocalizations.of(context)!.multisig_send_transaction,
            {
              AppLocalizations.of(context)!.destination: multisigSendTransaction.dest,
              AppLocalizations.of(context)!.value:
                  '${multisigSendTransaction.value.toTokens().removeZeroes().formatValue()} $kEverTicker',
              AppLocalizations.of(context)!.bounce: multisigSendTransaction.bounce
                  ? AppLocalizations.of(context)!.yes
                  : AppLocalizations.of(context)!.no,
              AppLocalizations.of(context)!.flags: multisigSendTransaction.flags.toString(),
              AppLocalizations.of(context)!.payload: multisigSendTransaction.payload,
            },
          ),
          submit: (multisigSubmitTransaction) => Tuple2(
            AppLocalizations.of(context)!.multisig_submit_transaction,
            {
              AppLocalizations.of(context)!.custodian: multisigSubmitTransaction.custodian,
              AppLocalizations.of(context)!.destination: multisigSubmitTransaction.dest,
              AppLocalizations.of(context)!.value:
                  '${multisigSubmitTransaction.value.toTokens().removeZeroes().formatValue()} $kEverTicker',
              AppLocalizations.of(context)!.bounce: multisigSubmitTransaction.bounce
                  ? AppLocalizations.of(context)!.yes
                  : AppLocalizations.of(context)!.no,
              AppLocalizations.of(context)!.all_balance: multisigSubmitTransaction.allBalance
                  ? AppLocalizations.of(context)!.yes
                  : AppLocalizations.of(context)!.no,
              AppLocalizations.of(context)!.payload: multisigSubmitTransaction.payload,
              AppLocalizations.of(context)!.transaction_id: multisigSubmitTransaction.transId,
            },
          ),
          confirm: (multisigConfirmTransaction) => Tuple2(
            AppLocalizations.of(context)!.multisig_confirm_transaction,
            {
              AppLocalizations.of(context)!.custodian: multisigConfirmTransaction.custodian,
              AppLocalizations.of(context)!.transaction_id:
                  multisigConfirmTransaction.transactionId,
            },
          ),
        ),
      );
}

extension WalletInteractionInfoX on WalletInteractionInfo {
  Map<String, String> toRepresentableData(BuildContext context) {
    final knownPayloadData = knownPayload?.toRepresentableData(context);
    final methodData = method.toRepresentableData(context);

    return {
      if (recipient != null) AppLocalizations.of(context)!.recipient: recipient!,
      if (knownPayloadData != null) ...{
        AppLocalizations.of(context)!.known_payload: knownPayloadData.item1,
        ...knownPayloadData.item2,
      },
      AppLocalizations.of(context)!.method: methodData.item1,
      ...methodData.item2,
    };
  }
}

extension TokenWalletDeployedNotificationX on TokenWalletDeployedNotification {
  Map<String, String> toRepresentableData(BuildContext context) => {
        AppLocalizations.of(context)!.root_token_contract: rootTokenContract,
      };
}

extension DePoolReceiveAnswerNotificationX on DePoolReceiveAnswerNotification {
  Map<String, String> toRepresentableData(BuildContext context) => {
        AppLocalizations.of(context)!.error_code: '$errorCode',
        AppLocalizations.of(context)!.comment: comment,
      };
}

extension DePoolOnRoundCompleteNotificationX on DePoolOnRoundCompleteNotification {
  Map<String, String> toRepresentableData({
    required BuildContext context,
    required String ticker,
  }) =>
      {
        AppLocalizations.of(context)!.round_id: roundId,
        AppLocalizations.of(context)!.reward:
            '${reward.toTokens().removeZeroes().formatValue()} $kEverTicker',
        AppLocalizations.of(context)!.ordinary_stake:
            '${ordinaryStake.toTokens().removeZeroes().formatValue()} $kEverTicker',
        AppLocalizations.of(context)!.vesting_stake:
            '${vestingStake.toTokens().removeZeroes().formatValue()} $kEverTicker',
        AppLocalizations.of(context)!.lock_stake:
            '${lockStake.toTokens().removeZeroes().formatValue()} $kEverTicker',
        AppLocalizations.of(context)!.reinvest:
            reinvest ? AppLocalizations.of(context)!.yes : AppLocalizations.of(context)!.no,
        AppLocalizations.of(context)!.reason: reason.toString(),
      };
}
