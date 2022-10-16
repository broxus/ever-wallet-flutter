import 'package:collection/collection.dart';
import 'package:ever_wallet/application/bloc/ton_wallet/ton_wallet_transactions_bloc.dart';
import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/async_value_stream_provider.dart';
import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/application/common/widgets/preload_transactions_listener.dart';
import 'package:ever_wallet/application/main/wallet/map_ton_wallet_transactions_to_widgets.dart';
import 'package:ever_wallet/data/models/ton_wallet_expired_transaction.dart';
import 'package:ever_wallet/data/models/ton_wallet_multisig_expired_transaction.dart';
import 'package:ever_wallet/data/models/ton_wallet_multisig_ordinary_transaction.dart';
import 'package:ever_wallet/data/models/ton_wallet_multisig_pending_transaction.dart';
import 'package:ever_wallet/data/models/ton_wallet_ordinary_transaction.dart';
import 'package:ever_wallet/data/models/ton_wallet_pending_transaction.dart';
import 'package:ever_wallet/data/repositories/ton_wallets_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

class TonWalletTransactionsLayout extends StatefulWidget {
  final String address;
  final ScrollController controller;

  const TonWalletTransactionsLayout({
    super.key,
    required this.address,
    required this.controller,
  });

  @override
  _TonWalletTransactionsLayoutState createState() => _TonWalletTransactionsLayoutState();
}

class _TonWalletTransactionsLayoutState extends State<TonWalletTransactionsLayout> {
  @override
  Widget build(BuildContext context) =>
      AsyncValueStreamProvider<List<TonWalletMultisigPendingTransaction>>(
        create: (context) =>
            context.read<TonWalletsRepository>().multisigPendingTransactionsStream(widget.address),
        builder: (context, child) {
          final multisigPendingTransactionsState =
              context.watch<AsyncValue<List<TonWalletMultisigPendingTransaction>>>().maybeWhen(
                    ready: (value) => value,
                    orElse: () => <TonWalletMultisigPendingTransaction>[],
                  );

          return AsyncValueStreamProvider<List<TonWalletExpiredTransaction>>(
            create: (context) =>
                context.read<TonWalletsRepository>().expiredTransactionsStream(widget.address),
            builder: (context, child) {
              final expiredTransactionsState =
                  context.watch<AsyncValue<List<TonWalletExpiredTransaction>>>().maybeWhen(
                        ready: (value) => value,
                        orElse: () => <TonWalletExpiredTransaction>[],
                      );

              return AsyncValueStreamProvider<List<TonWalletPendingTransaction>>(
                create: (context) =>
                    context.read<TonWalletsRepository>().pendingTransactionsStream(widget.address),
                builder: (context, child) {
                  final pendingTransactionsState =
                      context.watch<AsyncValue<List<TonWalletPendingTransaction>>>().maybeWhen(
                            ready: (value) => value,
                            orElse: () => <TonWalletPendingTransaction>[],
                          );

                  return AsyncValueStreamProvider<List<TonWalletMultisigExpiredTransaction>>(
                    create: (context) => context
                        .read<TonWalletsRepository>()
                        .multisigExpiredTransactionsStream(widget.address),
                    builder: (context, child) {
                      final multisigExpiredTransactions = context
                          .watch<AsyncValue<List<TonWalletMultisigExpiredTransaction>>>()
                          .maybeWhen(
                            ready: (value) => value,
                            orElse: () => <TonWalletMultisigExpiredTransaction>[],
                          );

                      return AsyncValueStreamProvider<List<TonWalletMultisigOrdinaryTransaction>>(
                        create: (context) => context
                            .read<TonWalletsRepository>()
                            .multisigOrdinaryTransactionsStream(widget.address),
                        builder: (context, child) {
                          final multisigOrdinaryTransactions = context
                              .watch<AsyncValue<List<TonWalletMultisigOrdinaryTransaction>>>()
                              .maybeWhen(
                                ready: (value) => value,
                                orElse: () => <TonWalletMultisigOrdinaryTransaction>[],
                              );
                          return AsyncValueStreamProvider<TonWallet>(
                            create: (context) => context
                                .read<TonWalletsRepository>()
                                .getTonWalletStream(widget.address),
                            builder: (context, child) {
                              final tonWalletInfo =
                                  context.watch<AsyncValue<TonWallet>>().maybeWhen(
                                        ready: (value) => value,
                                        orElse: () => null,
                                      );

                              return BlocProvider<TonWalletTransactionsBloc>(
                                key: ValueKey(widget.address),
                                create: (context) => TonWalletTransactionsBloc(
                                  context.read<TonWalletsRepository>(),
                                  widget.address,
                                ),
                                child: BlocBuilder<TonWalletTransactionsBloc,
                                    TonWalletTransactionsState>(
                                  builder: (context, state) {
                                    final transactionsState = state.when(
                                      initial: () => <TonWalletOrdinaryTransaction>[],
                                      loading: (transactions) => transactions,
                                      ready: (transactions) => transactions,
                                      error: (error) => <TonWalletOrdinaryTransaction>[],
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
                                            multisigOrdinaryTransactions:
                                                multisigOrdinaryTransactions,
                                            multisigPendingTransactions:
                                                multisigPendingTransactionsState,
                                            multisigExpiredTransactions:
                                                multisigExpiredTransactions,
                                            expiredTransactions: expiredTransactionsState,
                                            pendingTransactions: pendingTransactionsState,
                                            ordinaryTransactions: transactionsState,
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
            },
          );
        },
      );

  Widget list({
    required List<TonWalletOrdinaryTransaction> ordinaryTransactions,
    required List<TonWalletPendingTransaction> pendingTransactions,
    required List<TonWalletExpiredTransaction> expiredTransactions,
    required List<TonWalletMultisigOrdinaryTransaction> multisigOrdinaryTransactions,
    required List<TonWalletMultisigPendingTransaction> multisigPendingTransactions,
    required List<TonWalletMultisigExpiredTransaction> multisigExpiredTransactions,
  }) {
    final all = mapTonWalletTransactionsToWidgets(
      ordinaryTransactions: ordinaryTransactions,
      pendingTransactions: pendingTransactions,
      expiredTransactions: expiredTransactions,
      multisigOrdinaryTransactions: multisigOrdinaryTransactions,
      multisigPendingTransactions: multisigPendingTransactions,
      multisigExpiredTransactions: multisigExpiredTransactions,
    );

    return AnimatedSwitcher(
      duration: kThemeAnimationDuration,
      child: all.isNotEmpty
          ? PreloadTransactionsListener(
              scrollController: widget.controller,
              onNotification: () {
                final prevTransactionLt = ordinaryTransactions.lastOrNull?.prevTransactionLt;

                if (prevTransactionLt == null) return;

                context
                    .read<TonWalletTransactionsBloc>()
                    .add(TonWalletTransactionsEvent.preload(prevTransactionLt));
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
