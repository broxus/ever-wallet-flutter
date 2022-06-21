import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../../../providers/key/public_keys_labels_provider.dart';
import '../../../../common/constants.dart';
import '../../../../common/extensions.dart';
import '../../../../common/theme.dart';
import '../../../../common/utils.dart';
import '../../../../common/widgets/custom_outlined_button.dart';
import '../../../../common/widgets/modal_header.dart';
import '../../../../common/widgets/transaction_type_label.dart';
import '../../../common/extensions.dart';
import '../utils.dart';

class TonWalletMultisigTransactionInfoModalBody extends StatelessWidget {
  final TonWalletTransactionWithData transactionWithData;
  final String creator;
  final List<String> confirmations;
  final List<String> custodians;

  const TonWalletMultisigTransactionInfoModalBody({
    Key? key,
    required this.transactionWithData,
    required this.creator,
    required this.confirmations,
    required this.custodians,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer(
        builder: (context, ref, child) {
          final publicKeysLabels = ref.watch(publicKeysLabelsProvider).asData?.value ?? {};

          final msgSender = transactionWithData.transaction.inMessage.src;

          final dataSender = transactionWithData.data?.maybeWhen(
            walletInteraction: (info) => info.knownPayload?.maybeWhen(
              tokenSwapBack: (tokenSwapBack) => tokenSwapBack.callbackAddress,
              orElse: () => null,
            ),
            orElse: () => null,
          );

          final sender = dataSender ?? msgSender;

          final msgRecipient = transactionWithData.transaction.outMessages.firstOrNull?.dst;

          final dataRecipient = transactionWithData.data?.maybeWhen(
            walletInteraction: (info) =>
                info.knownPayload?.maybeWhen(
                  tokenOutgoingTransfer: (tokenOutgoingTransfer) => tokenOutgoingTransfer.to.address,
                  orElse: () => null,
                ) ??
                info.method.maybeWhen(
                  multisig: (multisigTransaction) => multisigTransaction.maybeWhen(
                    send: (multisigSendTransaction) => multisigSendTransaction.dest,
                    submit: (multisigSubmitTransaction) => multisigSubmitTransaction.dest,
                    orElse: () => null,
                  ),
                  orElse: () => null,
                ) ??
                info.recipient,
            orElse: () => null,
          );

          final recipient = dataRecipient ?? msgRecipient;

          final isOutgoing = recipient != null;

          final msgValue = isOutgoing
              ? transactionWithData.transaction.outMessages.firstOrNull?.value
              : transactionWithData.transaction.inMessage.value;

          final dataValue = transactionWithData.data?.maybeWhen(
            dePoolOnRoundComplete: (notification) => notification.reward,
            walletInteraction: (info) => info.method.maybeWhen(
              multisig: (multisigTransaction) => multisigTransaction.maybeWhen(
                send: (multisigSendTransaction) => multisigSendTransaction.value,
                submit: (multisigSubmitTransaction) => multisigSubmitTransaction.value,
                orElse: () => null,
              ),
              orElse: () => null,
            ),
            orElse: () => null,
          );

          final value = dataValue ?? msgValue;

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
                if (value != null)
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
            section(
              [
                ...custodians.asMap().entries.map(
                  (e) {
                    final title =
                        publicKeysLabels[e.value] ?? AppLocalizations.of(context)!.custodian_n('${e.key + 1}');

                    return custodiansItem(
                      context: context,
                      label: title,
                      publicKey: e.value,
                      isCreator: e.value == creator,
                      isSigned: confirmations.contains(e.value),
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
        },
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
        separatorBuilder: (context, index) => const SizedBox(height: 16),
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
                const SizedBox(width: 8),
                label,
              ]
            ],
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
              const SizedBox(width: 8),
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
      CustomOutlinedButton(
        onPressed: () => launchUrlString(transactionExplorerLink(hash)),
        text: AppLocalizations.of(context)!.see_in_the_explorer,
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
