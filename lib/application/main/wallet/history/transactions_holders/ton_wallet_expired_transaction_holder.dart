import 'package:ever_wallet/application/common/extensions.dart';
import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/application/common/widgets/ton_asset_icon.dart';
import 'package:ever_wallet/application/common/widgets/transaction_type_label.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/widgets/address_title.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/widgets/date_title.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/widgets/expire_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

class TonWalletExpiredTransactionHolder extends StatelessWidget {
  final PendingTransaction pendingTransaction;
  final String walletAddress;

  const TonWalletExpiredTransactionHolder({
    Key? key,
    required this.pendingTransaction,
    required this.walletAddress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final expireAt = pendingTransaction.expireAt.toDateTime();

    final address = pendingTransaction.src ?? walletAddress;

    final date = expireAt;

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
                        child: AddressTitle(address: address),
                      ),
                      DateTitle(date: date),
                    ],
                  ),
                  const Gap(4),
                  TransactionTypeLabel(
                    text: AppLocalizations.of(context)!.expired,
                    color: CrystalColor.expired,
                  ),
                  const Gap(4),
                  ExpireTitle(
                    date: expireAt,
                    expired: true,
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
