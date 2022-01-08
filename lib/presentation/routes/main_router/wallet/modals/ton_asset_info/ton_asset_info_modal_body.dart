import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

import '../../../../../../domain/blocs/key/current_key_provider.dart';
import '../../../../../../domain/blocs/key/keys_provider.dart';
import '../../../../../../domain/blocs/ton_wallet/ton_wallet_expired_transactions_provider.dart';
import '../../../../../../domain/blocs/ton_wallet/ton_wallet_info_provider.dart';
import '../../../../../../domain/blocs/ton_wallet/ton_wallet_multisig_pending_transactions_provider.dart';
import '../../../../../../domain/blocs/ton_wallet/ton_wallet_sent_transactions_provider.dart';
import '../../../../../../domain/blocs/ton_wallet/ton_wallet_transactions_state_provider.dart';
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
  @override
  Widget build(BuildContext context) => Consumer(
        builder: (context, ref, child) {
          final tonWalletInfo = ref.watch(tonWalletInfoProvider(widget.address)).asData?.value;

          return tonWalletInfo != null
              ? Material(
                  color: Colors.white,
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        header(
                          balance: tonWalletInfo.contractState.balance,
                          contractState: tonWalletInfo.contractState,
                        ),
                        Expanded(
                          child: history(),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox();
        },
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
            actions(),
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

  Widget actions() => Consumer(
        builder: (context, ref, child) {
          final keys = ref.watch(keysProvider).asData?.value ?? {};
          final currentKey = ref.watch(currentKeyProvider).asData?.value;
          final tonWalletInfo = ref.watch(tonWalletInfoProvider(widget.address)).asData?.value;

          final receiveButton = WalletActionButton(
            icon: Assets.images.iconReceive,
            title: LocaleKeys.actions_receive.tr(),
            onPressed: () => showReceiveModal(
              context: context,
              address: widget.address,
            ),
          );

          WalletActionButton? actionButton;

          if (currentKey != null && tonWalletInfo != null) {
            final publicKey = currentKey.publicKey;
            final requiresSeparateDeploy = tonWalletInfo.details.requiresSeparateDeploy;
            final isDeployed = tonWalletInfo.contractState.isDeployed;

            if (!requiresSeparateDeploy || isDeployed) {
              final items = [
                ...keys.keys,
                ...keys.values.whereNotNull().expand((e) => e),
              ];
              final publicKeys =
                  tonWalletInfo.custodians?.where((e) => items.any((el) => el.publicKey == e)).toList() ?? [publicKey];

              actionButton = WalletActionButton(
                icon: Assets.images.iconSend,
                title: LocaleKeys.actions_send.tr(),
                onPressed: () => startSendTransactionFlow(
                  context: context,
                  address: widget.address,
                  publicKeys: publicKeys,
                ),
              );
            } else {
              actionButton = WalletActionButton(
                icon: Assets.images.iconDeploy,
                title: LocaleKeys.actions_deploy.tr(),
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
                const SizedBox(width: 16),
                Expanded(
                  child: actionButton,
                ),
              ],
            ],
          );
        },
      );

  Widget history() => Consumer(
        builder: (context, ref, child) {
          final tonWalletInfo = ref.watch(tonWalletInfoProvider(widget.address)).asData?.value;
          final transactionsState = ref.watch(tonWalletTransactionsStateProvider(widget.address));
          final sentTransactionsState =
              ref.watch(tonWalletSentTransactionsProvider(widget.address)).asData?.value ?? [];
          final expiredTransactionsState =
              ref.watch(tonWalletExpiredTransactionsProvider(widget.address)).asData?.value ?? [];
          final multisigPendingTransactionsState =
              ref.watch(tonWalletMultisigPendingTransactionsProvider(widget.address)).asData?.value ?? [];

          return Column(
            children: [
              historyTitle(
                transactionsState: transactionsState.item1,
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
                      tonWalletInfo: tonWalletInfo,
                      transactionsState: transactionsState.item1,
                      sentTransactionsState: sentTransactionsState,
                      expiredTransactionsState: expiredTransactionsState,
                      multisigPendingTransactionsState: multisigPendingTransactionsState,
                    ),
                    if (transactionsState.item2) loader(),
                  ],
                ),
              ),
            ],
          );
        },
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
    required TonWalletInfo? tonWalletInfo,
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
              walletAddress: tonWalletInfo?.address,
              walletType: tonWalletInfo?.walletType,
              custodians: tonWalletInfo?.custodians,
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
      child: Consumer(
        builder: (context, ref, child) => PreloadTransactionsListener(
          prevTransactionId: transactionsState.lastOrNull?.transaction.prevTransactionId,
          onLoad: () => ref
              .read(
                tonWalletTransactionsStateProvider(widget.address).notifier,
              )
              .preload(),
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
      ),
    );
  }

  Widget loader() => IgnorePointer(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black12,
            child: Center(
              child: PlatformCircularProgressIndicator(),
            ),
          ),
        ),
      );
}
