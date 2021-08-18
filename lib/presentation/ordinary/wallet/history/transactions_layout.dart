import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../domain/blocs/ton_wallet/ton_wallet_transactions_bloc.dart';
import '../../../../injection.dart';
import '../../../design/design.dart';
import '../../../design/utils.dart';
import '../../../design/widget/preload_transactions_listener.dart';
import 'transaction_holder.dart';

class TransactionsLayout extends StatefulWidget {
  final SubscriptionSubject subscriptionSubject;
  final ScrollController controller;
  final Widget Function(String) placeholderBuilder;

  const TransactionsLayout({
    Key? key,
    required this.subscriptionSubject,
    required this.controller,
    required this.placeholderBuilder,
  }) : super(key: key);

  @override
  _TransactionsLayoutState createState() => _TransactionsLayoutState();
}

class _TransactionsLayoutState extends State<TransactionsLayout> {
  late final TonWalletTransactionsBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = getIt.get<TonWalletTransactionsBloc>(param1: widget.subscriptionSubject.value.tonWallet);
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<TonWalletTransactionsBloc, TonWalletTransactionsState>(
        bloc: bloc,
        builder: (context, state) => state.maybeWhen(
          ready: (transactions) => AnimatedSwitcher(
            duration: kThemeAnimationDuration,
            child: transactions.isNotEmpty
                ? PreloadTransactionsListener(
                    prevTransId: transactions.lastOrNull?.prevTransId,
                    onLoad: () => bloc.add(const TonWalletTransactionsEvent.preloadTransactions()),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      controller: widget.controller,
                      itemCount: transactions.length,
                      separatorBuilder: (_, __) => Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 16.0),
                        color: CrystalColor.divider,
                      ),
                      itemBuilder: (context, index) => WalletTransactionHolder(
                        transaction: transactions[index],
                        icon: getTonAssetIcon(),
                      ),
                    ),
                  )
                : widget.placeholderBuilder(LocaleKeys.wallet_history_modal_placeholder_transactions_empty.tr()),
          ),
          orElse: () => const SizedBox(),
        ),
      );
}
