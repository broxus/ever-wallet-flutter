import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../../../../../domain/utils/explorer.dart';
import '../../../../../../../../../../domain/utils/transaction_data.dart';
import '../../../../../../../../../../domain/utils/transaction_time.dart';
import '../../../../../design/design.dart';
import '../../../../../design/utils.dart';
import '../../../../../design/widgets/crystal_bottom_sheet.dart';

class TokenWalletTransactionObserver extends StatefulWidget {
  final String currency;
  final int decimals;
  final Transaction transaction;
  final TokenWalletTransaction data;
  final Widget? icon;
  final String? sender;
  final String? recipient;
  final String value;

  TokenWalletTransactionObserver._({
    Key? key,
    required this.currency,
    required this.decimals,
    required this.transaction,
    required this.data,
    this.icon,
  })  : sender = data.maybeWhen(
          incomingTransfer: (tokenIncomingTransfer) => tokenIncomingTransfer.senderAddress,
          orElse: () => null,
        ),
        recipient = data.maybeWhen(
          outgoingTransfer: (tokenOutgoingTransfer) => tokenOutgoingTransfer.to.address,
          swapBack: (tokenSwapBack) => tokenSwapBack.callbackAddress,
          orElse: () => null,
        ),
        value = data.when(
          incomingTransfer: (tokenIncomingTransfer) => tokenIncomingTransfer.tokens,
          outgoingTransfer: (tokenOutgoingTransfer) => tokenOutgoingTransfer.tokens,
          swapBack: (tokenSwapBack) => tokenSwapBack.tokens,
          accept: (value) => value,
          transferBounced: (value) => value,
          swapBackBounced: (value) => value,
        ),
        super(key: key);

  static Future<void> open({
    required BuildContext context,
    required String currency,
    required int decimals,
    required Transaction transaction,
    required TokenWalletTransaction data,
    Widget? icon,
  }) =>
      showCrystalBottomSheet(
        context,
        expand: false,
        barrierColor: CrystalColor.modalBackground.withOpacity(0.7),
        title: LocaleKeys.transaction_observer_title.tr(),
        body: TokenWalletTransactionObserver._(
          currency: currency,
          decimals: decimals,
          transaction: transaction,
          data: data,
          icon: icon,
        ),
      );

  @override
  _TokenWalletTransactionObserverState createState() => _TokenWalletTransactionObserverState();
}

class _TokenWalletTransactionObserverState extends State<TokenWalletTransactionObserver> {
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOutgoing = widget.recipient != null;
    final address = isOutgoing ? widget.recipient : widget.sender;

    return SafeArea(
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
                      value: widget.transaction.createdAt.toDateTime().format(),
                    ),
                    const CrystalDivider(height: 16),
                    if (address != null)
                      InformationField(
                        title: isOutgoing ? LocaleKeys.fields_recipient.tr() : LocaleKeys.fields_sender.tr(),
                        value: address,
                      ),
                    const CrystalDivider(height: 16),
                    InformationField(
                      title: LocaleKeys.fields_hash_id.tr(),
                      value: widget.transaction.id.hash,
                    ),
                    const CrystalDivider(height: 16),
                    const Divider(height: 1, thickness: 1),
                    const CrystalDivider(height: 16),
                    InformationField(
                      title: LocaleKeys.fields_amount.tr(),
                      value: LocaleKeys.wallet_history_modal_holder_value.tr(
                        args: [
                          '${isOutgoing ? '- ' : ''}${formatValue(widget.value.toTokens(widget.decimals))}',
                          widget.currency,
                        ],
                      ),
                    ),
                    const CrystalDivider(height: 16),
                    InformationField(
                      title: LocaleKeys.fields_blockchain_fee.tr(),
                      value: LocaleKeys.wallet_history_modal_holder_fee.tr(
                        args: [
                          formatValue(widget.transaction.totalFees.toTokens()),
                          'TON',
                        ],
                      ),
                    ),
                    const CrystalDivider(height: 16),
                    if (widget.data.toComment() != null && (widget.data.toComment()?.isNotEmpty ?? false)) ...[
                      const Divider(height: 1, thickness: 1),
                      const CrystalDivider(height: 16),
                      InformationField(
                        title: LocaleKeys.fields_comment.tr(),
                        step: 8,
                        value: widget.data.toComment()!,
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ),
          const CrystalDivider(height: 8),
          CrystalButton(
            onTap: () => launch(getTransactionExplorerLink(widget.transaction.id.hash)),
            type: CrystalButtonType.outline,
            text: LocaleKeys.transaction_observer_open_explorer.tr(),
          ),
        ],
      ),
    );
  }
}
