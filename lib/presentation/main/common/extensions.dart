import 'package:easy_localization/easy_localization.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

import '../../../generated/codegen_loader.g.dart';
import '../../common/constants.dart';
import '../../common/extensions.dart';

extension KnownPayloadX on KnownPayload {
  Tuple2<String, Map<String, String>>? toRepresentableData() => when(
        comment: (value) => value.isNotEmpty
            ? Tuple2(
                LocaleKeys.comment.tr(),
                {
                  LocaleKeys.comment.tr(): value,
                },
              )
            : null,
        tokenOutgoingTransfer: (tokenOutgoingTransfer) => Tuple2(
          LocaleKeys.token_incoming_transfer.tr(),
          {
            ...tokenOutgoingTransfer.to.when(
              ownerWallet: (address) => {
                LocaleKeys.owner_wallet.tr(): address,
              },
              tokenWallet: (address) => {
                LocaleKeys.token_wallet.tr(): address,
              },
            ),
            LocaleKeys.tokens.tr(): tokenOutgoingTransfer.tokens,
          },
        ),
        tokenSwapBack: (tokenSwapBack) => Tuple2(
          LocaleKeys.token_swap_back.tr(),
          {
            LocaleKeys.tokens.tr(): tokenSwapBack.tokens,
            LocaleKeys.callback_address.tr(): tokenSwapBack.callbackAddress,
            LocaleKeys.callback_payload.tr(): tokenSwapBack.callbackPayload,
          },
        ),
      );
}

extension WalletInteractionMethodX on WalletInteractionMethod {
  Tuple2<String, Map<String, String>> toRepresentableData() => when(
        walletV3Transfer: () => Tuple2(
          LocaleKeys.wallet_v3_transfer.tr(),
          <String, String>{},
        ),
        multisig: (multisigTransaction) => multisigTransaction.when(
          send: (multisigSendTransaction) => Tuple2(
            LocaleKeys.multisig_send_transaction.tr(),
            {
              LocaleKeys.destination.tr(): multisigSendTransaction.dest,
              LocaleKeys.value.tr():
                  '${multisigSendTransaction.value.toTokens().removeZeroes().formatValue()} $kEverTicker',
              LocaleKeys.bounce.tr(): multisigSendTransaction.bounce ? LocaleKeys.yes.tr() : LocaleKeys.no.tr(),
              LocaleKeys.flags.tr(): multisigSendTransaction.flags.toString(),
              LocaleKeys.payload.tr(): multisigSendTransaction.payload,
            },
          ),
          submit: (multisigSubmitTransaction) => Tuple2(
            LocaleKeys.multisig_submit_transaction.tr(),
            {
              LocaleKeys.custodian.tr(): multisigSubmitTransaction.custodian,
              LocaleKeys.destination.tr(): multisigSubmitTransaction.dest,
              LocaleKeys.value.tr():
                  '${multisigSubmitTransaction.value.toTokens().removeZeroes().formatValue()} $kEverTicker',
              LocaleKeys.bounce.tr(): multisigSubmitTransaction.bounce ? LocaleKeys.yes.tr() : LocaleKeys.no.tr(),
              LocaleKeys.all_balance.tr():
                  multisigSubmitTransaction.allBalance ? LocaleKeys.yes.tr() : LocaleKeys.no.tr(),
              LocaleKeys.payload.tr(): multisigSubmitTransaction.payload,
              LocaleKeys.transaction_id.tr(): multisigSubmitTransaction.transId,
            },
          ),
          confirm: (multisigConfirmTransaction) => Tuple2(
            LocaleKeys.multisig_confirm_transaction.tr(),
            {
              LocaleKeys.custodian.tr(): multisigConfirmTransaction.custodian,
              LocaleKeys.transaction_id.tr(): multisigConfirmTransaction.transactionId,
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
      if (recipient != null) LocaleKeys.recipient.tr(): recipient!,
      if (knownPayload != null) ...{
        LocaleKeys.known_payload.tr(): knownPayloadData!.item1,
        ...knownPayloadData.item2,
      },
      LocaleKeys.method.tr(): methodData.item1,
      ...methodData.item2,
    };
  }
}

extension TokenWalletDeployedNotificationX on TokenWalletDeployedNotification {
  Map<String, String> toRepresentableData() => {
        LocaleKeys.root_token_contract.tr(): rootTokenContract,
      };
}

extension DePoolReceiveAnswerNotificationX on DePoolReceiveAnswerNotification {
  Map<String, String> toRepresentableData() => {
        LocaleKeys.error_code.tr(): '$errorCode',
        LocaleKeys.comment.tr(): comment,
      };
}

extension DePoolOnRoundCompleteNotificationX on DePoolOnRoundCompleteNotification {
  Map<String, String> toRepresentableData() => {
        LocaleKeys.round_id.tr(): roundId,
        LocaleKeys.reward.tr(): '${reward.toTokens().removeZeroes().formatValue()} $kEverTicker',
        LocaleKeys.ordinary_stake.tr(): '${ordinaryStake.toTokens().removeZeroes().formatValue()} $kEverTicker',
        LocaleKeys.vesting_stake.tr(): '${vestingStake.toTokens().removeZeroes().formatValue()} $kEverTicker',
        LocaleKeys.lock_stake.tr(): '${lockStake.toTokens().removeZeroes().formatValue()} $kEverTicker',
        LocaleKeys.reinvest.tr(): reinvest ? LocaleKeys.yes.tr() : LocaleKeys.no.tr(),
        LocaleKeys.reason.tr(): reason.toString(),
      };
}
