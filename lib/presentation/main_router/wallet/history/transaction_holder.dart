import 'package:extended_text/extended_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../domain/models/wallet_transaction.dart';
import '../../../design/design.dart';
import '../modals/transaction_observer/transaction_observer.dart';

class WalletTransactionHolder extends StatelessWidget {
  final WalletTransaction transaction;
  final Widget icon;
  final String? data;

  WalletTransactionHolder({
    Key? key,
    required this.transaction,
    required this.icon,
  })  : data = transaction.maybeMap(ordinary: (v) => v.data, orElse: () => null),
        super(key: key);

  @override
  Widget build(BuildContext context) => Material(
        type: MaterialType.card,
        color: CrystalColor.primary,
        child: CrystalInkWell(
          onTap: () => TransactionObserver.open(
            context: context,
            transaction: transaction,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: icon,
                    ),
                    const CrystalDivider(width: 16),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: IntrinsicWidth(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 20,
                                width: MediaQuery.of(context).size.width * 0.35,
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
                                    fontSize: 16,
                                    letterSpacing: 0.25,
                                    color: CrystalColor.fontDark,
                                  ),
                                ),
                              ),
                              const CrystalDivider(height: 4),
                              SizedBox(
                                height: 20,
                                child: Text(
                                  transaction.createdAt.format(),
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    letterSpacing: 0.75,
                                    color: CrystalColor.fontSecondaryDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(
                            height: 20,
                            child: Text(
                              transaction.isOutgoing
                                  ? '- ${transaction.value.floorValue().elipseValue()}'
                                  : '+ ${transaction.value.floorValue().elipseValue()}',
                              style: TextStyle(
                                fontSize: 16,
                                color: transaction.isOutgoing ? CrystalColor.error : CrystalColor.success,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                            ),
                          ),
                          const CrystalDivider(height: 4),
                          SizedBox(
                            height: 20,
                            child: Text(
                              LocaleKeys.wallet_history_modal_holder_fee.tr(
                                args: [
                                  transaction.totalFees,
                                  transaction.feesCurrency,
                                ],
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                letterSpacing: 0.75,
                                color: CrystalColor.fontSecondaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (data != null && data!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 10,
                    ),
                    child: Text(
                      data!,
                      style: const TextStyle(
                        color: CrystalColor.fontDark,
                        letterSpacing: 0.75,
                      ),
                    ),
                  ),
                getStatusInfo(),
              ],
            ),
          ),
        ),
      );

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
