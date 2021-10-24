import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/blocs/ton_wallet/ton_wallet_transactions_bloc.dart';
import '../../../../injection.dart';
import '../../../design/design.dart';
import '../../../design/widget/preload_transactions_listener.dart';
import 'transaction_holder.dart';

class TransactionsLayout extends StatefulWidget {
  final String address;
  final ScrollController controller;
  final Widget Function(String) placeholderBuilder;

  const TransactionsLayout({
    Key? key,
    required this.address,
    required this.controller,
    required this.placeholderBuilder,
  }) : super(key: key);

  @override
  _TransactionsLayoutState createState() => _TransactionsLayoutState();
}

class _TransactionsLayoutState extends State<TransactionsLayout> {
  final bloc = getIt.get<TonWalletTransactionsBloc>();

  @override
  void initState() {
    super.initState();
    bloc.add(TonWalletTransactionsEvent.load(widget.address));
  }

  @override
  void didUpdateWidget(covariant TransactionsLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    bloc.add(TonWalletTransactionsEvent.load(widget.address));
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<TonWalletTransactionsBloc, TonWalletTransactionsState>(
        bloc: bloc,
        builder: (context, state) => AnimatedSwitcher(
          duration: kThemeAnimationDuration,
          child: state.transactions.isNotEmpty
              ? PreloadTransactionsListener(
                  prevTransactionId: state.transactions.lastOrNull?.prevTransactionId,
                  onLoad: () => bloc.add(const TonWalletTransactionsEvent.preload()),
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    controller: widget.controller,
                    itemCount: state.transactions.length,
                    separatorBuilder: (_, __) => Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      color: CrystalColor.divider,
                    ),
                    itemBuilder: (context, index) => WalletTransactionHolder(
                      transaction: state.transactions[index],
                      icon: Image.asset(Assets.images.ton.path),
                    ),
                  ),
                )
              : widget.placeholderBuilder(LocaleKeys.wallet_history_modal_placeholder_transactions_empty.tr()),
        ),
      );
}
