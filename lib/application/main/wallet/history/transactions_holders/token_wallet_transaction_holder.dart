import 'package:collection/collection.dart';
import 'package:ever_wallet/application/common/extensions.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/widgets/address_title.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/widgets/date_title.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/widgets/fees_title.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/widgets/icon_forward.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/widgets/value_title.dart';
import 'package:ever_wallet/application/main/wallet/modals/token_wallet_transaction_info/show_token_wallet_transaction_info.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

class TokenWalletTransactionHolder extends StatelessWidget {
  final TokenWalletTransactionWithData transactionWithData;
  final String currency;
  final int decimals;
  final Widget icon;

  const TokenWalletTransactionHolder({
    Key? key,
    required this.transactionWithData,
    required this.currency,
    required this.decimals,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sender = transactionWithData.data!.maybeWhen(
          incomingTransfer: (tokenIncomingTransfer) => tokenIncomingTransfer.senderAddress,
          orElse: () => null,
        ) ??
        transactionWithData.transaction.inMessage.src;

    final recipient = transactionWithData.data!.maybeWhen(
          outgoingTransfer: (tokenOutgoingTransfer) => tokenOutgoingTransfer.to.data,
          orElse: () => null,
        ) ??
        transactionWithData.transaction.outMessages.firstOrNull?.dst;

    final value = transactionWithData.data!.when(
      incomingTransfer: (tokenIncomingTransfer) => tokenIncomingTransfer.tokens,
      outgoingTransfer: (tokenOutgoingTransfer) => tokenOutgoingTransfer.tokens,
      swapBack: (tokenSwapBack) => tokenSwapBack.tokens,
      accept: (value) => value,
      transferBounced: (value) => value,
      swapBackBounced: (value) => value,
    );

    final isOutgoing = transactionWithData.data!.when(
      incomingTransfer: (tokenIncomingTransfer) => false,
      outgoingTransfer: (tokenOutgoingTransfer) => true,
      swapBack: (tokenSwapBack) => true,
      accept: (value) => false,
      transferBounced: (value) => false,
      swapBackBounced: (value) => false,
    );

    final address = isOutgoing ? recipient : sender;

    final date = transactionWithData.transaction.createdAt.toDateTime();

    final fees = transactionWithData.transaction.totalFees;

    return InkWell(
      onTap: () => showTokenWalletTransactionInfo(
        context: context,
        transactionWithData: transactionWithData,
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
                          value: value.toTokens(decimals).removeZeroes().formatValue(),
                          currency: currency,
                          isOutgoing: isOutgoing,
                        ),
                      ),
                      const IconForward(),
                    ],
                  ),
                  const Gap(4),
                  FeesTitle(fees: fees.toTokens().removeZeroes().formatValue()),
                  const Gap(4),
                  Row(
                    children: [
                      Expanded(
                        child: address != null ? AddressTitle(address: address) : const SizedBox(),
                      ),
                      DateTitle(date: date),
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
}
