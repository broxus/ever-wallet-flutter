import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../design/design.dart';
import '../../../../design/transaction_time.dart';
import '../../../../design/widgets/ton_asset_icon.dart';
import '../modals/ton_wallet_transaction_info/show_ton_wallet_transaction_info.dart';

class TonWalletTransactionHolder extends StatelessWidget {
  final TonWalletTransactionWithData transactionWithData;

  const TonWalletTransactionHolder({
    Key? key,
    required this.transactionWithData,
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
            : transactionWithData.transaction.inMessage.value)
        ?.toTokens()
        .removeZeroes()
        .formatValue();

    final dataValue = transactionWithData.data
        ?.maybeWhen(
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
        )
        ?.toTokens()
        .removeZeroes()
        .formatValue();

    final value = dataValue ?? msgValue;

    final address = isOutgoing ? recipient : sender;

    final date = transactionWithData.transaction.createdAt.toDateTime();

    final fees = transactionWithData.transaction.totalFees.toTokens().removeZeroes().formatValue();

    return InkWell(
      onTap: () => showTonWalletTransactionInfo(
        context: context,
        transactionWithData: transactionWithData,
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
                        child: value != null
                            ? valueTitle(
                                value: value,
                                isOutgoing: isOutgoing,
                              )
                            : const SizedBox(),
                      ),
                      iconForward(),
                    ],
                  ),
                  const SizedBox(height: 4),
                  feesTitle(fees),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: address != null ? addressTitle(address) : const SizedBox(),
                      ),
                      dateTitle(date),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget valueTitle({
    required String value,
    required bool isOutgoing,
  }) =>
      Text(
        '${isOutgoing ? '-' : ''}$value TON',
        style: TextStyle(
          color: isOutgoing ? CrystalColor.error : CrystalColor.success,
          fontWeight: FontWeight.w600,
        ),
      );

  Widget iconForward() => const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 18,
        color: Colors.grey,
      );

  Widget feesTitle(String fees) => Text(
        'Fees: $fees TON',
        style: const TextStyle(
          color: Colors.black45,
        ),
      );

  Widget addressTitle(String address) => Text(
        address.ellipseAddress(),
      );

  Widget dateTitle(DateTime date) => Text(
        DateFormat('MMM d, H:mm').format(date),
      );
}
