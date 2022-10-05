import 'package:ever_wallet/application/common/constants.dart';
import 'package:ever_wallet/application/common/extensions.dart';
import 'package:ever_wallet/application/common/utils.dart';
import 'package:ever_wallet/application/common/widgets/custom_outlined_button.dart';
import 'package:ever_wallet/application/common/widgets/modal_header.dart';
import 'package:ever_wallet/application/main/common/extensions.dart';
import 'package:ever_wallet/application/main/wallet/modals/utils.dart';
import 'package:ever_wallet/data/models/ton_wallet_ordinary_transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher_string.dart';

class TonWalletTransactionInfoModalBody extends StatelessWidget {
  final TonWalletOrdinaryTransaction transaction;

  const TonWalletTransactionInfoModalBody({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final dePoolOnRoundComplete =
        transaction.dePoolOnRoundCompleteNotification?.toRepresentableData(context);

    final dePoolReceiveAnswer =
        transaction.dePoolReceiveAnswerNotification?.toRepresentableData(context);

    final tokenWalletDeployed =
        transaction.tokenWalletDeployedNotification?.toRepresentableData(context);

    final walletInteraction = transaction.walletInteractionInfo?.toRepresentableData(context);

    final sections = [
      section(
        [
          dateItem(
            context: context,
            date: transaction.date,
          ),
          addressItem(
            context: context,
            isOutgoing: transaction.isOutgoing,
            address: transaction.address,
          ),
          hashItem(
            context: context,
            hash: transaction.hash,
          ),
        ],
      ),
      section(
        [
          amountItem(
            context: context,
            isOutgoing: transaction.isOutgoing,
            value: transaction.value.toTokens().removeZeroes().formatValue(),
          ),
          feeItem(
            context: context,
            fees: transaction.fees.toTokens().removeZeroes().formatValue(),
          ),
        ],
      ),
      if (transaction.comment != null && transaction.comment!.isNotEmpty)
        section(
          [
            item(
              title: AppLocalizations.of(context)!.comment,
              subtitle: transaction.comment!,
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
              const Gap(16),
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: list(sections),
                ),
              ),
              const Gap(16),
              explorerButton(
                context: context,
                hash: transaction.hash,
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
        separatorBuilder: (context, index) => const Gap(16),
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
          const Gap(4),
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
        title: isOutgoing
            ? AppLocalizations.of(context)!.recipient
            : AppLocalizations.of(context)!.sender,
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
