import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../../providers/common/network_type_provider.dart';
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
      incomingTransfer: (tokenIncomingTransfer) =>
          AppLocalizations.of(context)!.token_incoming_transfer,
      outgoingTransfer: (tokenOutgoingTransfer) =>
          AppLocalizations.of(context)!.token_outgoing_transfer,
      swapBack: (tokenSwapBack) => AppLocalizations.of(context)!.swap_back,
      accept: (value) => AppLocalizations.of(context)!.accept,
      transferBounced: (value) => AppLocalizations.of(context)!.transfer_bounced,
      swapBackBounced: (value) => AppLocalizations.of(context)!.swap_back_bounced,
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
            value: value.toTokens(decimals).removeZeroes().formatValue(),
          ),
          feeItem(
            context: context,
            fees: fees.toTokens().removeZeroes().formatValue(),
          ),
        ],
      ),
      section(
        [
          typeItem(context: context, type: type),
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
              explorerButton(context: context, hash: hash),
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
        subtitle: '${isOutgoing ? '-' : ''}$value $currency',
      );

  Widget feeItem({
    required BuildContext context,
    required String fees,
  }) =>
      Consumer(
        builder: (context, ref, child) {
          final ticker =
              ref.watch(networkTypeProvider).asData?.value == 'Ever' ? kEverTicker : kVenomTicker;

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

  Widget explorerButton({
    required BuildContext context,
    required String hash,
  }) =>
      Consumer(
        builder: (context, ref, child) {
          final transactionExplorerLink = ref.watch(networkTypeProvider).asData?.value == 'Ever'
              ? everTransactionExplorerLink
              : venomTransactionExplorerLink;

          return CustomOutlinedButton(
            onPressed: () => launchUrlString(transactionExplorerLink(hash)),
            text: AppLocalizations.of(context)!.see_in_the_explorer,
          );
        },
      );
}
