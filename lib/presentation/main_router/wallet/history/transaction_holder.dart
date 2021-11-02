import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../domain/models/wallet_transaction.dart';
import '../../../design/design.dart';
import '../../../design/utils.dart';
import '../modals/transaction_observer/transaction_observer.dart';

class WalletTransactionHolder extends StatelessWidget {
  final WalletTransaction transaction;
  final Widget? icon;

  const WalletTransactionHolder({
    Key? key,
    required this.transaction,
    this.icon,
  }) : super(key: key);

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
          ? "- ${formatValue(transaction.value)} ${transaction.currency}"
          : "${formatValue(transaction.value)} ${transaction.currency}",
      softWrap: false,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: transaction.isOutgoing ? CrystalColor.error : CrystalColor.success,
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
      "Fees: ${formatValue(transaction.totalFees)} ${transaction.feesCurrency}",
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
                child: Text(
                  transaction.address.elipseAddress(),
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
