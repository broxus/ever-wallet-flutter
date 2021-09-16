import 'package:crystal/presentation/design/value_formatter.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../domain/models/wallet_transaction.dart';
import '../../../design/design.dart';
import '../modals/transaction_observer/transaction_observer.dart';

class WalletTransactionHolder extends StatelessWidget {
  final WalletTransaction transaction;
  Widget? icon;
  final String? data;

  WalletTransactionHolder({
    Key? key,
    required this.transaction,
    this.icon,
  })  : data = transaction.maybeMap(ordinary: (v) => v.data, orElse: () => null),
        super(key: key);

  @override
  Widget build(BuildContext context) => Material(
        color: CrystalColor.primary,
        child: CrystalInkWell(
          onTap: () => TransactionObserver.open(
            context: context,
            transaction: transaction,
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
    return Text(
      transaction.isOutgoing
          ? "${ValueFormatter().formatValue(transaction.value)} ${transaction.currency}"
          : "- ${ValueFormatter().formatValue(transaction.value)} ${transaction.currency}",
      softWrap: false,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: transaction.isOutgoing ? CrystalColor.success : CrystalColor.fontDark,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _getLayout() {
    return Row(
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
  }

  Widget _getFees() {
    return Text(
      "Fees: ${ValueFormatter().formatValue(transaction.totalFees)} ${transaction.feesCurrency}",
      style: const TextStyle(
        color: CrystalColor.fontSecondaryDark,
      ),
    );
  }

  Widget _getAddress() {
    return transaction.address != ""
        ? Column(
            children: [
              const CrystalDivider(
                height: 6,
              ),
              SizedBox(
                width: 100,
                child: ExtendedText(
                  transaction.address,
                  key: UniqueKey(),
                  maxLines: 1,
                  textAlign: TextAlign.start,
                  softWrap: false,
                  overflowWidget: TextOverflowWidget(
                    align: TextOverflowAlign.center,
                    position: TextOverflowPosition.middle,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.filled(
                        3,
                        const Padding(
                          padding: EdgeInsets.all(2),
                          child: CircleIcon(
                            color: CrystalColor.fontDark,
                            size: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  style: const TextStyle(
                    letterSpacing: 0.25,
                    color: CrystalColor.fontDark,
                  ),
                ),
              ),
            ],
          )
        : const SizedBox();
  }

  Widget _getDate() {
    return Text(
      DateFormat('MMM d, H:mm').format(transaction.createdAt).toString(),
      style: const TextStyle(
        color: CrystalColor.fontDark,
      ),
    );
  }

  Widget getStatusInfo() => transaction.map(
        ordinary: (_) => const SizedBox(),
        sent: (_) => getStatusContainer(
          color: CrystalColor.pending,
          status: LocaleKeys.wallet_history_modal_status_in_progress.tr(),
        ),
        expired: (_) => getStatusContainer(
          color: CrystalColor.error,
          status: LocaleKeys.wallet_history_modal_status_failed.tr(),
        ),
      );

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
