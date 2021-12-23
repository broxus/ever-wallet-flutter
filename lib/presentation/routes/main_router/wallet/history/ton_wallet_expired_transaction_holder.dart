import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../design/design.dart';
import '../../../../design/transaction_time.dart';
import '../../../../design/widgets/ton_asset_icon.dart';
import '../../../../design/widgets/transaction_type_label.dart';

class TonWalletExpiredTransactionHolder extends StatelessWidget {
  final PendingTransaction pendingTransaction;

  const TonWalletExpiredTransactionHolder({
    Key? key,
    required this.pendingTransaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final expireAt = pendingTransaction.expireAt.toDateTime();

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

  Widget label() => const TransactionTypeLabel(
        text: 'Transaction expired',
        color: CrystalColor.error,
      );

  Widget expireTitle(DateTime date) => Text(
        'Expired at ${DateFormat('MMM d, H:mm').format(date)}',
        style: const TextStyle(
          color: Colors.black45,
        ),
      );
}
