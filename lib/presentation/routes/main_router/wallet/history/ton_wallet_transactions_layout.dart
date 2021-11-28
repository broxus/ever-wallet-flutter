import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../domain/blocs/ton_wallet/ton_wallet_transactions_bloc.dart';
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
  Widget build(BuildContext context) => BlocBuilder<TonWalletTransactionsBloc, List<TonWalletTransactionWithData>>(
        bloc: bloc,
        builder: (context, state) => AnimatedSwitcher(
          duration: kThemeAnimationDuration,
          child: state.isNotEmpty
              ? PreloadTransactionsListener(
                  prevTransactionId: state.lastOrNull?.transaction.prevTransactionId,
                  onLoad: () => bloc.add(const TonWalletTransactionsEvent.preload()),
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    controller: widget.controller,
                    itemCount: state.length,
                    separatorBuilder: (_, __) => Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      color: CrystalColor.divider,
                    ),
                    itemBuilder: (context, index) => TonWalletTransactionHolder(
                      currency: 'TON',
                      transactionType: TransactionType.ordinary,
                      transaction: state[index].transaction,
                      data: state[index].data,
                      icon: CircleIcon(
                        color: Colors.transparent,
                        icon: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Assets.images.ton.svg(),
                        ),
                      ),
                    ),
                  ),
                )
              : widget.placeholderBuilder(LocaleKeys.wallet_history_modal_placeholder_transactions_empty.tr()),
        ),
      );
}
