import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../../generated/codegen_loader.g.dart';
import '../../../../common/constants.dart';
import '../../../../common/extensions.dart';
import '../../../../common/utils.dart';
import '../../../../common/widgets/custom_outlined_button.dart';
import '../../../../common/widgets/modal_header.dart';
import '../../../common/extensions.dart';
import '../utils.dart';

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
              title: LocaleKeys.comment.tr(),
              subtitle: comment,
            ),
          ],
        ),
      if (dePoolOnRoundComplete != null)
        section(
          [
            typeItem(LocaleKeys.de_pool_on_round_complete.tr()),
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
            typeItem(LocaleKeys.de_pool_receive_answer.tr()),
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
            typeItem(LocaleKeys.token_wallet_deployed.tr()),
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
            typeItem(LocaleKeys.wallet_interaction.tr()),
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
              ModalHeader(
                text: LocaleKeys.transaction_information.tr(),
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
        title: LocaleKeys.date_and_time.tr(),
        subtitle: transactionTimeFormat.format(date),
      );

  Widget addressItem({
    required bool isOutgoing,
    required String address,
  }) =>
      item(
        title: isOutgoing ? LocaleKeys.recipient.tr() : LocaleKeys.sender.tr(),
        subtitle: address,
      );

  Widget hashItem(String hash) => item(
        title: LocaleKeys.hash_id.tr(),
        subtitle: hash,
      );

  Widget amountItem({
    required bool isOutgoing,
    required String value,
  }) =>
      item(
        title: LocaleKeys.amount.tr(),
        subtitle: '${isOutgoing ? '-' : ''}$value $kEverTicker',
      );

  Widget feeItem(String fees) => item(
        title: LocaleKeys.blockchain_fee.tr(),
        subtitle: '$fees $kEverTicker',
      );

  Widget typeItem(String type) => item(
        title: LocaleKeys.type.tr(),
        subtitle: type,
      );

  Widget explorerButton(String hash) => CustomOutlinedButton(
        onPressed: () => launchUrlString(transactionExplorerLink(hash)),
        text: LocaleKeys.see_in_the_explorer.tr(),
      );
}
