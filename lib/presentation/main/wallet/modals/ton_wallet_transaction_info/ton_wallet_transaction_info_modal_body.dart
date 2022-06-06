import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
      dePoolOnRoundComplete: (notification) => notification.toRepresentableData(context),
      orElse: () => null,
    );

    final dePoolReceiveAnswer = transactionWithData.data?.maybeWhen(
      dePoolReceiveAnswer: (notification) => notification.toRepresentableData(context),
      orElse: () => null,
    );

    final tokenWalletDeployed = transactionWithData.data?.maybeWhen(
      tokenWalletDeployed: (notification) => notification.toRepresentableData(context),
      orElse: () => null,
    );

    final walletInteraction = transactionWithData.data?.maybeWhen(
      walletInteraction: (info) => info.toRepresentableData(context),
      orElse: () => null,
    );

    final sections = [
      section(
        [
          dateItem(
            context: context,
            date: date,
          ),
          if (address != null) ...[
            addressItem(
              context: context,
              isOutgoing: isOutgoing,
              address: address,
            ),
          ],
          hashItem(
            context: context,
            hash: hash,
          ),
        ],
      ),
      section(
        [
          amountItem(
            context: context,
            isOutgoing: isOutgoing,
            value: value.toTokens().removeZeroes().formatValue(),
          ),
          feeItem(
            context: context,
            fees: fees.toTokens().removeZeroes().formatValue(),
          ),
        ],
      ),
      if (comment != null && comment.isNotEmpty)
        section(
          [
            item(
              title: AppLocalizations.of(context)!.comment,
              subtitle: comment,
            ),
          ],
        ),
      if (dePoolOnRoundComplete != null)
        section(
          [
            typeItem(
              context: context,
              type: AppLocalizations.of(context)!.de_pool_on_round_complete,
            ),
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
            typeItem(
              context: context,
              type: AppLocalizations.of(context)!.de_pool_receive_answer,
            ),
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
            typeItem(
              context: context,
              type: AppLocalizations.of(context)!.token_wallet_deployed,
            ),
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
            typeItem(
              context: context,
              type: AppLocalizations.of(context)!.wallet_interaction,
            ),
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
                text: AppLocalizations.of(context)!.transaction_information,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: list(sections),
                ),
              ),
              const SizedBox(height: 16),
              explorerButton(
                context: context,
                hash: hash,
              ),
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

  Widget dateItem({
    required BuildContext context,
    required DateTime date,
  }) =>
      item(
        title: AppLocalizations.of(context)!.date_and_time,
        subtitle: transactionTimeFormat.format(date),
      );

  Widget addressItem({
    required BuildContext context,
    required bool isOutgoing,
    required String address,
  }) =>
      item(
        title: isOutgoing ? AppLocalizations.of(context)!.recipient : AppLocalizations.of(context)!.sender,
        subtitle: address,
      );

  Widget hashItem({
    required BuildContext context,
    required String hash,
  }) =>
      item(
        title: AppLocalizations.of(context)!.hash_id,
        subtitle: hash,
      );

  Widget amountItem({
    required BuildContext context,
    required bool isOutgoing,
    required String value,
  }) =>
      item(
        title: AppLocalizations.of(context)!.amount,
        subtitle: '${isOutgoing ? '-' : ''}$value $kEverTicker',
      );

  Widget feeItem({
    required BuildContext context,
    required String fees,
  }) =>
      item(
        title: AppLocalizations.of(context)!.blockchain_fee,
        subtitle: '$fees $kEverTicker',
      );

  Widget typeItem({
    required BuildContext context,
    required String type,
  }) =>
      item(
        title: AppLocalizations.of(context)!.type,
        subtitle: type,
      );

  Widget explorerButton({
    required BuildContext context,
    required String hash,
  }) =>
      CustomOutlinedButton(
        onPressed: () => launchUrlString(transactionExplorerLink(hash)),
        text: AppLocalizations.of(context)!.see_in_the_explorer,
      );
}
