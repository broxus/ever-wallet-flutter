import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../domain/models/wallet_transaction.dart';
import '../../../../../domain/utils/explorer.dart';
import '../../../../design/design.dart';
import '../../../../design/utils.dart';
import '../../../../design/widget/crystal_bottom_sheet.dart';

class TransactionObserver extends StatefulWidget {
  final WalletTransaction transaction;

  const TransactionObserver._({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  static Future<void> open({
    required BuildContext context,
    required WalletTransaction transaction,
  }) =>
      showCrystalBottomSheet(
        context,
        expand: false,
        barrierColor: CrystalColor.modalBackground.withOpacity(0.7),
        title: LocaleKeys.transaction_observer_title.tr(),
        body: TransactionObserver._(
          transaction: transaction,
        ),
      );

  @override
  _TransactionObserverState createState() => _TransactionObserverState();
}

class _TransactionObserverState extends State<TransactionObserver> {
  final scrollController = ScrollController();
  late final String? data;

  @override
  void initState() {
    super.initState();
    data = widget.transaction.maybeMap(ordinary: (v) => v.data, orElse: () => null);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: FadingEdgeScrollView.fromSingleChildScrollView(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InformationField(
                        title: LocaleKeys.fields_date_time.tr(),
                        value: widget.transaction.createdAt.format(),
                      ),
                      const CrystalDivider(height: 16),
                      InformationField(
                        title: widget.transaction.isOutgoing
                            ? LocaleKeys.fields_recipient.tr()
                            : LocaleKeys.fields_sender.tr(),
                        value: widget.transaction.address,
                      ),
                      const CrystalDivider(height: 16),
                      InformationField(
                        title: LocaleKeys.fields_hash_id.tr(),
                        value: widget.transaction.hash,
                      ),
                      const CrystalDivider(height: 16),
                      const Divider(height: 1, thickness: 1),
                      const CrystalDivider(height: 16),
                      InformationField(
                        title: LocaleKeys.fields_amount.tr(),
                        value: LocaleKeys.wallet_history_modal_holder_value.tr(
                          args: [
                            formatValue(widget.transaction.value),
                            widget.transaction.currency,
                          ],
                        ),
                      ),
                      const CrystalDivider(height: 16),
                      InformationField(
                        title: LocaleKeys.fields_blockchain_fee.tr(),
                        value: LocaleKeys.wallet_history_modal_holder_fee.tr(
                          args: [
                            formatValue(widget.transaction.totalFees),
                            widget.transaction.feesCurrency,
                          ],
                        ),
                      ),
                      const CrystalDivider(height: 16),
                      const Divider(height: 1, thickness: 1),
                      const CrystalDivider(height: 16),
                      if (data?.isNotEmpty ?? false)
                        InformationField(
                          title: LocaleKeys.fields_comment.tr(),
                          step: 8,
                          value: data!,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const CrystalDivider(height: 8),
            CrystalButton(
              onTap: () => launch(getTransactionExplorerLink(widget.transaction.hash)),
              type: CrystalButtonType.outline,
              text: LocaleKeys.transaction_observer_open_explorer.tr(),
            ),
          ],
        ),
      );
}
