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
import '../../../../../../domain/blocs/ton_wallet/ton_wallet_pending_transactions_provider.dart';
import '../../../../../../domain/blocs/ton_wallet/ton_wallet_transactions_state_provider.dart';
import '../../../../../design/design.dart';
import '../../../../../design/transaction_time.dart';
import '../../../../../design/widgets/custom_close_button.dart';
import '../../../../../design/widgets/preload_transactions_listener.dart';
import '../../../../../design/widgets/ton_asset_icon.dart';
import '../../../../../design/widgets/wallet_action_button.dart';
import '../../history/transactions_holders/ton_wallet_expired_transaction_holder.dart';
import '../../history/transactions_holders/ton_wallet_multisig_expired_transaction_holder.dart';
import '../../history/transactions_holders/ton_wallet_multisig_pending_transaction_holder.dart';
import '../../history/transactions_holders/ton_wallet_pending_transaction_holder.dart';
import '../../history/transactions_holders/ton_wallet_transaction_holder.dart';
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
                        header(tonWalletInfo: tonWalletInfo),
                        Expanded(
                          child: history(tonWalletInfo: tonWalletInfo),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox();
        },
      );

  Widget header({
    required TonWalletInfo tonWalletInfo,
  }) =>
      Container(
        padding: const EdgeInsets.all(16),
        color: CrystalColor.accentBackground,
        child: Column(
          children: [
            info(tonWalletInfo.contractState.balance),
            const SizedBox(height: 24),
            actions(tonWalletInfo),
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
        '${balance.toTokens().removeZeroes().formatValue()} EVER',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      );

  Widget nameText() => const Text(
        'Everscale',
        style: TextStyle(
          fontSize: 16,
        ),
      );

  Widget actions(TonWalletInfo tonWalletInfo) => Consumer(
        builder: (context, ref, child) {
          final keys = ref.watch(keysProvider).asData?.value ?? {};
          final currentKey = ref.watch(currentKeyProvider).asData?.value;

          final receiveButton = WalletActionButton(
            icon: Assets.images.iconReceive,
            title: LocaleKeys.actions_receive.tr(),
            onPressed: () => showReceiveModal(
              context: context,
              address: widget.address,
            ),
          );

          WalletActionButton? actionButton;

          if (currentKey != null) {
            final requiresSeparateDeploy = tonWalletInfo.details.requiresSeparateDeploy;
            final isDeployed = tonWalletInfo.contractState.isDeployed;

            if (!requiresSeparateDeploy || isDeployed) {
              final keysList = [
                ...keys.keys,
                ...keys.values.whereNotNull().expand((e) => e),
              ];

              final custodians = tonWalletInfo.custodians ?? [];

              final localCustodians = keysList.where((e) => custodians.any((el) => el == e.publicKey)).toList();

              final initiatorKey = localCustodians.firstWhereOrNull((e) => e.publicKey == currentKey.publicKey);

              final listOfKeys = [
                if (initiatorKey != null) initiatorKey,
                ...localCustodians.where((e) => e.publicKey != initiatorKey?.publicKey),
              ];

              final publicKeys = listOfKeys.map((e) => e.publicKey).toList();

              actionButton = WalletActionButton(
                icon: Assets.images.iconSend,
                title: LocaleKeys.actions_send.tr(),
                onPressed: publicKeys.isNotEmpty
                    ? () => startSendTransactionFlow(
                          context: context,
                          address: widget.address,
                          publicKeys: publicKeys,
                        )
                    : null,
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

  Widget history({
    required TonWalletInfo tonWalletInfo,
  }) =>
      Consumer(
        builder: (context, ref, child) {
          final transactionsState = ref.watch(tonWalletTransactionsStateProvider(widget.address));
          final pendingTransactionsState =
              ref.watch(tonWalletPendingTransactionsProvider(widget.address)).asData?.value ?? [];
          final expiredTransactionsState =
              ref.watch(tonWalletExpiredTransactionsProvider(widget.address)).asData?.value ?? [];
          final multisigPendingTransactionsState =
              ref.watch(tonWalletMultisigPendingTransactionsProvider(widget.address)).asData?.value ?? [];

          return Column(
            children: [
              historyTitle(
                transactionsState: transactionsState.item1,
                pendingTransactionsState: pendingTransactionsState,
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
                      pendingTransactionsState: pendingTransactionsState,
                      expiredTransactionsState: expiredTransactionsState,
                      multisigPendingTransactionsState: multisigPendingTransactionsState,
                    ),
                    loader(transactionsState.item2),
                  ],
                ),
              ),
            ],
          );
        },
      );

  Widget historyTitle({
    required List<TonWalletTransactionWithData> transactionsState,
    required List<PendingTransaction> pendingTransactionsState,
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
                pendingTransactionsState.isEmpty &&
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
    required TonWalletInfo tonWalletInfo,
    required List<TonWalletTransactionWithData> transactionsState,
    required List<PendingTransaction> pendingTransactionsState,
    required List<PendingTransaction> expiredTransactionsState,
    required List<MultisigPendingTransaction> multisigPendingTransactionsState,
  }) {
    final timeForConfirmation = Duration(seconds: tonWalletInfo.details.expirationTime);

    final ordinaryTransactions = transactionsState.where(
      (e) =>
          e.data?.maybeWhen(
            walletInteraction: (info) => info.method.maybeWhen(
              multisig: (multisigTransaction) => multisigTransaction.maybeWhen(
                submit: (multisigSubmitTransaction) => false,
                confirm: (multisigConfirmTransaction) => false,
                orElse: () => true,
              ),
              orElse: () => true,
            ),
            orElse: () => true,
          ) ??
          true,
    );
    final ordinary = ordinaryTransactions.map(
      (e) => Tuple2(
        e.transaction.createdAt,
        TonWalletTransactionHolder(
          transactionWithData: e,
          walletAddress: tonWalletInfo.address,
        ),
      ),
    );

    final pending = pendingTransactionsState.map(
      (e) => Tuple2(
        e.expireAt,
        TonWalletPendingTransactionHolder(
          pendingTransaction: e,
          walletAddress: tonWalletInfo.address,
        ),
      ),
    );

    final expired = expiredTransactionsState.map(
      (e) => Tuple2(
        e.expireAt,
        TonWalletExpiredTransactionHolder(
          pendingTransaction: e,
          walletAddress: tonWalletInfo.address,
        ),
      ),
    );

    final multisigPendingTransactions = transactionsState.where(
      (e) =>
          e.data != null &&
          e.data!.maybeWhen(
            walletInteraction: (info) => info.method.maybeWhen(
              multisig: (multisigTransaction) => multisigTransaction.maybeWhen(
                submit: (multisigSubmitTransaction) =>
                    e.transaction.createdAt.toDateTime().add(timeForConfirmation).isAfter(DateTime.now()) &&
                    multisigPendingTransactionsState.any((e) => e.id == multisigSubmitTransaction.transId),
                orElse: () => false,
              ),
              orElse: () => false,
            ),
            orElse: () => false,
          ),
    );
    final multisigPending = multisigPendingTransactions.map(
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
          walletAddress: tonWalletInfo.address,
          walletPublicKey: tonWalletInfo.publicKey,
          walletType: tonWalletInfo.walletType,
          custodians: tonWalletInfo.custodians ?? [],
          details: tonWalletInfo.details,
        ),
      ),
    );

    final multisigExpiredTransactions = transactionsState.where(
      (e) =>
          e.data != null &&
          e.data!.maybeWhen(
            walletInteraction: (info) => info.method.maybeWhen(
              multisig: (multisigTransaction) => multisigTransaction.maybeWhen(
                submit: (multisigSubmitTransaction) {
                  final submitTransactionId = multisigSubmitTransaction.transId;
                  final custodians = tonWalletInfo.custodians ?? [];
                  final confirmations = transactionsState
                      .where(
                        (e) =>
                            e.data != null &&
                            e.data!.maybeWhen(
                              walletInteraction: (info) => info.method.maybeWhen(
                                multisig: (multisigTransaction) => multisigTransaction.maybeWhen(
                                  submit: (multisigSubmitTransaction) =>
                                      multisigSubmitTransaction.transId == submitTransactionId,
                                  confirm: (multisigConfirmTransaction) =>
                                      multisigConfirmTransaction.transactionId == submitTransactionId,
                                  orElse: () => false,
                                ),
                                orElse: () => false,
                              ),
                              orElse: () => false,
                            ),
                      )
                      .map(
                        (e) => e.data?.maybeWhen(
                          walletInteraction: (info) => info.method.maybeWhen(
                            multisig: (multisigTransaction) => multisigTransaction.maybeWhen(
                              submit: (multisigSubmitTransaction) => multisigSubmitTransaction.custodian,
                              confirm: (multisigConfirmTransaction) => multisigConfirmTransaction.custodian,
                              orElse: () => null,
                            ),
                            orElse: () => null,
                          ),
                          orElse: () => null,
                        ),
                      )
                      .whereNotNull();

                  final signed = custodians.every((e) => confirmations.contains(e));

                  return !signed &&
                      e.transaction.createdAt.toDateTime().add(timeForConfirmation).isBefore(DateTime.now());
                },
                orElse: () => false,
              ),
              orElse: () => false,
            ),
            orElse: () => false,
          ),
    );
    final multisigExpired = multisigExpiredTransactions.map(
      (e) => Tuple2(
        e.transaction.createdAt,
        TonWalletMultisigExpiredTransactionHolder(
          transactionWithData: e,
          walletAddress: tonWalletInfo.address,
          walletPublicKey: tonWalletInfo.publicKey,
          walletType: tonWalletInfo.walletType,
          custodians: tonWalletInfo.custodians ?? [],
        ),
      ),
    );

    final multisigSent = transactionsState
        .where(
          (e) =>
              e.data != null &&
              e.data!.maybeWhen(
                walletInteraction: (info) => info.method.maybeWhen(
                  multisig: (multisigTransaction) => multisigTransaction.maybeWhen(
                    submit: (multisigSubmitTransaction) => true,
                    orElse: () => false,
                  ),
                  orElse: () => false,
                ),
                orElse: () => false,
              ),
        )
        .where((e) => !multisigPendingTransactions.contains(e) && !multisigExpiredTransactions.contains(e))
        .map(
          (e) => Tuple2(
            e.transaction.createdAt,
            TonWalletTransactionHolder(
              transactionWithData: e,
              walletAddress: tonWalletInfo.address,
            ),
          ),
        );

    final sorted = [
      ...ordinary,
      ...pending,
      ...expired,
      ...multisigSent,
      ...multisigPending,
      ...multisigExpired,
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
}
