import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../data/models/ton_wallet_info.dart';
import '../../../../../providers/ton_wallet/ton_wallet_expired_transactions_provider.dart';
import '../../../../../providers/ton_wallet/ton_wallet_info_provider.dart';
import '../../../../../providers/ton_wallet/ton_wallet_multisig_pending_transactions_provider.dart';
import '../../../../../providers/ton_wallet/ton_wallet_pending_transactions_provider.dart';
import '../../../../../providers/ton_wallet/ton_wallet_transactions_state_provider.dart';
import '../../../../design/design.dart';
import '../../../../design/widgets/preload_transactions_listener.dart';
import '../map_ton_wallet_transactions_to_widgets.dart';

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
  Widget build(BuildContext context) => Consumer(
        builder: (context, ref, child) {
          final tonWalletInfo = ref.watch(tonWalletInfoProvider(widget.address)).asData?.value;
          final transactionsState = ref.watch(tonWalletTransactionsStateProvider(widget.address));
          final pendingTransactionsState =
              ref.watch(tonWalletPendingTransactionsProvider(widget.address)).asData?.value ?? [];
          final expiredTransactionsState =
              ref.watch(tonWalletExpiredTransactionsProvider(widget.address)).asData?.value ?? [];
          final multisigPendingTransactionsState =
              ref.watch(tonWalletMultisigPendingTransactionsProvider(widget.address)).asData?.value ?? [];

          return Stack(
            fit: StackFit.expand,
            children: [
              if (tonWalletInfo != null)
                list(
                  tonWalletInfo: tonWalletInfo,
                  transactionsState: transactionsState.item1,
                  pendingTransactionsState: pendingTransactionsState,
                  expiredTransactionsState: expiredTransactionsState,
                  multisigPendingTransactionsState: multisigPendingTransactionsState,
                ),
              loader(transactionsState.item2),
            ],
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
          ? Consumer(
              builder: (context, ref, child) => PreloadTransactionsListener(
                scrollController: widget.controller,
                onNotification: () => ref
                    .read(tonWalletTransactionsStateProvider(widget.address).notifier)
                    .preload(transactionsState.lastOrNull?.transaction.prevTransactionId),
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
              ),
            )
          : placeholder(LocaleKeys.wallet_history_modal_placeholder_transactions_empty.tr()),
    );
  }

  Widget loader(bool loading) => IgnorePointer(
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
