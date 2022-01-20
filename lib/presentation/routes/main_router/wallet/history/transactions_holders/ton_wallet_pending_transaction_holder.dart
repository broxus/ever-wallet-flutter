import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../design/design.dart';
import '../../../../../design/transaction_time.dart';
import '../../../../../design/widgets/ton_asset_icon.dart';
import '../../../../../design/widgets/transaction_type_label.dart';
import 'widgets/address_title.dart';
import 'widgets/date_title.dart';
import 'widgets/expire_title.dart';

class TonWalletPendingTransactionHolder extends StatelessWidget {
  final PendingTransaction pendingTransaction;
  final String walletAddress;

  const TonWalletPendingTransactionHolder({
    Key? key,
    required this.pendingTransaction,
    required this.walletAddress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final expireAt = pendingTransaction.expireAt.toDateTime();

    final address = walletAddress;

    final date = DateTime.now();

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
                    text: 'In progress',
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
