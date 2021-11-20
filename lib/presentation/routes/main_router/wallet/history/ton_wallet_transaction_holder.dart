import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../domain/models/transaction_type.dart';
import '../../../../../../../../domain/utils/transaction_time.dart';
import '../../../../design/design.dart';
import '../../../../design/utils.dart';
import '../modals/transaction_observer/ton_wallet_transaction_observer.dart';

class TonWalletTransactionHolder extends StatelessWidget {
  final String currency;
  final TransactionType transactionType;
  final Transaction transaction;
  final TransactionAdditionalInfo? data;
  final Widget? icon;
  final bool isOutgoing;
  final String? address;
  final String value;

  TonWalletTransactionHolder({
    Key? key,
    required this.currency,
    required this.transactionType,
    required this.transaction,
    this.data,
    this.icon,
  })  : isOutgoing = transaction.outMessages.isNotEmpty,
        address = transaction.outMessages.isNotEmpty ? transaction.outMessages.first.dst : transaction.inMessage.src,
        value = transaction.outMessages.isNotEmpty ? transaction.outMessages.first.value : transaction.inMessage.value,
        super(key: key);

  @override
  Widget build(BuildContext context) => Material(
        color: CrystalColor.primary,
        child: CrystalInkWell(
          onTap: () => TonWalletTransactionObserver.open(
            context: context,
            currency: currency,
            transactionType: transactionType,
            transaction: transaction,
            data: data,
            icon: icon,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (icon != null)
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: icon,
                  )
                else
                  const SizedBox(),
                const CrystalDivider(
                  width: 16,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: IntrinsicWidth(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _getValueTitle(),
                          const CrystalDivider(
                            height: 2,
                          ),
                          _getLayout(),
                          const CrystalDivider(
                            height: 4,
                          ),
                          getStatusInfo(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _getValueTitle() {
    final formattedValue = value.toTokens();

    return Text(
      isOutgoing ? '- ${formatValue(formattedValue)} $currency' : '${formatValue(formattedValue)} $currency',
      softWrap: false,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: isOutgoing ? CrystalColor.error : CrystalColor.success,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _getLayout() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _getFees(),
              _getAddress(),
            ],
          ),
          _getDate(),
        ],
      );

  Widget _getFees() => Text(
        'Fees: ${formatValue(transaction.totalFees.toTokens())} TON',
        style: const TextStyle(
          color: CrystalColor.fontSecondaryDark,
        ),
      );

  Widget _getAddress() => address != null && address!.isNotEmpty
      ? Column(
          children: [
            const CrystalDivider(
              height: 6,
            ),
            SizedBox(
              width: 100,
              child: Text(
                address!.ellipseAddress(),
                maxLines: 1,
                textAlign: TextAlign.start,
                softWrap: false,
                style: const TextStyle(
                  letterSpacing: 0.25,
                  color: CrystalColor.fontDark,
                ),
              ),
            ),
          ],
        )
      : const SizedBox();

  Widget _getDate() => Text(
        DateFormat('MMM d, H:mm').format(transaction.createdAt.toDateTime()).toString(),
        style: const TextStyle(
          color: CrystalColor.fontDark,
        ),
      );

  Widget getStatusInfo() {
    switch (transactionType) {
      case TransactionType.ordinary:
        return const SizedBox();
      case TransactionType.sent:
        return getStatusContainer(
          color: CrystalColor.pending,
          status: LocaleKeys.wallet_history_modal_status_in_progress.tr(),
        );
      case TransactionType.expired:
        return getStatusContainer(
          color: CrystalColor.error,
          status: LocaleKeys.wallet_history_modal_status_failed.tr(),
        );
    }
  }

  Widget getStatusContainer({
    required String status,
    required Color color,
  }) =>
      Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 10,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: color,
                  letterSpacing: 0.75,
                ),
              ),
            ),
          ),
        ],
      );
}
