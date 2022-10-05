import 'package:ever_wallet/application/common/extensions.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/widgets/address_title.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/widgets/date_title.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/widgets/fees_title.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/widgets/icon_forward.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/widgets/value_title.dart';
import 'package:ever_wallet/application/main/wallet/modals/token_wallet_transaction_info/show_token_wallet_transaction_info.dart';
import 'package:ever_wallet/data/models/token_wallet_ordinary_transaction.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class TokenWalletTransactionHolder extends StatelessWidget {
  final TokenWalletOrdinaryTransaction transaction;
  final String currency;
  final int decimals;
  final Widget icon;

  const TokenWalletTransactionHolder({
    super.key,
    required this.transaction,
    required this.currency,
    required this.decimals,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => showTokenWalletTransactionInfo(
          context: context,
          transaction: transaction,
          currency: currency,
          decimals: decimals,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              icon,
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ValueTitle(
                            value:
                                transaction.value.toTokens(decimals).removeZeroes().formatValue(),
                            currency: currency,
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
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
