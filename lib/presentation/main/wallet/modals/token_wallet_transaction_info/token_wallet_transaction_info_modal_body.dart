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
import '../utils.dart';

class TokenWalletTransactionInfoModalBody extends StatelessWidget {
  final TokenWalletTransactionWithData transactionWithData;
  final String currency;
  final int decimals;

  const TokenWalletTransactionInfoModalBody({
    Key? key,
    required this.transactionWithData,
    required this.currency,
    required this.decimals,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sender = transactionWithData.data!.maybeWhen(
          incomingTransfer: (tokenIncomingTransfer) => tokenIncomingTransfer.senderAddress,
          orElse: () => null,
        ) ??
        transactionWithData.transaction.inMessage.src;

    final recipient = transactionWithData.data!.maybeWhen(
          outgoingTransfer: (tokenOutgoingTransfer) => tokenOutgoingTransfer.to.address,
          orElse: () => null,
        ) ??
        transactionWithData.transaction.outMessages.firstOrNull?.dst;

    final value = transactionWithData.data!.when(
      incomingTransfer: (tokenIncomingTransfer) => tokenIncomingTransfer.tokens,
      outgoingTransfer: (tokenOutgoingTransfer) => tokenOutgoingTransfer.tokens,
      swapBack: (tokenSwapBack) => tokenSwapBack.tokens,
      accept: (value) => value,
      transferBounced: (value) => value,
      swapBackBounced: (value) => value,
    );

    final isOutgoing = transactionWithData.data!.when(
      incomingTransfer: (tokenIncomingTransfer) => false,
      outgoingTransfer: (tokenOutgoingTransfer) => true,
      swapBack: (tokenSwapBack) => true,
      accept: (value) => false,
      transferBounced: (value) => false,
      swapBackBounced: (value) => false,
    );

    final address = isOutgoing ? recipient : sender;

    final date = transactionWithData.transaction.createdAt.toDateTime();

    final fees = transactionWithData.transaction.totalFees;

    final hash = transactionWithData.transaction.id.hash;

    final type = transactionWithData.data!.when(
      incomingTransfer: (tokenIncomingTransfer) => LocaleKeys.token_incoming_transfer.tr(),
      outgoingTransfer: (tokenOutgoingTransfer) => LocaleKeys.token_outgoing_transfer.tr(),
      swapBack: (tokenSwapBack) => LocaleKeys.swap_back.tr(),
      accept: (value) => LocaleKeys.accept.tr(),
      transferBounced: (value) => LocaleKeys.transfer_bounced.tr(),
      swapBackBounced: (value) => LocaleKeys.swap_back_bounced.tr(),
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
            value: value.toTokens(decimals).removeZeroes().formatValue(),
          ),
          feeItem(fees.toTokens().removeZeroes().formatValue()),
        ],
      ),
      section(
        [
          typeItem(type),
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
        subtitle: '${isOutgoing ? '-' : ''}$value $currency',
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
