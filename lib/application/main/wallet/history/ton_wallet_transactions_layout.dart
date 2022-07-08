import 'package:collection/collection.dart';
import 'package:ever_wallet/application/bloc/ton_wallet/ton_wallet_transactions_bloc.dart';
import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/application/common/widgets/preload_transactions_listener.dart';
import 'package:ever_wallet/application/main/wallet/map_ton_wallet_transactions_to_widgets.dart';
import 'package:ever_wallet/data/models/ton_wallet_info.dart';
import 'package:ever_wallet/data/repositories/ton_wallets_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:provider/provider.dart';

class TonWalletTransactionsLayout extends StatefulWidget {
  final String address;
  final ScrollController controller;

  const TonWalletTransactionsLayout({
    Key? key,
    required this.address,
    required this.controller,
  }) : super(key: key);

  @override
  _TonWalletTransactionsLayoutState createState() => _TonWalletTransactionsLayoutState();
}

class _TonWalletTransactionsLayoutState extends State<TonWalletTransactionsLayout> {
  @override
  Widget build(BuildContext context) =>
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

                  return StreamProvider<AsyncValue<TonWalletInfo?>>(
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

                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                if (tonWalletInfo != null)
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
        },
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

    return AnimatedSwitcher(
      duration: kThemeAnimationDuration,
      child: all.isNotEmpty
          ? PreloadTransactionsListener(
              scrollController: widget.controller,
              onNotification: () {
                final prevTransactionId =
                    transactionsState.lastOrNull?.transaction.prevTransactionId;

                if (prevTransactionId == null) return;

                context
                    .read<TonWalletTransactionsBloc>()
                    .add(TonWalletTransactionsEvent.preload(prevTransactionId));
              },
              child: ListView.separated(
                padding: EdgeInsets.zero,
                controller: widget.controller,
                itemBuilder: (context, index) => all[index],
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  thickness: 1,
                ),
                itemCount: all.length,
              ),
            )
          : placeholder(AppLocalizations.of(context)!.transactions_empty),
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

  Widget placeholder(String text) => Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: CrystalColor.fontSecondaryDark,
            ),
          ),
        ),
      );
}
