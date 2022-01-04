import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../domain/blocs/key/keys_bloc.dart';
import '../../../../../../domain/blocs/public_keys_labels_bloc.dart';
import '../../../../../design/design.dart';
import '../../../../../design/explorer.dart';
import '../../../../../design/transaction_time.dart';
import '../../../../../design/widgets/custom_elevated_button.dart';
import '../../../../../design/widgets/custom_outlined_button.dart';
import '../../../../../design/widgets/modal_header.dart';
import '../../../../../design/widgets/transaction_type_label.dart';
import '../confirm_transaction_flow/start_confirm_transaction_flow.dart';

class TonWalletMultisigPendingTransactionInfoModalBody extends StatelessWidget {
  final TonWalletTransactionWithData transactionWithData;
  final MultisigPendingTransaction? multisigPendingTransaction;
  final String? walletAddress;
  final WalletType? walletType;
  final List<String>? custodians;

  const TonWalletMultisigPendingTransactionInfoModalBody({
    Key? key,
    required this.transactionWithData,
    required this.multisigPendingTransaction,
    required this.walletAddress,
    required this.walletType,
    required this.custodians,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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

    final msgValue = (isOutgoing
            ? transactionWithData.transaction.outMessages.firstOrNull?.value
            : transactionWithData.transaction.inMessage.value)
        ?.toTokens()
        .removeZeroes()
        .formatValue();

    final dataValue = transactionWithData.data
        ?.maybeWhen(
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
        )
        ?.toTokens()
        .removeZeroes()
        .formatValue();

    final value = dataValue ?? msgValue;

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
        'Reward': '${notification.reward.toTokens().removeZeroes().formatValue()} TON',
        'Ordinary stake': '${notification.ordinaryStake.toTokens().removeZeroes().formatValue()} TON',
        'Vesting stake': '${notification.vestingStake.toTokens().removeZeroes().formatValue()} TON',
        'Lock stake': '${notification.lockStake.toTokens().removeZeroes().formatValue()} TON',
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
                'Value': '${multisigSendTransaction.value.toTokens().removeZeroes().formatValue()} TON',
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
                'Value': '${multisigSubmitTransaction.value.toTokens().removeZeroes().formatValue()} TON',
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

    final signsReceived = multisigPendingTransaction?.signsReceived;

    final signsRequired = multisigPendingTransaction?.signsRequired;

    final creator = multisigPendingTransaction?.creator;

    final confirmations = multisigPendingTransaction?.confirmations;

    final transactionId = multisigPendingTransaction?.id;

    final localKeys = [
      ...context.read<KeysBloc>().state.keys.keys,
      ...context.read<KeysBloc>().state.keys.values.where((e) => e != null).cast<List<KeyStoreEntry>>().expand((e) => e)
    ];

    final localCustodians = localKeys.where((e) => custodians?.any((el) => el == e.publicKey) ?? false).toList();

    final nonConfirmedLocalCustodians =
        localCustodians.where((e) => confirmations?.every((el) => el != e.publicKey) ?? false);

    final publicKeys = nonConfirmedLocalCustodians.map((e) => e.publicKey).toList();

    final canConfirm = publicKeys.isNotEmpty;

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
      section(
        [
          if (signsReceived != null && signsRequired != null)
            signaturesItem(
              received: signsReceived,
              required: signsRequired,
            ),
          if (custodians != null && confirmations != null)
            ...custodians!
                .asMap()
                .entries
                .map(
                  (e) => custodiansItem(
                    label: context.read<PublicKeysLabelsBloc>().state[e.value] ?? 'Custodian ${e.key + 1}',
                    publicKey: e.value,
                    isCreator: e.value == creator,
                    isSigned: confirmations.contains(e.value),
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
              if (canConfirm && walletAddress != null && transactionId != null && address != null && value != null) ...[
                confirmButton(
                  context: context,
                  address: walletAddress!,
                  publicKeys: publicKeys,
                  transactionId: transactionId,
                  destination: address,
                  amount: value,
                  comment: comment,
                ),
                const SizedBox(height: 16),
              ],
              explorerButton(hash),
            ],
          ),
        ),
      ),
    );
  }

  Widget label() => Row(
        children: const [
          TransactionTypeLabel(
            text: 'Waiting for confirmation',
            color: CrystalColor.error,
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
        subtitle: '${isOutgoing ? '-' : ''}$value TON',
      );

  Widget feeItem(String fees) => item(
        title: 'Blockchain fee',
        subtitle: '$fees TON',
      );

  Widget typeItem(String type) => item(
        title: 'Type',
        subtitle: type,
      );

  Widget signaturesItem({
    required int received,
    required int required,
  }) =>
      item(
        title: 'Signatures',
        subtitle: '$received of $required signatures collected',
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
                text: 'Signed',
                color: CrystalColor.success,
              )
            else
              custodianLabel(
                text: 'Not signed',
                color: CrystalColor.fontDark,
              ),
            if (isCreator) ...[
              const SizedBox(width: 8),
              custodianLabel(
                text: 'Initiator',
                color: CrystalColor.pending,
              ),
            ],
          ],
        ),
      );

  Widget confirmButton({
    required BuildContext context,
    required String address,
    required List<String> publicKeys,
    required String transactionId,
    required String destination,
    required String amount,
    String? comment,
  }) =>
      CustomElevatedButton(
        onPressed: () => startConfirmTransactionFlow(
          context: context,
          address: address,
          publicKeys: publicKeys,
          transactionId: transactionId,
          destination: destination,
          amount: amount.fromTokens(),
          comment: comment,
        ),
        text: 'Confirm transaction',
      );

  Widget explorerButton(String hash) => CustomOutlinedButton(
        onPressed: () => launch(getTransactionExplorerLink(hash)),
        text: 'See in the explorer',
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
