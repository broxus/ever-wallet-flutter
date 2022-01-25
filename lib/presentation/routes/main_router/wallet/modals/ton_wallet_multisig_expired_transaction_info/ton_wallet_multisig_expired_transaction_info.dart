import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../domain/blocs/key/keys_provider.dart';
import '../../../../../../domain/blocs/key/public_keys_labels_provider.dart';
import '../../../../../design/design.dart';
import '../../../../../design/explorer.dart';
import '../../../../../design/transaction_time.dart';
import '../../../../../design/widgets/custom_outlined_button.dart';
import '../../../../../design/widgets/modal_header.dart';
import '../../../../../design/widgets/transaction_type_label.dart';

class TonWalletMultisigExpiredTransactionInfoModalBody extends StatelessWidget {
  final TonWalletTransactionWithData transactionWithData;
  final String walletAddress;
  final String walletPublicKey;
  final WalletType walletType;
  final List<String> custodians;

  const TonWalletMultisigExpiredTransactionInfoModalBody({
    Key? key,
    required this.transactionWithData,
    required this.walletAddress,
    required this.walletPublicKey,
    required this.walletType,
    required this.custodians,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer(
        builder: (context, ref, child) {
          final keys = ref.watch(keysProvider).asData?.value ?? {};
          final keysList = [
            ...keys.keys,
            ...keys.values.whereNotNull().expand((e) => e),
          ];

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
            dePoolOnRoundComplete: (notification) => {
              'Round ID': notification.roundId,
              'Reward': '${notification.reward.toTokens().removeZeroes().formatValue()} EVER',
              'Ordinary stake': '${notification.ordinaryStake.toTokens().removeZeroes().formatValue()} EVER',
              'Vesting stake': '${notification.vestingStake.toTokens().removeZeroes().formatValue()} EVER',
              'Lock stake': '${notification.lockStake.toTokens().removeZeroes().formatValue()} EVER',
              'Reinvest': notification.reinvest ? 'Yes' : 'No',
              'Reason': notification.reason.toString(),
            },
            orElse: () => null,
          );

          final dePoolReceiveAnswer = transactionWithData.data?.maybeWhen(
            dePoolReceiveAnswer: (notification) => {
              'Error code': notification.errorCode.toString(),
              'comment': notification.comment,
            },
            orElse: () => null,
          );

          final tokenWalletDeployed = transactionWithData.data?.maybeWhen(
            tokenWalletDeployed: (notification) => {
              'Root token contract': notification.rootTokenContract,
            },
            orElse: () => null,
          );

          final ethEventStatusChanged = transactionWithData.data?.maybeWhen(
            ethEventStatusChanged: (status) => {
              'Status': describeEnum(status).capitalize,
            },
            orElse: () => null,
          );

          final tonEventStatusChanged = transactionWithData.data?.maybeWhen(
            tonEventStatusChanged: (status) => {
              'Status': describeEnum(status).capitalize,
            },
            orElse: () => null,
          );

          final walletInteraction = transactionWithData.data?.maybeWhen(
            walletInteraction: (info) {
              final recipient = info.recipient;
              final knownPayload = info.knownPayload?.when(
                comment: (value) => value.isNotEmpty
                    ? Tuple2(
                        'Comment',
                        {
                          'Comment': value,
                        },
                      )
                    : null,
                tokenOutgoingTransfer: (tokenOutgoingTransfer) => Tuple2(
                  'Token outgoing transfer',
                  {
                    ...tokenOutgoingTransfer.to.when(
                      ownerWallet: (address) => {
                        'Owner wallet': address,
                      },
                      tokenWallet: (address) => {
                        'Token wallet': address,
                      },
                    ),
                    'Tokens': tokenOutgoingTransfer.tokens,
                  },
                ),
                tokenSwapBack: (tokenSwapBack) => Tuple2(
                  'Token swap back',
                  {
                    'Tokens': tokenSwapBack.tokens,
                    'Callback address': tokenSwapBack.callbackAddress,
                    'Callback payload': tokenSwapBack.callbackPayload,
                  },
                ),
              );
              final method = info.method.when(
                walletV3Transfer: () => const Tuple2(
                  'WalletV3 transfer',
                  <String, String>{},
                ),
                multisig: (multisigTransaction) => multisigTransaction.when(
                  send: (multisigSendTransaction) => Tuple2(
                    'Multisig send transaction',
                    {
                      'Destination': multisigSendTransaction.dest,
                      'Value': '${multisigSendTransaction.value.toTokens().removeZeroes().formatValue()} EVER',
                      'Bounce': multisigSendTransaction.bounce ? 'Yes' : 'No',
                      'Flags': multisigSendTransaction.flags.toString(),
                      'Payload': multisigSendTransaction.payload,
                    },
                  ),
                  submit: (multisigSubmitTransaction) => Tuple2(
                    'Multisig submit transaction',
                    {
                      'Custodian': multisigSubmitTransaction.custodian,
                      'Destination': multisigSubmitTransaction.dest,
                      'Value': '${multisigSubmitTransaction.value.toTokens().removeZeroes().formatValue()} EVER',
                      'Bounce': multisigSubmitTransaction.bounce ? 'Yes' : 'No',
                      'All balance': multisigSubmitTransaction.allBalance ? 'Yes' : 'No',
                      'Payload': multisigSubmitTransaction.payload,
                      'Transaction ID': multisigSubmitTransaction.transId,
                    },
                  ),
                  confirm: (multisigConfirmTransaction) => Tuple2(
                    'Multisig confirm transaction',
                    {
                      'Custodian': multisigConfirmTransaction.custodian,
                      'Transaction ID': multisigConfirmTransaction.transactionId,
                    },
                  ),
                ),
              );

              return {
                if (recipient != null) 'Recipient': recipient,
                if (knownPayload != null) ...{
                  'Known payload': knownPayload.item1,
                  ...knownPayload.item2,
                },
                'Method': method.item1,
                ...method.item2,
              };
            },
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
            if (ethEventStatusChanged != null)
              section(
                [
                  typeItem('Eth event status changed'),
                  ...ethEventStatusChanged.entries
                      .map(
                        (e) => item(
                          title: e.key,
                          subtitle: e.value,
                        ),
                      )
                      .toList(),
                ],
              ),
            if (tonEventStatusChanged != null)
              section(
                [
                  typeItem('Ton event status changed'),
                  ...tonEventStatusChanged.entries
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
        children: const [
          TransactionTypeLabel(
            text: 'Expired',
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
        onPressed: () => launch(getTransactionExplorerLink(hash)),
        text: 'See in the explorer',
      );
}
