import 'package:ever_wallet/application/common/constants.dart';
import 'package:ever_wallet/application/common/extensions.dart';
import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/application/common/widgets/ton_asset_icon.dart';
import 'package:ever_wallet/application/common/widgets/transaction_type_label.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/widgets/address_title.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/widgets/date_title.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/widgets/fees_title.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/widgets/icon_forward.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/widgets/value_title.dart';
import 'package:ever_wallet/application/main/wallet/modals/ton_wallet_multisig_expired_transaction_info/show_ton_wallet_multisig_expired_transaction_info.dart';
import 'package:ever_wallet/data/models/ton_wallet_multisig_expired_transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';

class TonWalletMultisigExpiredTransactionHolder extends StatelessWidget {
  final TonWalletMultisigExpiredTransaction transaction;

  const TonWalletMultisigExpiredTransactionHolder({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => showTonWalletMultisigExpiredTransactionInfo(
          context: context,
          transaction: transaction,
        ),
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
                          child: ValueTitle(
                            value: transaction.value.toTokens().removeZeroes().formatValue(),
                            currency: kEverTicker,
                            isOutgoing: transaction.isOutgoing,
                          ),
                        ),
                        const IconForward(),
                      ],
                    ),
                    const Gap(4),
                    FeesTitle(fees: transaction.fees.toTokens().removeZeroes().formatValue()),
                    const Gap(4),
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
                      text: AppLocalizations.of(context)!.expired,
                      color: CrystalColor.expired,
                    ),
                    const Gap(4),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
