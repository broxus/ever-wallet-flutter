import 'package:ever_wallet/application/common/constants.dart';
import 'package:ever_wallet/application/common/extensions.dart';
import 'package:ever_wallet/application/common/widgets/ton_asset_icon.dart';
import 'package:ever_wallet/application/common/widgets/transport_type_builder.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/widgets/address_title.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/widgets/date_title.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/widgets/fees_title.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/widgets/icon_forward.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/widgets/value_title.dart';
import 'package:ever_wallet/application/main/wallet/modals/ton_wallet_multisig_transaction_info/show_ton_wallet_multisig_transaction_info.dart';
import 'package:ever_wallet/data/models/ton_wallet_multisig_ordinary_transaction.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class TonWalletMultisigTransactionHolder extends StatelessWidget {
  final TonWalletMultisigOrdinaryTransaction transaction;

  const TonWalletMultisigTransactionHolder({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => showTonWalletMultisigTransactionInfo(
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
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
