import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

import '../../../../../../providers/key/current_key_provider.dart';
import '../../../../../../providers/key/keys_provider.dart';
import '../../../../../../providers/token_wallet/token_wallet_info_provider.dart';
import '../../../../../../providers/token_wallet/token_wallet_transactions_state_provider.dart';
import '../../../../../../providers/ton_wallet/ton_wallet_info_provider.dart';
import '../../../../../generated/assets.gen.dart';
import '../../../../common/extensions.dart';
import '../../../../common/theme.dart';
import '../../../../common/widgets/custom_close_button.dart';
import '../../../../common/widgets/preload_transactions_listener.dart';
import '../../../../common/widgets/token_address_generated_icon.dart';
import '../../../../common/widgets/token_asset_icon.dart';
import '../../../../common/widgets/wallet_action_button.dart';
import '../../history/transactions_holders/token_wallet_transaction_holder.dart';
import '../receive_modal/show_receive_modal.dart';
import '../token_send_transaction_flow/start_token_send_transaction_flow.dart';

class TokenAssetInfoModalBody extends StatefulWidget {
  final String owner;
  final String rootTokenContract;
  final String? logoURI;

  const TokenAssetInfoModalBody({
    Key? key,
    required this.owner,
    required this.rootTokenContract,
    this.logoURI,
  }) : super(key: key);

  @override
  _TokenAssetInfoModalBodyState createState() => _TokenAssetInfoModalBodyState();
}

class _TokenAssetInfoModalBodyState extends State<TokenAssetInfoModalBody> {
  @override
  Widget build(BuildContext context) => Consumer(
        builder: (context, ref, child) {
          final tokenWalletInfo = ref
              .watch(
                tokenWalletInfoProvider(
                  Tuple2(widget.owner, widget.rootTokenContract),
                ),
              )
              .asData
              ?.value;
          final transactionsState = ref.watch(
            tokenWalletTransactionsStateProvider(
              Tuple2(widget.owner, widget.rootTokenContract),
            ),
          );

          return tokenWalletInfo != null
              ? Material(
                  color: Colors.white,
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        header(
                          owner: tokenWalletInfo.owner,
                          balance: tokenWalletInfo.balance,
                          contractState: tokenWalletInfo.contractState,
                          symbol: tokenWalletInfo.symbol,
                          version: tokenWalletInfo.version,
                        ),
                        Expanded(
                          child: history(
                            symbol: tokenWalletInfo.symbol,
                            transactionsState: transactionsState,
                            version: tokenWalletInfo.version,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox();
        },
      );

  Widget header({
    required String owner,
    required String balance,
    required ContractState contractState,
    required Symbol symbol,
    required TokenWalletVersion version,
  }) =>
      Container(
        padding: const EdgeInsets.all(16),
        color: CrystalColor.accentBackground,
        child: Column(
          children: [
            info(
              balance: balance,
              symbol: symbol,
              version: version,
            ),
            const SizedBox(height: 24),
            actions(
              owner: owner,
              symbol: symbol,
            ),
          ],
        ),
      );

  Widget info({
    required String balance,
    required Symbol symbol,
    required TokenWalletVersion version,
  }) =>
      Row(
        children: [
          icon(version: version),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                balanceText(
                  balance: balance,
                  symbol: symbol,
                ),
                const SizedBox(height: 4),
                nameText(symbol),
              ],
            ),
          ),
          const CustomCloseButton(),
        ],
      );

  Widget icon({
    required TokenWalletVersion version,
  }) =>
      widget.logoURI != null
          ? TokenAssetIcon(
              logoURI: widget.logoURI!,
              version: version,
            )
          : TokenAddressGeneratedIcon(
              address: widget.rootTokenContract,
              version: version,
            );

  Widget balanceText({
    required String balance,
    required Symbol symbol,
  }) =>
      Text(
        '${balance.toTokens(symbol.decimals).removeZeroes().formatValue()} ${symbol.name}',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      );

  Widget nameText(Symbol symbol) => Text(
        symbol.fullName,
        style: const TextStyle(
          fontSize: 16,
        ),
      );

  Widget actions({
    required String owner,
    required Symbol symbol,
  }) =>
      Consumer(
        builder: (context, ref, child) {
          final keys = ref.watch(keysProvider).asData?.value ?? {};
          final currentKey = ref.watch(currentKeyProvider).asData?.value;
          final tonWalletInfo = ref.watch(tonWalletInfoProvider(widget.owner)).asData?.value;

          final receiveButton = WalletActionButton(
            icon: Assets.images.iconReceive,
            title: AppLocalizations.of(context)!.receive,
            onPressed: () => showReceiveModal(
              context: context,
              address: owner,
            ),
          );

          WalletActionButton? actionButton;

          if (currentKey != null && tonWalletInfo != null) {
            final keysList = [
              ...keys.keys,
              ...keys.values.whereNotNull().expand((e) => e),
            ];

            final custodians = tonWalletInfo.custodians ?? [];

            final localCustodians = keysList.where((e) => custodians.any((el) => el == e.publicKey)).toList();

            final initiatorKey = localCustodians.firstWhereOrNull((e) => e.publicKey == currentKey.publicKey);

            final listOfKeys = [
              if (initiatorKey != null) initiatorKey,
              ...localCustodians.where((e) => e.publicKey != initiatorKey?.publicKey),
            ];

            final publicKeys = listOfKeys.map((e) => e.publicKey).toList();

            actionButton = WalletActionButton(
              icon: Assets.images.iconSend,
              title: AppLocalizations.of(context)!.send,
              onPressed: publicKeys.isNotEmpty
                  ? () => startTokenSendTransactionFlow(
                        context: context,
                        owner: owner,
                        rootTokenContract: symbol.rootTokenContract,
                        publicKeys: publicKeys,
                      )
                  : null,
            );
          }

          return Row(
            children: [
              Expanded(
                child: receiveButton,
              ),
              if (actionButton != null) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: actionButton,
                ),
              ],
            ],
          );
        },
      );

  Widget history({
    required Symbol symbol,
    required Tuple2<List<TokenWalletTransactionWithData>, bool> transactionsState,
    required TokenWalletVersion version,
  }) =>
      Column(
        children: [
          historyTitle(transactionsState.item1),
          const Divider(
            height: 1,
            thickness: 1,
          ),
          Flexible(
            child: Stack(
              fit: StackFit.expand,
              children: [
                list(
                  state: transactionsState.item1,
                  symbol: symbol,
                  version: version,
                ),
                loader(loading: transactionsState.item2),
              ],
            ),
          ),
        ],
      );

  Widget historyTitle(List<TokenWalletTransactionWithData> state) => Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(
              AppLocalizations.of(context)!.history,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            if (state.isEmpty)
              Text(
                AppLocalizations.of(context)!.transactions_empty,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black45,
                ),
              ),
          ],
        ),
      );

  Widget list({
    required List<TokenWalletTransactionWithData> state,
    required Symbol symbol,
    required TokenWalletVersion version,
  }) =>
      RawScrollbar(
        thickness: 4,
        minThumbLength: 48,
        thumbColor: CrystalColor.secondary,
        radius: const Radius.circular(8),
        controller: ModalScrollController.of(context),
        child: Consumer(
          builder: (context, ref, child) => PreloadTransactionsListener(
            scrollController: ModalScrollController.of(context)!,
            onNotification: () => ref
                .read(
                  tokenWalletTransactionsStateProvider(
                    Tuple2(widget.owner, widget.rootTokenContract),
                  ).notifier,
                )
                .preload(state.lastOrNull?.transaction.prevTransactionId),
            child: ListView.separated(
              controller: ModalScrollController.of(context),
              physics: const ClampingScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) => TokenWalletTransactionHolder(
                transactionWithData: state[index],
                currency: symbol.name,
                decimals: symbol.decimals,
                icon: icon(version: version),
              ),
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                thickness: 1,
              ),
              itemCount: state.length,
            ),
          ),
        ),
      );

  Widget loader({required bool loading}) => IgnorePointer(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: loading
              ? Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black12,
                  child: Center(
                    child: PlatformCircularProgressIndicator(),
                  ),
                )
              : const SizedBox(),
        ),
      );
}