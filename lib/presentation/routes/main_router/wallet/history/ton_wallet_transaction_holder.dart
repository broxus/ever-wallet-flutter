import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../domain/utils/transaction_time.dart';
import '../../../../design/design.dart';
import '../../../../design/widgets/custom_ink_well.dart';
import '../../../../design/widgets/ton_asset_icon.dart';
import '../modals/ton_wallet_transaction_info/show_ton_wallet_transaction_info.dart';

class TonWalletTransactionHolder extends StatelessWidget {
  final TonWalletTransactionWithData transactionWithData;

  const TonWalletTransactionHolder({
    Key? key,
    required this.transactionWithData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isOutgoing = transactionWithData.transaction.outMessages.isNotEmpty;
    final sender = transactionWithData.transaction.inMessage.src;
    final recipient = transactionWithData.transaction.outMessages.firstOrNull?.dst;
    final value = (isOutgoing
            ? transactionWithData.transaction.outMessages.first.value
            : transactionWithData.transaction.inMessage.value)
        .toTokens()
        .removeZeroes()
        .formatValue();
    final address = isOutgoing ? recipient : sender;
    final date = transactionWithData.transaction.createdAt.toDateTime();
    final fees = transactionWithData.transaction.totalFees.toTokens().removeZeroes().formatValue();

    return CustomInkWell(
      onTap: () => showTonWalletTransactionInfo(
        context: context,
        transactionWithData: transactionWithData,
      ),
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
                        child: valueTitle(
                          value: value,
                          isOutgoing: isOutgoing,
                        ),
                      ),
                      iconForward(),
                    ],
                  ),
                  const SizedBox(height: 4),
                  feesTitle(fees),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: address != null ? addressTitle(address) : const SizedBox(),
                      ),
                      dateTitle(date),
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
        '${isOutgoing ? '-' : ''}$value TON',
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

  Widget feesTitle(String fees) => Text(
        'Fees: $fees TON',
        style: const TextStyle(
          color: Colors.black45,
        ),
      );

  Widget addressTitle(String address) => Text(
        address.ellipseAddress(),
      );

  Widget dateTitle(DateTime date) => Text(
        DateFormat('MMM d, H:mm').format(date),
      );
}
