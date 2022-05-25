import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../../../providers/key/public_keys_labels_provider.dart';
import '../../../../../generated/codegen_loader.g.dart';
import '../../../../common/constants.dart';
import '../../../../common/extensions.dart';
import '../../../../common/theme.dart';
import '../../../../common/utils.dart';
import '../../../../common/widgets/custom_outlined_button.dart';
import '../../../../common/widgets/modal_header.dart';
import '../../../../common/widgets/transaction_type_label.dart';
import '../../../common/extensions.dart';
import '../utils.dart';

class TonWalletMultisigExpiredTransactionInfoModalBody extends StatelessWidget {
  final TonWalletTransactionWithData transactionWithData;
  final String creator;
  final List<String> confirmations;
  final String walletAddress;
  final List<String> custodians;

  const TonWalletMultisigExpiredTransactionInfoModalBody({
    Key? key,
    required this.transactionWithData,
    required this.creator,
    required this.confirmations,
    required this.walletAddress,
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
                if (value != null)
                  amountItem(
                    isOutgoing: isOutgoing,
                    value: value.toTokens().removeZeroes().formatValue(),
                  ),
                feeItem(
                  fees.toTokens().removeZeroes().formatValue(),
                ),
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
            section(
              [
                ...custodians.asMap().entries.map(
                  (e) {
                    final title = publicKeysLabels[e.value] ?? LocaleKeys.custodian_n.tr(args: ['${e.key + 1}']);

                    return custodiansItem(
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
                      text: LocaleKeys.transaction_information.tr(),
                    ),
                    const SizedBox(height: 16),
                    label(),
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
        },
      );

  Widget label() => Row(
        children: [
          TransactionTypeLabel(
            text: LocaleKeys.expired.tr(),
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

  Widget custodiansItem({
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
                text: LocaleKeys.signed.tr(),
                color: CrystalColor.success,
              )
            else
              custodianLabel(
                text: LocaleKeys.not_signed.tr(),
                color: CrystalColor.fontDark,
              ),
            if (isCreator) ...[
              const SizedBox(width: 8),
              custodianLabel(
                text: LocaleKeys.initiator.tr(),
                color: CrystalColor.pending,
              ),
            ],
          ],
        ),
      );

  Widget explorerButton(String hash) => CustomOutlinedButton(
        onPressed: () => launchUrlString(transactionExplorerLink(hash)),
        text: LocaleKeys.see_in_the_explorer.tr(),
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
