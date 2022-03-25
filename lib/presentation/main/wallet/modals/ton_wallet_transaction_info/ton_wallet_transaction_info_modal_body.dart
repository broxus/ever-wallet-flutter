import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../common/extensions.dart';
import '../../../../common/utils.dart';
import '../../../../common/widgets/custom_outlined_button.dart';
import '../../../../common/widgets/modal_header.dart';
import '../../../common/extensions.dart';

class TonWalletTransactionInfoModalBody extends StatelessWidget {
  final TonWalletTransactionWithData transactionWithData;

  const TonWalletTransactionInfoModalBody({
    Key? key,
    required this.transactionWithData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isOutgoing = transactionWithData.transaction.outMessages.isNotEmpty;

    final sender = transactionWithData.transaction.inMessage.src;

    final recipient = transactionWithData.transaction.outMessages.firstOrNull?.dst;

    final value = isOutgoing
        ? transactionWithData.transaction.outMessages.first.value
        : transactionWithData.transaction.inMessage.value;

    final address = isOutgoing ? recipient : sender;

    final date = transactionWithData.transaction.createdAt.toDateTime();

    final fees = transactionWithData.transaction.totalFees;

    final hash = transactionWithData.transaction.id.hash;

    final comment = transactionWithData.data?.maybeWhen(
      comment: (value) => value,
      orElse: () => null,
    );

    final dePoolOnRoundComplete = transactionWithData.data?.maybeWhen(
      dePoolOnRoundComplete: (notification) => notification.toRepresentableData(),
      orElse: () => null,
    );

    final dePoolReceiveAnswer = transactionWithData.data?.maybeWhen(
      dePoolReceiveAnswer: (notification) => notification.toRepresentableData(),
      orElse: () => null,
    );

    final tokenWalletDeployed = transactionWithData.data?.maybeWhen(
      tokenWalletDeployed: (notification) => notification.toRepresentableData(),
      orElse: () => null,
    );

    final walletInteraction = transactionWithData.data?.maybeWhen(
      walletInteraction: (info) => info.toRepresentableData(),
      orElse: () => null,
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
            value: value.toTokens().removeZeroes().formatValue(),
          ),
          feeItem(fees.toTokens().removeZeroes().formatValue()),
        ],
      ),
      if (comment != null && comment.isNotEmpty)
        section(
          [
            item(
              title: 'Comment',
              subtitle: comment,
            ),
          ],
        ),
      if (dePoolOnRoundComplete != null)
        section(
          [
            typeItem('DePool on round complete'),
            ...dePoolOnRoundComplete.entries
                .map(
                  (e) => item(
                    title: e.key,
                    subtitle: e.value,
                  ),
                )
                .toList(),
          ],
        ),
      if (dePoolReceiveAnswer != null)
        section(
          [
            typeItem('DePool receive answer'),
            ...dePoolReceiveAnswer.entries
                .map(
                  (e) => item(
                    title: e.key,
                    subtitle: e.value,
                  ),
                )
                .toList(),
          ],
        ),
      if (tokenWalletDeployed != null)
        section(
          [
            typeItem('Token wallet deployed'),
            ...tokenWalletDeployed.entries
                .map(
                  (e) => item(
                    title: e.key,
                    subtitle: e.value,
                  ),
                )
                .toList(),
          ],
        ),
      if (walletInteraction != null)
        section(
          [
            typeItem('Wallet interaction'),
            ...walletInteraction.entries
                .map(
                  (e) => item(
                    title: e.key,
                    subtitle: e.value,
                  ),
                )
                .toList(),
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
        subtitle: '${isOutgoing ? '-' : ''}$value EVER',
      );

  Widget feeItem(String fees) => item(
        title: 'Blockchain fee',
        subtitle: '$fees EVER',
      );

  Widget typeItem(String type) => item(
        title: 'Type',
        subtitle: type,
      );

  Widget explorerButton(String hash) => CustomOutlinedButton(
        onPressed: () => launch(transactionExplorerLink(hash)),
        text: 'See in the explorer',
      );
}
