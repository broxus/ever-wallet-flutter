import 'package:ever_wallet/application/common/constants.dart';
import 'package:ever_wallet/application/common/extensions.dart';
import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/application/common/widgets/ton_asset_icon.dart';
import 'package:ever_wallet/application/common/widgets/transaction_type_label.dart';
import 'package:ever_wallet/application/common/widgets/transport_type_builder.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/widgets/address_title.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/widgets/confirmation_time_counter.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/widgets/confirms_title.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/widgets/date_title.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/widgets/fees_title.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/widgets/icon_forward.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/widgets/value_title.dart';
import 'package:ever_wallet/application/main/wallet/modals/ton_wallet_multisig_pending_transaction_info/show_ton_wallet_multisig_pending_transaction_info.dart';
import 'package:ever_wallet/data/models/ton_wallet_multisig_pending_transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';

class TonWalletMultisigPendingTransactionHolder extends StatelessWidget {
  final TonWalletMultisigPendingTransaction transaction;

  const TonWalletMultisigPendingTransactionHolder({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => showTonWalletMultisigPendingTransactionInfo(
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
                          child: TransportTypeBuilderWidget(
                            builder: (context, isEver) {
                              return ValueTitle(
                                value: transaction.value.toTokens().removeZeroes().formatValue(),
                                currency: isEver ? kEverTicker : kVenomTicker,
                                isOutgoing: transaction.isOutgoing,
                              );
                            },
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
                      text: AppLocalizations.of(context)!.waiting_for_confirmation,
                      color: CrystalColor.error,
                    ),
                    const Gap(4),
                    ConfirmsTitle(
                      signsReceived: transaction.signsReceived,
                      signsRequired: transaction.signsRequired,
                    ),
                    const Gap(4),
                    ConfirmationTimeCounter(
                      expireAt: transaction.expireAt,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
