import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../domain/utils/transaction_time.dart';
import '../../../../design/design.dart';
import '../../../../design/widgets/custom_ink_well.dart';
import '../modals/token_wallet_transaction_info/show_token_wallet_transaction_info.dart';

class TokenWalletTransactionHolder extends StatelessWidget {
  final TokenWalletTransactionWithData transaction;
  final String currency;
  final int decimals;
  final Widget icon;

  const TokenWalletTransactionHolder({
    Key? key,
    required this.transaction,
    required this.currency,
    required this.decimals,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sender = transaction.data!.maybeWhen(
      incomingTransfer: (tokenIncomingTransfer) => tokenIncomingTransfer.senderAddress,
      orElse: () => null,
    );
    final recipient = transaction.data!.maybeWhen(
      outgoingTransfer: (tokenOutgoingTransfer) => tokenOutgoingTransfer.to.address,
      orElse: () => null,
    );
    final value = transaction.data!.when(
      incomingTransfer: (tokenIncomingTransfer) => tokenIncomingTransfer.tokens,
      outgoingTransfer: (tokenOutgoingTransfer) => tokenOutgoingTransfer.tokens,
      swapBack: (tokenSwapBack) => tokenSwapBack.tokens,
      accept: (value) => value,
      transferBounced: (value) => value,
      swapBackBounced: (value) => value,
    );
    final isOutgoing = recipient != null;
    final address = isOutgoing ? recipient : sender;

    return CustomInkWell(
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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: valueTitle(
                          value: value,
                          isOutgoing: isOutgoing,
                        ),
                      ),
                      iconForward(),
                    ],
                  ),
                  const SizedBox(height: 4),
                  fees(),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: address != null ? addressTitle(address) : const SizedBox(),
                      ),
                      date(),
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

  Widget valueTitle({
    required String value,
    required bool isOutgoing,
  }) =>
      Text(
        isOutgoing
            ? '-${value.toTokens(decimals).removeZeroes().formatValue()} $currency'
            : '${value.toTokens(decimals).removeZeroes().formatValue()} $currency',
        style: TextStyle(
          color: isOutgoing ? CrystalColor.error : CrystalColor.success,
          fontWeight: FontWeight.w600,
        ),
      );

  Widget iconForward() => const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 18,
        color: Colors.grey,
      );

  Widget fees() => Text(
        'Fees: ~${transaction.transaction.totalFees.toTokens().removeZeroes().formatValue()} TON',
        style: const TextStyle(
          color: Colors.black45,
        ),
      );

  Widget addressTitle(String address) => Text(
        address.ellipseAddress(),
      );

  Widget date() => Text(
        DateFormat('MMM d, H:mm').format(transaction.transaction.createdAt.toDateTime()),
      );
}
