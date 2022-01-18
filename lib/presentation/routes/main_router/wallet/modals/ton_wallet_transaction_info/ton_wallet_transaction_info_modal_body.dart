import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../design/design.dart';
import '../../../../../design/explorer.dart';
import '../../../../../design/transaction_time.dart';
import '../../../../../design/widgets/custom_outlined_button.dart';
import '../../../../../design/widgets/modal_header.dart';

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
    final value = (isOutgoing
            ? transactionWithData.transaction.outMessages.first.value
            : transactionWithData.transaction.inMessage.value)
        .toTokens()
        .removeZeroes()
        .formatValue();
    final address = isOutgoing ? recipient : sender;
    final date = transactionWithData.transaction.createdAt.toDateTime();
    final fees = transactionWithData.transaction.totalFees.toTokens().removeZeroes().formatValue();
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
          amountItem(
            isOutgoing: isOutgoing,
            value: value,
          ),
          feeItem(fees),
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
        onPressed: () => launch(getTransactionExplorerLink(hash)),
        text: 'See in the explorer',
      );
}
