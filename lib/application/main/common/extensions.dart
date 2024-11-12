import 'package:ever_wallet/application/common/extensions.dart';
import 'package:ever_wallet/data/repositories/transport_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

extension KnownPayloadX on KnownPayload {
  Tuple2<String, Map<String, String>>? toRepresentableData(
          BuildContext context) =>
      when(
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
            AppLocalizations.of(context)!.callback_address:
                data.callbackAddress,
            AppLocalizations.of(context)!.callback_payload:
                data.callbackPayload,
          },
        ),
      );
}

extension WalletInteractionMethodX on WalletInteractionMethod {
  Tuple2<String, Map<String, String>> toRepresentableData(
      BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final symbol = context
        .read<TransportRepository>()
        .transportWithData
        .item2
        .config
        .symbol;

    return when(
      walletV3Transfer: () => Tuple2(
        localizations.wallet_v3_transfer,
        <String, String>{},
      ),
      multisig: (data) => data.when(
        send: (data) => Tuple2(
          localizations.multisig_send_transaction,
          {
            localizations.destination: data.dest,
            localizations.value:
                '${data.value.toTokens().removeZeroes().formatValue()} $symbol',
            localizations.bounce:
                data.bounce ? localizations.yes : localizations.no,
            localizations.flags: data.flags.toString(),
            localizations.payload: data.payload,
          },
        ),
        submit: (data) => Tuple2(
          localizations.multisig_submit_transaction,
          {
            localizations.custodian: data.custodian,
            localizations.destination: data.dest,
            localizations.value:
                '${data.value.toTokens().removeZeroes().formatValue()} $symbol',
            localizations.bounce:
                data.bounce ? localizations.yes : localizations.no,
            localizations.all_balance:
                data.allBalance ? localizations.yes : localizations.no,
            localizations.payload: data.payload,
            localizations.transaction_id: data.transId,
          },
        ),
        confirm: (data) => Tuple2(
          localizations.multisig_confirm_transaction,
          {
            localizations.custodian: data.custodian,
            localizations.transaction_id: data.transactionId,
          },
        ),
      ),
    );
  }
}

extension WalletInteractionInfoX on WalletInteractionInfo {
  Map<String, String> toRepresentableData(BuildContext context) {
    final knownPayloadData = knownPayload?.toRepresentableData(context);
    final methodData = method.toRepresentableData(context);

    return {
      if (recipient != null)
        AppLocalizations.of(context)!.recipient: recipient!,
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

extension DePoolOnRoundCompleteNotificationX
    on DePoolOnRoundCompleteNotification {
  Map<String, String> toRepresentableData({
    required BuildContext context,
    required String ticker,
  }) =>
      {
        AppLocalizations.of(context)!.round_id: roundId,
        AppLocalizations.of(context)!.reward:
            '${reward.toTokens().removeZeroes().formatValue()} $ticker',
        AppLocalizations.of(context)!.ordinary_stake:
            '${ordinaryStake.toTokens().removeZeroes().formatValue()} $ticker',
        AppLocalizations.of(context)!.vesting_stake:
            '${vestingStake.toTokens().removeZeroes().formatValue()} $ticker',
        AppLocalizations.of(context)!.lock_stake:
            '${lockStake.toTokens().removeZeroes().formatValue()} $ticker',
        AppLocalizations.of(context)!.reinvest: reinvest
            ? AppLocalizations.of(context)!.yes
            : AppLocalizations.of(context)!.no,
        AppLocalizations.of(context)!.reason: reason.toString(),
      };
}
