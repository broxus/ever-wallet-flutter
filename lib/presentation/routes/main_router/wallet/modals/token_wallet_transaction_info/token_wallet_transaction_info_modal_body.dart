import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../design/design.dart';
import '../../../../../design/explorer.dart';
import '../../../../../design/transaction_time.dart';
import '../../../../../design/widgets/custom_outlined_button.dart';
import '../../../../../design/widgets/modal_header.dart';

class TokenWalletTransactionInfoModalBody extends StatelessWidget {
  final TokenWalletTransactionWithData transactionWithData;
  final String currency;
  final int decimals;

  const TokenWalletTransactionInfoModalBody({
    Key? key,
    required this.transactionWithData,
    required this.currency,
    required this.decimals,
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

    final hash = transactionWithData.transaction.id.hash;

    final type = transactionWithData.data!.when(
      incomingTransfer: (tokenIncomingTransfer) => 'Token incoming transfer',
      outgoingTransfer: (tokenOutgoingTransfer) => 'Token outgoing transfer',
      swapBack: (tokenSwapBack) => 'Swap back',
      accept: (value) => 'Accept',
      transferBounced: (value) => 'Transfer bounced',
      swapBackBounced: (value) => 'Swap back bounced',
    );

    final sections = [
      section(
        [
          dateItem(date),
          if (address != null) ...[
            addressItem(
              isOutgoing: isOutgoing,
              address: address,
            ),
          ],
          hashItem(hash),
        ],
      ),
      section(
        [
          amountItem(
            isOutgoing: isOutgoing,
            value: value,
          ),
          feeItem(fees),
        ],
      ),
      section(
        [
          typeItem(type),
        ],
      ),
    ];

    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const ModalHeader(
                text: 'Transaction information',
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: list(sections),
                ),
              ),
              const SizedBox(height: 16),
              explorerButton(hash),
            ],
          ),
        ),
      ),
    );
  }

  Widget list(List<Widget> list) => ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => list[index],
        separatorBuilder: (context, index) => const Divider(
          height: 32,
          thickness: 1,
        ),
        itemCount: list.length,
      );

  Widget section(List<Widget> children) => ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => children[index],
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemCount: children.length,
      );

  Widget item({
    required String title,
    required String subtitle,
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
          SelectableText(
            subtitle,
            style: const TextStyle(
              fontSize: 16,
            ),
          )
        ],
      );

  Widget dateItem(DateTime date) => item(
        title: 'Date and time',
        subtitle: DateFormat('dd.MM.yyyy, H:mm').format(date),
      );

  Widget addressItem({
    required bool isOutgoing,
    required String address,
  }) =>
      item(
        title: isOutgoing ? 'Recipient' : 'Sender',
        subtitle: address,
      );

  Widget hashItem(String hash) => item(
        title: 'Hash (ID)',
        subtitle: hash,
      );

  Widget amountItem({
    required bool isOutgoing,
    required String value,
  }) =>
      item(
        title: 'Amount',
        subtitle: '${isOutgoing ? '-' : ''}$value $currency',
      );

  Widget feeItem(String fees) => item(
        title: 'Blockchain fee',
        subtitle: '$fees TON',
      );

  Widget typeItem(String type) => item(
        title: 'Type',
        subtitle: type,
      );

  Widget explorerButton(String hash) => CustomOutlinedButton(
        onPressed: () => launch(getTransactionExplorerLink(hash)),
        text: 'See in the explorer',
      );
}
