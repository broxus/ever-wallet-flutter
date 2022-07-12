import 'package:collection/collection.dart';
import 'package:ever_wallet/application/bloc/ton_wallet/ton_wallet_transactions_bloc.dart';
import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/constants.dart';
import 'package:ever_wallet/application/common/extensions.dart';
import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/application/common/widgets/custom_close_button.dart';
import 'package:ever_wallet/application/common/widgets/preload_transactions_listener.dart';
import 'package:ever_wallet/application/common/widgets/ton_asset_icon.dart';
import 'package:ever_wallet/application/common/widgets/wallet_action_button.dart';
import 'package:ever_wallet/application/main/wallet/map_ton_wallet_transactions_to_widgets.dart';
import 'package:ever_wallet/application/main/wallet/modals/deploy_wallet_flow/start_deploy_wallet_flow.dart';
import 'package:ever_wallet/application/main/wallet/modals/receive_modal/show_receive_modal.dart';
import 'package:ever_wallet/application/main/wallet/modals/send_transaction_flow/start_send_transaction_flow.dart';
import 'package:ever_wallet/data/models/ton_wallet_info.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
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

class TonAssetInfoModalBody extends StatefulWidget {
  final String address;

  const TonAssetInfoModalBody({
    Key? key,
    required this.address,
  }) : super(key: key);

  @override
  _TonAssetInfoModalBodyState createState() => _TonAssetInfoModalBodyState();
}

class _TonAssetInfoModalBodyState extends State<TonAssetInfoModalBody> {
  @override
  Widget build(BuildContext context) => StreamProvider<AsyncValue<TonWalletInfo?>>(
        create: (context) => context
            .read<TonWalletsRepository>()
            .getInfoStream(widget.address)
            .map((event) => AsyncValue.ready(event)),
        initialData: const AsyncValue.loading(),
        catchError: (context, error) => AsyncValue.error(error),
        builder: (context, child) {
          final tonWalletInfo = context.watch<AsyncValue<TonWalletInfo?>>().maybeWhen(
                ready: (value) => value,
                orElse: () => null,
              );

          return tonWalletInfo != null
              ? Material(
                  color: Colors.white,
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        header(tonWalletInfo: tonWalletInfo),
                        Expanded(
                          child: history(tonWalletInfo: tonWalletInfo),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox();
        },
      );

  Widget header({
    required TonWalletInfo tonWalletInfo,
  }) =>
      Container(
        padding: const EdgeInsets.all(16),
        color: CrystalColor.accentBackground,
        child: Column(
          children: [
            info(tonWalletInfo.contractState.balance),
            const Gap(24),
            actions(tonWalletInfo),
          ],
        ),
      );

  Widget info(String balance) => Row(
        children: [
          const TonAssetIcon(),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                balanceText(balance),
                const Gap(4),
                nameText(),
              ],
            ),
          ),
          const CustomCloseButton(),
        ],
      );

  Widget balanceText(String balance) => Text(
        '${balance.toTokens().removeZeroes().formatValue()} $kEverTicker',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      );

  Widget nameText() => const Text(
        kEverNetworkName,
        style: TextStyle(
          fontSize: 16,
        ),
      );

  Widget actions(TonWalletInfo tonWalletInfo) =>
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

              final receiveButton = WalletActionButton(
                icon: Assets.images.iconReceive,
                title: AppLocalizations.of(context)!.receive,
                onPressed: () => showReceiveModal(
                  context: context,
                  address: widget.address,
                ),
              );

              WalletActionButton? actionButton;

              if (currentKey != null) {
                final requiresSeparateDeploy = tonWalletInfo.details.requiresSeparateDeploy;
                final isDeployed = tonWalletInfo.contractState.isDeployed;

                if (!requiresSeparateDeploy || isDeployed) {
                  final keysList = [
                    ...keys.keys,
                    ...keys.values.whereNotNull().expand((e) => e),
                  ];

                  final custodians = tonWalletInfo.custodians ?? [];

                  final localCustodians =
                      keysList.where((e) => custodians.any((el) => el == e.publicKey)).toList();

                  final initiatorKey =
                      localCustodians.firstWhereOrNull((e) => e.publicKey == currentKey.publicKey);

                  final listOfKeys = [
                    if (initiatorKey != null) initiatorKey,
                    ...localCustodians.where((e) => e.publicKey != initiatorKey?.publicKey),
                  ];

                  final publicKeys = listOfKeys.map((e) => e.publicKey).toList();

                  actionButton = WalletActionButton(
                    icon: Assets.images.iconSend,
                    title: AppLocalizations.of(context)!.send,
                    onPressed: publicKeys.isNotEmpty
                        ? () => startSendTransactionFlow(
                              context: context,
                              address: widget.address,
                              publicKeys: publicKeys,
                            )
                        : null,
                  );
                } else {
                  actionButton = WalletActionButton(
                    icon: Assets.images.iconDeploy,
                    title: AppLocalizations.of(context)!.deploy,
                    onPressed: () => startDeployWalletFlow(
                      context: context,
                      address: widget.address,
                      publicKey: currentKey.publicKey,
                    ),
                  );
                }
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

  Widget history({
    required TonWalletInfo tonWalletInfo,
  }) =>
      StreamProvider<AsyncValue<List<MultisigPendingTransaction>?>>(
        create: (context) => context
            .read<TonWalletsRepository>()
            .getUnconfirmedTransactionsStream(widget.address)
            .map((event) => AsyncValue.ready(event)),
        initialData: const AsyncValue.loading(),
        catchError: (context, error) => AsyncValue.error(error),
        builder: (context, child) {
          final multisigPendingTransactionsState =
              context.watch<AsyncValue<List<MultisigPendingTransaction>?>>().maybeWhen(
                    ready: (value) => value ?? <MultisigPendingTransaction>[],
                    orElse: () => <MultisigPendingTransaction>[],
                  );

          return StreamProvider<AsyncValue<List<PendingTransaction>?>>(
            create: (context) => context
                .read<TonWalletsRepository>()
                .getExpiredMessagesStream(widget.address)
                .map((event) => AsyncValue.ready(event)),
            initialData: const AsyncValue.loading(),
            catchError: (context, error) => AsyncValue.error(error),
            builder: (context, child) {
              final expiredTransactionsState =
                  context.watch<AsyncValue<List<PendingTransaction>?>>().maybeWhen(
                        ready: (value) => value ?? <PendingTransaction>[],
                        orElse: () => <PendingTransaction>[],
                      );

              return StreamProvider<AsyncValue<List<PendingTransaction>?>>(
                create: (context) => context
                    .read<TonWalletsRepository>()
                    .getPendingTransactionsStream(widget.address)
                    .map((event) => AsyncValue.ready(event)),
                initialData: const AsyncValue.loading(),
                catchError: (context, error) => AsyncValue.error(error),
                builder: (context, child) {
                  final pendingTransactionsState =
                      context.watch<AsyncValue<List<PendingTransaction>?>>().maybeWhen(
                            ready: (value) => value ?? <PendingTransaction>[],
                            orElse: () => <PendingTransaction>[],
                          );

                  return BlocProvider<TonWalletTransactionsBloc>(
                    key: ValueKey(widget.address),
                    create: (context) => TonWalletTransactionsBloc(
                      context.read<TonWalletsRepository>(),
                      widget.address,
                    ),
                    child: BlocBuilder<TonWalletTransactionsBloc, TonWalletTransactionsState>(
                      builder: (context, state) {
                        final transactionsState = state.when(
                          initial: () => <TonWalletTransactionWithData>[],
                          loading: (transactions) => transactions,
                          ready: (transactions) => transactions,
                          error: (error) => <TonWalletTransactionWithData>[],
                        );

                        final loading = state.maybeWhen(
                          loading: (transactions) => true,
                          orElse: () => false,
                        );

                        return Column(
                          children: [
                            historyTitle(
                              transactionsState: transactionsState,
                              pendingTransactionsState: pendingTransactionsState,
                              expiredTransactionsState: expiredTransactionsState,
                              multisigPendingTransactionsState: multisigPendingTransactionsState,
                            ),
                            const Divider(
                              height: 1,
                              thickness: 1,
                            ),
                            Flexible(
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  list(
                                    tonWalletInfo: tonWalletInfo,
                                    transactionsState: transactionsState,
                                    pendingTransactionsState: pendingTransactionsState,
                                    expiredTransactionsState: expiredTransactionsState,
                                    multisigPendingTransactionsState:
                                        multisigPendingTransactionsState,
                                  ),
                                  loader(loading: loading),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      );

  Widget historyTitle({
    required List<TonWalletTransactionWithData> transactionsState,
    required List<PendingTransaction> pendingTransactionsState,
    required List<PendingTransaction> expiredTransactionsState,
    required List<MultisigPendingTransaction> multisigPendingTransactionsState,
  }) =>
      Padding(
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
            if (transactionsState.isEmpty &&
                pendingTransactionsState.isEmpty &&
                expiredTransactionsState.isEmpty &&
                multisigPendingTransactionsState.isEmpty)
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
    required TonWalletInfo tonWalletInfo,
    required List<TonWalletTransactionWithData> transactionsState,
    required List<PendingTransaction> pendingTransactionsState,
    required List<PendingTransaction> expiredTransactionsState,
    required List<MultisigPendingTransaction> multisigPendingTransactionsState,
  }) {
    final timeForConfirmation = Duration(seconds: tonWalletInfo.details.expirationTime);

    final all = mapTonWalletTransactionsToWidgets(
      timeForConfirmation: timeForConfirmation,
      tonWalletInfo: tonWalletInfo,
      transactions: transactionsState,
      pendingTransactions: pendingTransactionsState,
      expiredTransactions: expiredTransactionsState,
      multisigPendingTransactions: multisigPendingTransactionsState,
    );

    return RawScrollbar(
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
              .read<TonWalletTransactionsBloc>()
              .add(TonWalletTransactionsEvent.preload(prevTransactionId));
        },
        child: ListView.separated(
          controller: ModalScrollController.of(context),
          physics: const ClampingScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) => all[index],
          separatorBuilder: (_, __) => const Divider(
            height: 1,
            thickness: 1,
          ),
          itemCount: all.length,
        ),
      ),
    );
  }

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
