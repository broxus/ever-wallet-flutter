import 'package:collection/collection.dart';
import 'package:ever_wallet/application/bloc/token_wallet/token_wallet_transactions_bloc.dart';
import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/extensions.dart';
import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/application/common/widgets/custom_close_button.dart';
import 'package:ever_wallet/application/common/widgets/preload_transactions_listener.dart';
import 'package:ever_wallet/application/common/widgets/token_address_generated_icon.dart';
import 'package:ever_wallet/application/common/widgets/token_asset_icon.dart';
import 'package:ever_wallet/application/common/widgets/wallet_action_button.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/token_wallet_transaction_holder.dart';
import 'package:ever_wallet/application/main/wallet/modals/receive_modal/show_receive_modal.dart';
import 'package:ever_wallet/application/main/wallet/modals/token_send_transaction_flow/start_token_send_transaction_flow.dart';
import 'package:ever_wallet/data/models/token_wallet_info.dart';
import 'package:ever_wallet/data/models/ton_wallet_info.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:ever_wallet/data/repositories/token_wallets_repository.dart';
import 'package:ever_wallet/data/repositories/ton_wallets_repository.dart';
import 'package:ever_wallet/generated/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:gap/gap.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:provider/provider.dart';

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
  Widget build(BuildContext context) => StreamProvider<AsyncValue<TokenWalletInfo?>>(
        create: (context) => context
            .read<TokenWalletsRepository>()
            .getInfoStream(
              owner: widget.owner,
              rootTokenContract: widget.rootTokenContract,
            )
            .map((event) => AsyncValue.ready(event)),
        initialData: const AsyncValue.loading(),
        catchError: (context, error) => AsyncValue.error(error),
        builder: (context, child) {
          final tokenWalletInfo = context.watch<AsyncValue<TokenWalletInfo?>>().maybeWhen(
                ready: (value) => value,
                orElse: () => null,
              );

          return tokenWalletInfo != null
              ? BlocProvider<TokenWalletTransactionsBloc>(
                  key: ValueKey('${widget.owner} ${widget.rootTokenContract}'),
                  create: (context) => TokenWalletTransactionsBloc(
                    context.read<TokenWalletsRepository>(),
                    widget.owner,
                    widget.rootTokenContract,
                  ),
                  child: BlocBuilder<TokenWalletTransactionsBloc, TokenWalletTransactionsState>(
                    builder: (context, state) {
                      final transactionsState = state.when(
                        initial: () => <TokenWalletTransactionWithData>[],
                        loading: (transactions) => transactions,
                        ready: (transactions) => transactions,
                        error: (error) => <TokenWalletTransactionWithData>[],
                      );

                      final loading = state.maybeWhen(
                        loading: (transactions) => true,
                        orElse: () => false,
                      );

                      return Material(
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
                                  loading: loading,
                                  version: tokenWalletInfo.version,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
            const Gap(24),
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
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                balanceText(
                  balance: balance,
                  symbol: symbol,
                ),
                const Gap(4),
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
      StreamProvider<AsyncValue<Map<KeyStoreEntry, List<KeyStoreEntry>?>>>(
        create: (context) =>
            context.read<KeysRepository>().mappedKeysStream.map((event) => AsyncValue.ready(event)),
        initialData: const AsyncValue.loading(),
        catchError: (context, error) => AsyncValue.error(error),
        builder: (context, child) {
          final keys =
              context.watch<AsyncValue<Map<KeyStoreEntry, List<KeyStoreEntry>?>>>().maybeWhen(
                    ready: (value) => value,
                    orElse: () => <KeyStoreEntry, List<KeyStoreEntry>?>{},
                  );

          return StreamProvider<AsyncValue<KeyStoreEntry?>>(
            create: (context) => context
                .read<KeysRepository>()
                .currentKeyStream
                .map((event) => AsyncValue.ready(event)),
            initialData: const AsyncValue.loading(),
            catchError: (context, error) => AsyncValue.error(error),
            builder: (context, child) {
              final currentKey = context.watch<AsyncValue<KeyStoreEntry?>>().maybeWhen(
                    ready: (value) => value,
                    orElse: () => null,
                  );

              return StreamProvider<AsyncValue<TonWalletInfo?>>(
                create: (context) => context
                    .read<TonWalletsRepository>()
                    .getInfoStream(widget.owner)
                    .map((event) => AsyncValue.ready(event)),
                initialData: const AsyncValue.loading(),
                catchError: (context, error) => AsyncValue.error(error),
                builder: (context, child) {
                  final tonWalletInfo = context.watch<AsyncValue<TonWalletInfo?>>().maybeWhen(
                        ready: (value) => value,
                        orElse: () => null,
                      );

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

                    final localCustodians =
                        keysList.where((e) => custodians.any((el) => el == e.publicKey)).toList();

                    final initiatorKey = localCustodians
                        .firstWhereOrNull((e) => e.publicKey == currentKey.publicKey);

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
                        const Gap(16),
                        Expanded(
                          child: actionButton,
                        ),
                      ],
                    ],
                  );
                },
              );
            },
          );
        },
      );

  Widget history({
    required Symbol symbol,
    required List<TokenWalletTransactionWithData> transactionsState,
    required bool loading,
    required TokenWalletVersion version,
  }) =>
      Column(
        children: [
          historyTitle(transactionsState),
          const Divider(
            height: 1,
            thickness: 1,
          ),
          Flexible(
            child: Stack(
              fit: StackFit.expand,
              children: [
                list(
                  transactionsState: transactionsState,
                  symbol: symbol,
                  version: version,
                ),
                loader(loading: loading),
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
    required List<TokenWalletTransactionWithData> transactionsState,
    required Symbol symbol,
    required TokenWalletVersion version,
  }) =>
      RawScrollbar(
        thickness: 4,
        minThumbLength: 48,
        thumbColor: CrystalColor.secondary,
        radius: const Radius.circular(8),
        controller: ModalScrollController.of(context),
        child: PreloadTransactionsListener(
          scrollController: ModalScrollController.of(context)!,
          onNotification: () {
            final prevTransactionId = transactionsState.lastOrNull?.transaction.prevTransactionId;

            if (prevTransactionId == null) return;

            context
                .read<TokenWalletTransactionsBloc>()
                .add(TokenWalletTransactionsEvent.preload(prevTransactionId));
          },
          child: ListView.separated(
            controller: ModalScrollController.of(context),
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) => TokenWalletTransactionHolder(
              transactionWithData: transactionsState[index],
              currency: symbol.name,
              decimals: symbol.decimals,
              icon: icon(version: version),
            ),
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              thickness: 1,
            ),
            itemCount: transactionsState.length,
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
