import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../design/design.dart';
import '../../../../../design/transaction_time.dart';
import '../../../../../design/widgets/ton_asset_icon.dart';
import '../../../../../design/widgets/transaction_type_label.dart';
import '../../modals/ton_wallet_multisig_pending_transaction_info/show_ton_wallet_multisig_pending_transaction_info.dart';
import 'widgets/address_title.dart';
import 'widgets/confirmation_time_counter.dart';
import 'widgets/confirms_title.dart';
import 'widgets/date_title.dart';
import 'widgets/fees_title.dart';
import 'widgets/icon_forward.dart';
import 'widgets/value_title.dart';

class TonWalletMultisigPendingTransactionHolder extends StatelessWidget {
  final TonWalletTransactionWithData transactionWithData;
  final MultisigPendingTransaction multisigPendingTransaction;
  final String walletAddress;
  final String walletPublicKey;
  final WalletType walletType;
  final List<String> custodians;
  final TonWalletDetails details;

  const TonWalletMultisigPendingTransactionHolder({
    Key? key,
    required this.transactionWithData,
    required this.multisigPendingTransaction,
    required this.walletAddress,
    required this.walletPublicKey,
    required this.walletType,
    required this.custodians,
    required this.details,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final msgSender = transactionWithData.transaction.inMessage.src;

    final dataSender = transactionWithData.data?.maybeWhen(
      walletInteraction: (info) => info.knownPayload?.maybeWhen(
        tokenSwapBack: (tokenSwapBack) => tokenSwapBack.callbackAddress,
        orElse: () => null,
      ),
      orElse: () => null,
    );

    final sender = dataSender ?? msgSender;

    final msgRecipient = transactionWithData.transaction.outMessages.firstOrNull?.dst;

    final dataRecipient = transactionWithData.data?.maybeWhen(
      walletInteraction: (info) =>
          info.knownPayload?.maybeWhen(
            tokenOutgoingTransfer: (tokenOutgoingTransfer) => tokenOutgoingTransfer.to.address,
            orElse: () => null,
          ) ??
          info.method.maybeWhen(
            multisig: (multisigTransaction) => multisigTransaction.maybeWhen(
              send: (multisigSendTransaction) => multisigSendTransaction.dest,
              submit: (multisigSubmitTransaction) => multisigSubmitTransaction.dest,
              orElse: () => null,
            ),
            orElse: () => null,
          ) ??
          info.recipient,
      orElse: () => null,
    );

    final recipient = dataRecipient ?? msgRecipient;

    final isOutgoing = recipient != null;

    final msgValue = (isOutgoing
            ? transactionWithData.transaction.outMessages.firstOrNull?.value
            : transactionWithData.transaction.inMessage.value) ??
        transactionWithData.transaction.inMessage.value;

    final dataValue = transactionWithData.data?.maybeWhen(
      dePoolOnRoundComplete: (notification) => notification.reward,
      walletInteraction: (info) => info.method.maybeWhen(
        multisig: (multisigTransaction) => multisigTransaction.maybeWhen(
          send: (multisigSendTransaction) => multisigSendTransaction.value,
          submit: (multisigSubmitTransaction) => multisigSubmitTransaction.value,
          orElse: () => null,
        ),
        orElse: () => null,
      ),
      orElse: () => null,
    );

    final value = dataValue ?? msgValue;

    final address = (isOutgoing ? recipient : sender) ?? walletAddress;

    final date = transactionWithData.transaction.createdAt.toDateTime();

    final fees = transactionWithData.transaction.totalFees;

    final signsReceived = multisigPendingTransaction.signsReceived;

    final signsRequired = multisigPendingTransaction.signsRequired;

    final timeForConfirmation = Duration(seconds: details.expirationTime);

    final expireAt = date.add(timeForConfirmation);

    return InkWell(
      onTap: () => showTonWalletMultisigPendingTransactionInfo(
        context: context,
        transactionWithData: transactionWithData,
        multisigPendingTransaction: multisigPendingTransaction,
        walletAddress: walletAddress,
        walletPublicKey: walletPublicKey,
        walletType: walletType,
        custodians: custodians,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const TonAssetIcon(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ValueTitle(
                          value: value.toTokens().removeZeroes().formatValue(),
                          currency: 'EVER',
                          isOutgoing: isOutgoing,
                        ),
                      ),
                      const IconForward(),
                    ],
                  ),
                  const SizedBox(height: 4),
                  FeesTitle(fees: fees.toTokens().removeZeroes().formatValue()),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: AddressTitle(address: address),
                      ),
                      DateTitle(date: date),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const TransactionTypeLabel(
                    text: 'Waiting for confirmation',
                    color: CrystalColor.error,
                  ),
                  const SizedBox(height: 4),
                  ConfirmsTitle(
                    signsReceived: signsReceived,
                    signsRequired: signsRequired,
                  ),
                  const SizedBox(height: 4),
                  ConfirmationTimeCounter(
                    expireAt: expireAt,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
