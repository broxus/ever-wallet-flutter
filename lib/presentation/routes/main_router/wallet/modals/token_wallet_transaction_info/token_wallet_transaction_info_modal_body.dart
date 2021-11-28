import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../domain/utils/explorer.dart';
import '../../../../../../domain/utils/transaction_time.dart';
import '../../../../../design/design.dart';
import '../../../../../design/widgets/crystal_title.dart';
import '../../../../../design/widgets/custom_close_button.dart';
import '../../../../../design/widgets/custom_outlined_button.dart';

class TokenWalletTransactionInfoModalBody extends StatefulWidget {
  final TokenWalletTransactionWithData transaction;
  final String currency;
  final int decimals;

  const TokenWalletTransactionInfoModalBody({
    Key? key,
    required this.transaction,
    required this.currency,
    required this.decimals,
  }) : super(key: key);

  @override
  _TonAssetInfoModalBodyState createState() => _TonAssetInfoModalBodyState();
}

class _TonAssetInfoModalBodyState extends State<TokenWalletTransactionInfoModalBody> {
  @override
  Widget build(BuildContext context) {
    final sender = widget.transaction.data!.maybeWhen(
      incomingTransfer: (tokenIncomingTransfer) => tokenIncomingTransfer.senderAddress,
      orElse: () => null,
    );
    final recipient = widget.transaction.data!.maybeWhen(
      outgoingTransfer: (tokenOutgoingTransfer) => tokenOutgoingTransfer.to.address,
      orElse: () => null,
    );
    final value = widget.transaction.data!.when(
      incomingTransfer: (tokenIncomingTransfer) => tokenIncomingTransfer.tokens,
      outgoingTransfer: (tokenOutgoingTransfer) => tokenOutgoingTransfer.tokens,
      swapBack: (tokenSwapBack) => tokenSwapBack.tokens,
      accept: (value) => value,
      transferBounced: (value) => value,
      swapBackBounced: (value) => value,
    );
    final type = widget.transaction.data!.when(
      incomingTransfer: (tokenIncomingTransfer) => 'Token incoming transfer',
      outgoingTransfer: (tokenOutgoingTransfer) => 'Token outgoing transfer',
      swapBack: (tokenSwapBack) => 'Swap back',
      accept: (value) => 'Accept',
      transferBounced: (value) => 'Transfer bounced',
      swapBackBounced: (value) => 'Swap back bounced',
    );
    final isOutgoing = recipient != null;
    final address = isOutgoing ? (recipient ?? sender) : (sender ?? recipient);

    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: title(),
                    ),
                    const CustomCloseButton(),
                  ],
                ),
                const SizedBox(height: 16),
                dateSection(),
                const SizedBox(height: 16),
                if (address != null) ...[
                  addressSection(
                    isOutgoing: isOutgoing,
                    address: address,
                  ),
                  const SizedBox(height: 16),
                ],
                hashSection(),
                const Divider(
                  height: 32,
                  thickness: 1,
                ),
                amountSection(
                  isOutgoing: isOutgoing,
                  value: value,
                ),
                const SizedBox(height: 16),
                feeSection(),
                const Divider(
                  height: 32,
                  thickness: 1,
                ),
                typeSection(type),
                const SizedBox(height: 32),
                explorerButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget dateSection() => section(
        title: 'Date and time',
        subtitle: DateFormat('dd.MM.yyyy, H:mm').format(
          widget.transaction.transaction.createdAt.toDateTime(),
        ),
      );

  Widget addressSection({
    required bool isOutgoing,
    required String address,
  }) =>
      section(
        title: isOutgoing ? 'Recipient' : 'Sender',
        subtitle: address,
        isSelectable: true,
      );

  Widget hashSection() => section(
        title: 'Hash (ID)',
        subtitle: widget.transaction.transaction.id.hash,
        isSelectable: true,
      );

  Widget amountSection({
    required bool isOutgoing,
    required String value,
  }) =>
      section(
        title: 'Amount',
        subtitle: isOutgoing
            ? '-${value.toTokens(widget.decimals).removeZeroes().formatValue()} ${widget.currency}'
            : '${value.toTokens(widget.decimals).removeZeroes().formatValue()} ${widget.currency}',
      );

  Widget feeSection() => section(
        title: 'Blockchain fee',
        subtitle: '~${widget.transaction.transaction.totalFees.toTokens().removeZeroes().formatValue()} TON',
      );

  Widget typeSection(String type) => section(
        title: 'Type',
        subtitle: type,
      );

  Widget title() => const CrystalTitle(
        text: 'Transaction information',
      );

  Widget section({
    required String title,
    required String subtitle,
    bool isSelectable = false,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          if (isSelectable)
            SelectableText(
              subtitle,
              style: const TextStyle(
                fontSize: 16,
              ),
            )
          else
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
        ],
      );

  Widget explorerButton() => CustomOutlinedButton(
        onPressed: () => launch(getTransactionExplorerLink(widget.transaction.transaction.id.hash)),
        text: 'See in explorer',
      );
}
