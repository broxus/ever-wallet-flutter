import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/application/common/widgets/ton_asset_icon.dart';
import 'package:ever_wallet/application/common/widgets/transaction_type_label.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/widgets/address_title.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/widgets/date_title.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/widgets/expire_title.dart';
import 'package:ever_wallet/data/models/ton_wallet_pending_transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';

class TonWalletPendingTransactionHolder extends StatelessWidget {
  final TonWalletPendingTransaction transaction;

  const TonWalletPendingTransactionHolder({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => {},
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const TonAssetIcon(),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AddressTitle(address: transaction.address),
                      ),
                      DateTitle(date: transaction.date),
                    ],
                  ),
                  const Gap(4),
                  TransactionTypeLabel(
                    text: AppLocalizations.of(context)!.in_progress,
                    color: CrystalColor.pending,
                  ),
                  const Gap(4),
                  ExpireTitle(
                    date: transaction.expireAt,
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
