import 'package:ever_wallet/application/common/constants.dart';
import 'package:ever_wallet/application/common/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

extension KnownPayloadX on KnownPayload {
  Tuple2<String, Map<String, String>>? toRepresentableData(BuildContext context) => when(
        comment: (data) => data.isNotEmpty
            ? Tuple2(
                AppLocalizations.of(context)!.comment,
                {
                  AppLocalizations.of(context)!.comment: data,
                },
              )
            : null,
        tokenOutgoingTransfer: (data) => Tuple2(
          AppLocalizations.of(context)!.token_incoming_transfer,
          {
            ...data.to.when(
              ownerWallet: (data) => {
                AppLocalizations.of(context)!.owner_wallet: data,
              },
              tokenWallet: (data) => {
                AppLocalizations.of(context)!.token_wallet: data,
              },
            ),
            AppLocalizations.of(context)!.tokens: data.tokens,
          },
        ),
        tokenSwapBack: (data) => Tuple2(
          AppLocalizations.of(context)!.token_swap_back,
          {
            AppLocalizations.of(context)!.tokens: data.tokens,
            AppLocalizations.of(context)!.callback_address: data.callbackAddress,
            AppLocalizations.of(context)!.callback_payload: data.callbackPayload,
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
        multisig: (data) => data.when(
          send: (data) => Tuple2(
            AppLocalizations.of(context)!.multisig_send_transaction,
            {
              AppLocalizations.of(context)!.destination: data.dest,
              AppLocalizations.of(context)!.value:
                  '${data.value.toTokens().removeZeroes().formatValue()} $kEverTicker',
              AppLocalizations.of(context)!.bounce: data.bounce
                  ? AppLocalizations.of(context)!.yes
                  : AppLocalizations.of(context)!.no,
              AppLocalizations.of(context)!.flags: data.flags.toString(),
              AppLocalizations.of(context)!.payload: data.payload,
            },
          ),
          submit: (data) => Tuple2(
            AppLocalizations.of(context)!.multisig_submit_transaction,
            {
              AppLocalizations.of(context)!.custodian: data.custodian,
              AppLocalizations.of(context)!.destination: data.dest,
              AppLocalizations.of(context)!.value:
                  '${data.value.toTokens().removeZeroes().formatValue()} $kEverTicker',
              AppLocalizations.of(context)!.bounce: data.bounce
                  ? AppLocalizations.of(context)!.yes
                  : AppLocalizations.of(context)!.no,
              AppLocalizations.of(context)!.all_balance: data.allBalance
                  ? AppLocalizations.of(context)!.yes
                  : AppLocalizations.of(context)!.no,
              AppLocalizations.of(context)!.payload: data.payload,
              AppLocalizations.of(context)!.transaction_id: data.transId,
            },
          ),
          confirm: (data) => Tuple2(
            AppLocalizations.of(context)!.multisig_confirm_transaction,
            {
              AppLocalizations.of(context)!.custodian: data.custodian,
              AppLocalizations.of(context)!.transaction_id: data.transactionId,
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
  Map<String, String> toRepresentableData(BuildContext context) => {
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
