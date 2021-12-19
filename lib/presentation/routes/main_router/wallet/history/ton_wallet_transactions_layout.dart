import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

import '../../../../../../../../domain/blocs/ton_wallet/ton_wallet_transactions_bloc.dart';
import '../../../../../../../../injection.dart';
import '../../../../../domain/blocs/ton_wallet/ton_wallet_expired_transactions_bloc.dart';
import '../../../../../domain/blocs/ton_wallet/ton_wallet_info_bloc.dart';
import '../../../../../domain/blocs/ton_wallet/ton_wallet_multisig_pending_transactions_bloc.dart';
import '../../../../../domain/blocs/ton_wallet/ton_wallet_sent_transactions_bloc.dart';
import '../../../../design/design.dart';
import '../../../../design/widgets/preload_transactions_listener.dart';
import 'ton_wallet_expired_transaction_holder.dart';
import 'ton_wallet_multisig_pending_transaction_holder.dart';
import 'ton_wallet_sent_transaction_holder.dart';
import 'ton_wallet_transaction_holder.dart';

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
  final infoBloc = getIt.get<TonWalletInfoBloc>();
  final transactionsBloc = getIt.get<TonWalletTransactionsBloc>();
  final sentTransactionsBloc = getIt.get<TonWalletSentTransactionsBloc>();
  final expiredTransactionsBloc = getIt.get<TonWalletExpiredTransactionsBloc>();
  final multisigPendingTransactionsBloc = getIt.get<TonWalletMultisigPendingTransactionsBloc>();

  @override
  void initState() {
    super.initState();
    infoBloc.add(
      TonWalletInfoEvent.load(widget.address),
    );
    transactionsBloc.add(
      TonWalletTransactionsEvent.load(widget.address),
    );
    sentTransactionsBloc.add(
      TonWalletSentTransactionsEvent.load(widget.address),
    );
    expiredTransactionsBloc.add(
      TonWalletExpiredTransactionsEvent.load(widget.address),
    );
    multisigPendingTransactionsBloc.add(
      TonWalletMultisigPendingTransactionsEvent.load(widget.address),
    );
  }

  @override
  void didUpdateWidget(covariant TonWalletTransactionsLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.address != widget.address) {
      infoBloc.add(
        TonWalletInfoEvent.load(widget.address),
      );
      transactionsBloc.add(
        TonWalletTransactionsEvent.load(widget.address),
      );
      sentTransactionsBloc.add(
        TonWalletSentTransactionsEvent.load(widget.address),
      );
      expiredTransactionsBloc.add(
        TonWalletExpiredTransactionsEvent.load(widget.address),
      );
      multisigPendingTransactionsBloc.add(
        TonWalletMultisigPendingTransactionsEvent.load(widget.address),
      );
    }
  }

  @override
  void dispose() {
    infoBloc.close();
    transactionsBloc.close();
    sentTransactionsBloc.close();
    expiredTransactionsBloc.close();
    multisigPendingTransactionsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => history();

  Widget history() => BlocBuilder<TonWalletInfoBloc, TonWalletInfo?>(
        bloc: infoBloc,
        builder: (context, infoState) => BlocBuilder<TonWalletTransactionsBloc, List<TonWalletTransactionWithData>>(
          bloc: transactionsBloc,
          builder: (context, transactionsState) =>
              BlocBuilder<TonWalletSentTransactionsBloc, List<Tuple2<PendingTransaction, Transaction?>>>(
            bloc: sentTransactionsBloc,
            builder: (context, sentTransactionsState) =>
                BlocBuilder<TonWalletExpiredTransactionsBloc, List<PendingTransaction>>(
              bloc: expiredTransactionsBloc,
              builder: (context, expiredTransactionsState) =>
                  BlocBuilder<TonWalletMultisigPendingTransactionsBloc, List<MultisigPendingTransaction>>(
                bloc: multisigPendingTransactionsBloc,
                builder: (context, multisigPendingTransactionsState) => Stack(
                  fit: StackFit.expand,
                  children: [
                    list(
                      infoState: infoState,
                      transactionsState: transactionsState,
                      sentTransactionsState: sentTransactionsState,
                      expiredTransactionsState: expiredTransactionsState,
                      multisigPendingTransactionsState: multisigPendingTransactionsState,
                    ),
                    loader(),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Widget list({
    required TonWalletInfo? infoState,
    required List<TonWalletTransactionWithData> transactionsState,
    required List<Tuple2<PendingTransaction, Transaction?>> sentTransactionsState,
    required List<PendingTransaction> expiredTransactionsState,
    required List<MultisigPendingTransaction> multisigPendingTransactionsState,
  }) {
    final accountPendingTransactions = transactionsState
        .where((e) => e.data != null)
        .toList()
        .where(
          (e) => e.data!.maybeWhen(
            walletInteraction: (info) => info.method.maybeWhen(
              multisig: (multisigTransaction) => multisigTransaction.maybeWhen(
                submit: (multisigSubmitTransaction) =>
                    multisigPendingTransactionsState.any((e) => e.id == multisigSubmitTransaction.transId),
                orElse: () => false,
              ),
              orElse: () => false,
            ),
            orElse: () => false,
          ),
        )
        .toList();

    final ordinary = transactionsState
        .where((e) => !accountPendingTransactions.any((el) => el == e))
        .map(
          (e) => Tuple2(
            e.transaction.createdAt,
            TonWalletTransactionHolder(
              transactionWithData: e,
            ),
          ),
        )
        .toList();

    final sent = sentTransactionsState
        .map(
          (e) => Tuple2(
            e.item2?.createdAt ?? e.item1.expireAt,
            TonWalletSentTransactionHolder(
              pendingTransaction: e.item1,
              transaction: e.item2,
            ),
          ),
        )
        .toList();

    final expired = expiredTransactionsState
        .map(
          (e) => Tuple2(
            e.expireAt,
            TonWalletExpiredTransactionHolder(
              pendingTransaction: e,
            ),
          ),
        )
        .toList();

    final multisigPending = accountPendingTransactions
        .map(
          (e) => Tuple2(
            e.transaction.createdAt,
            TonWalletMultisigPendingTransactionHolder(
              transactionWithData: e,
              multisigPendingTransaction: multisigPendingTransactionsState.firstWhere(
                (el) =>
                    el.id ==
                    e.data?.maybeWhen(
                      walletInteraction: (info) => info.method.maybeWhen(
                        multisig: (multisigTransaction) => multisigTransaction.maybeWhen(
                          submit: (multisigSubmitTransaction) => multisigSubmitTransaction.transId,
                          orElse: () => null,
                        ),
                        orElse: () => null,
                      ),
                      orElse: () => null,
                    ),
              ),
              walletAddress: infoState?.address,
              walletType: infoState?.walletType,
              custodians: infoState?.custodians,
            ),
          ),
        )
        .toList();

    final sorted = [
      ...ordinary,
      ...sent,
      ...expired,
      ...multisigPending,
    ]..sort((a, b) => b.item1.compareTo(a.item1));

    final all = sorted.map((e) => e.item2).toList();

    return AnimatedSwitcher(
      duration: kThemeAnimationDuration,
      child: all.isNotEmpty
          ? PreloadTransactionsListener(
              prevTransactionId: transactionsState.lastOrNull?.transaction.prevTransactionId,
              onLoad: () => transactionsBloc.add(const TonWalletTransactionsEvent.preload()),
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
          : placeholder(LocaleKeys.wallet_history_modal_placeholder_transactions_empty.tr()),
    );
  }

  Widget loader() => StreamBuilder<bool>(
        stream: transactionsBloc.sideEffectsStream,
        builder: (context, snapshot) => IgnorePointer(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: !(snapshot.data ?? false)
                ? const SizedBox()
                : Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black12,
                    child: PlatformCircularProgressIndicator(),
                  ),
          ),
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
