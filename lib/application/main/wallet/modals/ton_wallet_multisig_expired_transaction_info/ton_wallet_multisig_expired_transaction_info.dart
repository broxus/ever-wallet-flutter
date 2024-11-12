import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/async_value_stream_provider.dart';
import 'package:ever_wallet/application/common/extensions.dart';
import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/application/common/utils.dart';
import 'package:ever_wallet/application/common/widgets/custom_outlined_button.dart';
import 'package:ever_wallet/application/common/widgets/modal_header.dart';
import 'package:ever_wallet/application/common/widgets/transaction_type_label.dart';
import 'package:ever_wallet/application/common/widgets/transport_builder.dart';
import 'package:ever_wallet/application/main/common/extensions.dart';
import 'package:ever_wallet/application/main/wallet/modals/utils.dart';
import 'package:ever_wallet/data/models/ton_wallet_multisig_expired_transaction.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class TonWalletMultisigExpiredTransactionInfoModalBody extends StatelessWidget {
  final TonWalletMultisigExpiredTransaction transaction;

  const TonWalletMultisigExpiredTransactionInfoModalBody({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) => TransportBuilderWidget(
        builder: (context, data) {
          return AsyncValueStreamProvider<Map<String, String>>(
            create: (context) => context.read<KeysRepository>().keyLabelsStream,
            builder: (context, child) {
              final publicKeysLabels =
                  context.watch<AsyncValue<Map<String, String>>>().maybeWhen(
                        ready: (value) => value,
                        orElse: () => <String, String>{},
                      );

              final dePoolOnRoundComplete = transaction
                  .dePoolOnRoundCompleteNotification
                  ?.toRepresentableData(
                context: context,
                ticker: data.config.symbol,
              );

              final dePoolReceiveAnswer = transaction
                  .dePoolReceiveAnswerNotification
                  ?.toRepresentableData(context);

              final tokenWalletDeployed = transaction
                  .tokenWalletDeployedNotification
                  ?.toRepresentableData(context);

              final walletInteraction = transaction.walletInteractionInfo
                  ?.toRepresentableData(context);

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
                      value: transaction.value
                          .toTokens()
                          .removeZeroes()
                          .formatValue(),
                    ),
                    feeItem(
                      context: context,
                      fees: transaction.fees
                          .toTokens()
                          .removeZeroes()
                          .formatValue(),
                    ),
                  ],
                ),
                if (transaction.comment != null &&
                    transaction.comment!.isNotEmpty)
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
                        type: AppLocalizations.of(context)!
                            .de_pool_on_round_complete,
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
                        type: AppLocalizations.of(context)!
                            .de_pool_receive_answer,
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
                        type:
                            AppLocalizations.of(context)!.token_wallet_deployed,
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
                section(
                  [
                    ...transaction.custodians.asMap().entries.map(
                      (e) {
                        final title = publicKeysLabels[e.value] ??
                            AppLocalizations.of(context)!
                                .custodian_n('${e.key + 1}');

                        return custodiansItem(
                          context: context,
                          label: title,
                          publicKey: e.value,
                          isCreator: e.value == transaction.creator,
                          isSigned: transaction.confirmations.contains(e.value),
                        );
                      },
                    ).toList(),
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
                          text: AppLocalizations.of(context)!
                              .transaction_information,
                          onCloseButtonPressed: Navigator.of(context).pop,
                        ),
                        const Gap(16),
                        label(context),
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
            },
          );
        },
      );

  Widget label(BuildContext context) => Row(
        children: [
          TransactionTypeLabel(
            text: AppLocalizations.of(context)!.expired,
            color: CrystalColor.expired,
          ),
        ],
      );

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
    Widget? label,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
              if (label != null) ...[
                const Gap(8),
                label,
              ]
            ],
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
      TransportBuilderWidget(
        builder: (context, data) {
          final ticker = data.config.symbol;

          return item(
            title: AppLocalizations.of(context)!.amount,
            subtitle: '${isOutgoing ? '-' : ''}$value $ticker',
          );
        },
      );

  Widget feeItem({
    required BuildContext context,
    required String fees,
  }) =>
      TransportBuilderWidget(
        builder: (context, data) {
          final ticker = data.config.symbol;

          return item(
            title: AppLocalizations.of(context)!.blockchain_fee,
            subtitle: '$fees $ticker',
          );
        },
      );

  Widget typeItem({
    required BuildContext context,
    required String type,
  }) =>
      item(
        title: AppLocalizations.of(context)!.type,
        subtitle: type,
      );

  Widget custodiansItem({
    required BuildContext context,
    required String label,
    required String publicKey,
    required bool isCreator,
    required bool isSigned,
  }) =>
      item(
        title: label,
        subtitle: publicKey,
        label: Row(
          children: [
            if (isSigned)
              custodianLabel(
                text: AppLocalizations.of(context)!.signed,
                color: CrystalColor.success,
              )
            else
              custodianLabel(
                text: AppLocalizations.of(context)!.not_signed,
                color: CrystalColor.fontDark,
              ),
            if (isCreator) ...[
              const Gap(8),
              custodianLabel(
                text: AppLocalizations.of(context)!.initiator,
                color: CrystalColor.pending,
              ),
            ],
          ],
        ),
      );

  Widget explorerButton({
    required BuildContext context,
    required String hash,
  }) =>
      TransportBuilderWidget(
        builder: (context, data) {
          return CustomOutlinedButton(
            onPressed: () => launchUrlString(
              transactionExplorerLink(
                id: hash,
                explorerBaseUrl: data.config.explorerBaseUrl,
              ),
            ),
            text: AppLocalizations.of(context)!.see_in_the_explorer,
          );
        },
      );

  Widget custodianLabel({
    required String text,
    required Color color,
  }) =>
      TransactionTypeLabel(
        text: text,
        color: color,
        borderRadius: BorderRadius.circular(4),
      );
}
