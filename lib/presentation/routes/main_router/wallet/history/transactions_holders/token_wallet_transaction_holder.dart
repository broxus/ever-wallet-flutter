import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../design/design.dart';
import '../../../../../design/transaction_time.dart';
import '../../modals/token_wallet_transaction_info/show_token_wallet_transaction_info.dart';
import 'widgets/address_title.dart';
import 'widgets/date_title.dart';
import 'widgets/fees_title.dart';
import 'widgets/icon_forward.dart';
import 'widgets/value_title.dart';

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
          outgoingTransfer: (tokenOutgoingTransfer) => tokenOutgoingTransfer.to.address,
          orElse: () => null,
        ) ??
        transactionWithData.transaction.outMessages.firstOrNull?.dst;

    final value = transactionWithData.data!
        .when(
          incomingTransfer: (tokenIncomingTransfer) => tokenIncomingTransfer.tokens,
          outgoingTransfer: (tokenOutgoingTransfer) => tokenOutgoingTransfer.tokens,
          swapBack: (tokenSwapBack) => tokenSwapBack.tokens,
          accept: (value) => value,
          transferBounced: (value) => value,
          swapBackBounced: (value) => value,
        )
        .toTokens(decimals)
        .removeZeroes()
        .formatValue();

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

    final fees = transactionWithData.transaction.totalFees.toTokens().removeZeroes().formatValue();

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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ValueTitle(
                          value: value,
                          currency: currency,
                          isOutgoing: isOutgoing,
                        ),
                      ),
                      const IconForward(),
                    ],
                  ),
                  const SizedBox(height: 4),
                  FeesTitle(fees: fees),
                  const SizedBox(height: 4),
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
