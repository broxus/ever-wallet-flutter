import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../../domain/blocs/ton_wallet/ton_wallet_transactions_bloc.dart';
import '../../../../../../../../domain/models/ton_wallet_transactions.dart';
import '../../../../../../../../domain/models/transaction_type.dart';
import '../../../../../../../../injection.dart';
import '../../../../design/design.dart';
import '../../../../design/widgets/preload_transactions_listener.dart';
import 'ton_wallet_transaction_holder.dart';

class TonWalletTransactionsLayout extends StatefulWidget {
  final String address;
  final ScrollController controller;
  final Widget Function(String) placeholderBuilder;

  const TonWalletTransactionsLayout({
    Key? key,
    required this.address,
    required this.controller,
    required this.placeholderBuilder,
  }) : super(key: key);

  @override
  _TonWalletTransactionsLayoutState createState() => _TonWalletTransactionsLayoutState();
}

class _TonWalletTransactionsLayoutState extends State<TonWalletTransactionsLayout> {
  final bloc = getIt.get<TonWalletTransactionsBloc>();

  @override
  void initState() {
    super.initState();
    bloc.add(TonWalletTransactionsEvent.load(widget.address));
  }

  @override
  void didUpdateWidget(covariant TonWalletTransactionsLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.address != widget.address) {
      bloc.add(TonWalletTransactionsEvent.load(widget.address));
    }
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<TonWalletTransactionsBloc, TonWalletTransactions>(
        bloc: bloc,
        builder: (context, state) {
          final length = state.ordinary.length + state.sent.length + state.expired.length;

          return AnimatedSwitcher(
            duration: kThemeAnimationDuration,
            child: length != 0
                ? PreloadTransactionsListener(
                    prevTransactionId: state.ordinary.lastOrNull?.transaction.prevTransactionId,
                    onLoad: () => bloc.add(const TonWalletTransactionsEvent.preload()),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      controller: widget.controller,
                      itemCount: length,
                      separatorBuilder: (_, __) => Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        color: CrystalColor.divider,
                      ),
                      itemBuilder: (context, index) {
                        final ordinary = state.ordinary
                            .map((e) => TonWalletTransactionHolder(
                                  currency: 'TON',
                                  transactionType: TransactionType.ordinary,
                                  transaction: e.transaction,
                                  data: e.data,
                                  icon: CircleIcon(
                                    color: Colors.transparent,
                                    icon: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Assets.images.ton.svg(),
                                    ),
                                  ),
                                ))
                            .toList();

                        final sent = state.sent
                            .map((e) => TonWalletTransactionHolder(
                                  currency: 'TON',
                                  transactionType: TransactionType.sent,
                                  transaction: e,
                                  icon: CircleIcon(
                                    color: Colors.transparent,
                                    icon: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Assets.images.ton.svg(),
                                    ),
                                  ),
                                ))
                            .toList();

                        final expired = state.sent
                            .map((e) => TonWalletTransactionHolder(
                                  currency: 'TON',
                                  transactionType: TransactionType.expired,
                                  transaction: e,
                                  icon: CircleIcon(
                                    color: Colors.transparent,
                                    icon: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Assets.images.ton.svg(),
                                    ),
                                  ),
                                ))
                            .toList();

                        final list = [
                          ...ordinary,
                          ...sent,
                          ...expired,
                        ]..sort((a, b) => b.transaction.createdAt.compareTo(a.transaction.createdAt));

                        return list[index];
                      },
                    ),
                  )
                : widget.placeholderBuilder(LocaleKeys.wallet_history_modal_placeholder_transactions_empty.tr()),
          );
        },
      );
}
