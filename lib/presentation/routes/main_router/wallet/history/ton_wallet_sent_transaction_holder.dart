import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../design/design.dart';
import '../../../../design/transaction_time.dart';
import '../../../../design/widgets/ton_asset_icon.dart';
import '../../../../design/widgets/transaction_type_label.dart';

class TonWalletSentTransactionHolder extends StatelessWidget {
  final PendingTransaction pendingTransaction;
  final Transaction? transaction;

  const TonWalletSentTransactionHolder({
    Key? key,
    required this.pendingTransaction,
    this.transaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final expireAt = pendingTransaction.expireAt.toDateTime();
    final isOutgoing = transaction?.outMessages.isNotEmpty ?? true;
    final sender = transaction?.inMessage.src;
    final recipient = transaction?.outMessages.firstOrNull?.dst;
    final value = (isOutgoing ? transaction?.outMessages.first.value : transaction?.inMessage.value)
        ?.toTokens()
        .removeZeroes()
        .formatValue();
    final address = isOutgoing ? recipient : sender;
    final date = transaction?.createdAt.toDateTime();
    final fees = transaction?.totalFees.toTokens().removeZeroes().formatValue();

    return InkWell(
      onTap: () => {},
      // showTonWalletTransactionInfo(
      //   context:  context,
      //   transactionWithData: transactionWithData,
      // ),
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
                  if (transaction != null)
                    Row(
                      children: [
                        Expanded(
                          child: value != null ? valueTitle(value) : const SizedBox(),
                        ),
                        iconForward(),
                      ],
                    ),
                  if (fees != null) ...[
                    const SizedBox(height: 4),
                    feesTitle(fees),
                    const SizedBox(height: 4),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: address != null ? addressTitle(address) : const SizedBox(),
                      ),
                      if (date != null) dateTitle(date),
                    ],
                  ),
                  const SizedBox(height: 4),
                  label(),
                  const SizedBox(height: 4),
                  expireTitle(expireAt),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget valueTitle(String value) => Text(
        '-$value TON',
        style: const TextStyle(
          color: CrystalColor.error,
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

  Widget label() => const TransactionTypeLabel(
        text: 'Transaction in progress',
        color: CrystalColor.pending,
      );

  Widget expireTitle(DateTime date) => Text(
        'Expires at ${DateFormat('MMM d, H:mm').format(date)}',
        style: const TextStyle(
          color: Colors.black45,
        ),
      );
}
