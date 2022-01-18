import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../design/design.dart';
import '../../../../../design/transaction_time.dart';
import '../../../../../design/widgets/ton_asset_icon.dart';
import '../../../../../design/widgets/transaction_type_label.dart';
import 'widgets/address_title.dart';
import 'widgets/date_title.dart';
import 'widgets/expire_title.dart';
import 'widgets/fees_title.dart';
import 'widgets/value_title.dart';

class TonWalletSentTransactionHolder extends StatelessWidget {
  final PendingTransaction pendingTransaction;
  final Transaction? transaction;
  final String walletAddress;

  const TonWalletSentTransactionHolder({
    Key? key,
    required this.pendingTransaction,
    this.transaction,
    required this.walletAddress,
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

    final address = (isOutgoing ? recipient : sender) ?? walletAddress;

    final date = transaction?.createdAt.toDateTime() ?? DateTime.now();

    final fees = transaction?.totalFees.toTokens().removeZeroes().formatValue();

    return InkWell(
      onTap: () => {},
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
                  if (value != null) ...[
                    ValueTitle(
                      value: value,
                      currency: 'EVER',
                      isOutgoing: isOutgoing,
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (fees != null) ...[
                    FeesTitle(fees: fees),
                    const SizedBox(height: 4),
                  ],
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
                    text: 'Transaction in progress',
                    color: CrystalColor.pending,
                  ),
                  const SizedBox(height: 4),
                  ExpireTitle(
                    date: expireAt,
                    expired: false,
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
