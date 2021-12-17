import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

import '../../../../../../../../../../injection.dart';
import '../../../../../../domain/blocs/ton_wallet/ton_wallet_expired_transactions_bloc.dart';
import '../../../../../../domain/blocs/ton_wallet/ton_wallet_info_bloc.dart';
import '../../../../../../domain/blocs/ton_wallet/ton_wallet_multisig_pending_transactions_bloc.dart';
import '../../../../../../domain/blocs/ton_wallet/ton_wallet_sent_transactions_bloc.dart';
import '../../../../../../domain/blocs/ton_wallet/ton_wallet_transactions_bloc.dart';
import '../../../../../design/design.dart';
import '../../../../../design/widgets/custom_close_button.dart';
import '../../../../../design/widgets/preload_transactions_listener.dart';
import '../../../../../design/widgets/ton_asset_icon.dart';
import '../../../../../design/widgets/wallet_action_button.dart';
import '../../history/ton_wallet_expired_transaction_holder.dart';
import '../../history/ton_wallet_multisig_pending_transaction_holder.dart';
import '../../history/ton_wallet_sent_transaction_holder.dart';
import '../../history/ton_wallet_transaction_holder.dart';
import '../deploy_wallet_flow/start_deploy_wallet_flow.dart';
import '../receive_modal/show_receive_modal.dart';
import '../send_transaction_flow/start_send_transaction_flow.dart';

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
  void didUpdateWidget(covariant TonAssetInfoModalBody oldWidget) {
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
    multisigPendingTransactionsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<TonWalletInfoBloc, TonWalletInfo?>(
        bloc: infoBloc,
        builder: (context, state) => state != null
            ? Material(
                color: Colors.white,
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      header(
                        balance: state.contractState.balance,
                        contractState: state.contractState,
                      ),
                      Expanded(
                        child: history(),
                      ),
                    ],
                  ),
                ),
              )
            : const SizedBox(),
      );

  Widget header({
    required String balance,
    required ContractState contractState,
  }) =>
      Container(
        padding: const EdgeInsets.all(16),
        color: CrystalColor.accentBackground,
        child: Column(
          children: [
            info(balance),
            const SizedBox(height: 24),
            actions(contractState.isDeployed),
          ],
        ),
      );

  Widget info(String balance) => Row(
        children: [
          const TonAssetIcon(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                balanceText(balance),
                const SizedBox(height: 4),
                nameText(),
              ],
            ),
          ),
          const CustomCloseButton(),
        ],
      );

  Widget balanceText(String balance) => Text(
        '${balance.toTokens().removeZeroes().formatValue()} TON',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      );

  Widget nameText() => const Text(
        'TON Crystal',
        style: TextStyle(
          fontSize: 16,
        ),
      );

  Widget actions(bool isDeployed) => Row(
        children: [
          Expanded(
            child: WalletActionButton(
              icon: Assets.images.iconReceive,
              title: LocaleKeys.actions_receive.tr(),
              onPressed: () => showReceiveModal(
                context: context,
                address: widget.address,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: WalletActionButton(
              icon: isDeployed ? Assets.images.iconSend : Assets.images.iconDeploy,
              title: isDeployed ? LocaleKeys.actions_send.tr() : LocaleKeys.actions_deploy.tr(),
              onPressed: isDeployed
                  ? () => startSendTransactionFlow(
                        context: context,
                        address: widget.address,
                      )
                  : () => startDeployWalletFlow(
                        context: context,
                        address: widget.address,
                      ),
            ),
          ),
        ],
      );

  Widget history() => BlocBuilder<TonWalletTransactionsBloc, List<TonWalletTransactionWithData>>(
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
              builder: (context, multisigPendingTransactionsState) => Column(
                children: [
                  historyTitle(
                    transactionsState: transactionsState,
                    sentTransactionsState: sentTransactionsState,
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
                          transactionsState: transactionsState,
                          sentTransactionsState: sentTransactionsState,
                          expiredTransactionsState: expiredTransactionsState,
                          multisigPendingTransactionsState: multisigPendingTransactionsState,
                        ),
                        loader(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Widget historyTitle({
    required List<TonWalletTransactionWithData> transactionsState,
    required List<Tuple2<PendingTransaction, Transaction?>> sentTransactionsState,
    required List<PendingTransaction> expiredTransactionsState,
    required List<MultisigPendingTransaction> multisigPendingTransactionsState,
  }) =>
      Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(
              LocaleKeys.fields_history.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            if (transactionsState.isEmpty &&
                sentTransactionsState.isEmpty &&
                expiredTransactionsState.isEmpty &&
                multisigPendingTransactionsState.isEmpty)
              Text(
                LocaleKeys.wallet_history_modal_placeholder_transactions_empty.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black45,
                ),
              ),
          ],
        ),
      );

  Widget list({
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
              walletType: infoBloc.state?.walletType,
              custodians: infoBloc.state?.custodians,
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

    return RawScrollbar(
      thickness: 4,
      minThumbLength: 48,
      thumbColor: CrystalColor.secondary,
      radius: const Radius.circular(8),
      controller: ModalScrollController.of(context),
      child: PreloadTransactionsListener(
        prevTransactionId: transactionsState.lastOrNull?.transaction.prevTransactionId,
        onLoad: () => transactionsBloc.add(const TonWalletTransactionsEvent.preload()),
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
}
