import 'package:collection/collection.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../domain/blocs/ton_wallet/ton_wallet_info_bloc.dart';
import '../../../../../domain/blocs/ton_wallet/ton_wallet_transactions_bloc.dart';
import '../../../../../injection.dart';
import '../../../../design/design.dart';
import '../../../../design/widget/crystal_bottom_sheet.dart';
import '../../../../design/widget/preload_transactions_listener.dart';
import '../../history/transaction_holder.dart';
import '../deploy_wallet_flow/deploy_wallet_flow.dart';
import '../receive_modal.dart';
import '../send_transaction_flow/send_transaction_flow.dart';

class TonAssetObserver extends StatefulWidget {
  final TonWallet tonWallet;

  const TonAssetObserver._({
    Key? key,
    required this.tonWallet,
  }) : super(key: key);

  static Future<void> open({
    required BuildContext context,
    required TonWallet tonWallet,
  }) =>
      CrystalBottomSheet.show(
        context,
        expand: false,
        padding: EdgeInsets.zero,
        avoidBottomInsets: false,
        barrierColor: CrystalColor.modalBackground.withOpacity(0.7),
        body: TonAssetObserver._(
          tonWallet: tonWallet,
        ),
      );

  @override
  _TonAssetObserverState createState() => _TonAssetObserverState();
}

class _TonAssetObserverState extends State<TonAssetObserver> {
  final _historyScrollController = ScrollController();
  late final TonWalletInfoBloc tonWalletInfoBloc;
  late final TonWalletTransactionsBloc tonWalletTransactionsBloc;

  @override
  void initState() {
    super.initState();
    tonWalletInfoBloc = getIt.get<TonWalletInfoBloc>(param1: widget.tonWallet);
    tonWalletTransactionsBloc = getIt.get<TonWalletTransactionsBloc>(param1: widget.tonWallet);
  }

  @override
  void dispose() {
    _historyScrollController.dispose();
    tonWalletInfoBloc.close();
    tonWalletTransactionsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<TonWalletInfoBloc, TonWalletInfoState>(
        bloc: tonWalletInfoBloc,
        builder: (context, state) => state.maybeWhen(
          ready: (address, contractState, walletType, details, publicKey) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(
                address: address,
                contractState: contractState,
              ),
              Flexible(
                child: _history(),
              ),
            ],
          ),
          orElse: () => const SizedBox(),
        ),
      );

  Widget _header({
    required String address,
    required ContractState contractState,
  }) =>
      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 24,
        ),
        color: CrystalColor.accentBackground,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleIcon(
                  color: Colors.transparent,
                  icon: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(Assets.images.ton.path),
                  ),
                ),
                const CrystalDivider(width: 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 24,
                        child: Text(
                          contractState.balance,
                          style: const TextStyle(
                            fontSize: 20,
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w700,
                            color: CrystalColor.fontDark,
                          ),
                        ),
                      ),
                      const CrystalDivider(height: 4),
                      const SizedBox(
                        height: 20,
                        child: Text(
                          'TON',
                          style: TextStyle(
                            fontSize: 16,
                            letterSpacing: 0.75,
                            color: CrystalColor.fontSecondaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const CrystalDivider(height: 24),
            _headerActions(
              address: address,
              isDeployed: contractState.isDeployed,
            ),
          ],
        ),
      );

  Widget _headerActions({
    required String address,
    required bool isDeployed,
  }) =>
      AnimatedSwitcher(
        duration: kThemeAnimationDuration,
        child: Row(
          children: [
            Expanded(
              child: _assetButton(
                asset: Assets.images.iconReceive.path,
                title: LocaleKeys.actions_receive.tr(),
                onTap: () => CrystalBottomSheet.show(
                  context,
                  body: ReceiveModalBody(
                    textAsTitle: true,
                    address: address,
                  ),
                ),
              ),
            ),
            const CrystalDivider(width: 10),
            Expanded(
              child: _assetButton(
                onTap: () => isDeployed
                    ? SendTransactionFlow.start(
                        context: context,
                        tonWallet: widget.tonWallet,
                      )
                    : DeployWalletFlow.start(
                        context: context,
                        tonWallet: widget.tonWallet,
                      ),
                asset: isDeployed ? Assets.images.iconSend.path : Assets.images.iconDeploy.path,
                title: isDeployed ? LocaleKeys.actions_send.tr() : LocaleKeys.actions_deploy.tr(),
              ),
            ),
          ],
        ),
      );

  Widget _history() => BlocBuilder<TonWalletTransactionsBloc, TonWalletTransactionsState>(
        bloc: tonWalletTransactionsBloc,
        builder: (context, state) => state.maybeWhen(
          ready: (transactions) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      LocaleKeys.fields_history.tr(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: CrystalColor.fontDark,
                      ),
                    ),
                    const Spacer(),
                    if (transactions.isEmpty)
                      Text(
                        LocaleKeys.wallet_history_modal_placeholder_transactions_empty.tr(),
                        style: const TextStyle(
                          fontSize: 16,
                          color: CrystalColor.fontSecondaryDark,
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1),
              Flexible(
                child: RawScrollbar(
                  thickness: 4,
                  thumbColor: CrystalColor.secondary,
                  radius: const Radius.circular(8),
                  controller: _historyScrollController,
                  child: PreloadTransactionsListener(
                    prevTransId: transactions.lastOrNull?.prevTransId,
                    onLoad: () => tonWalletTransactionsBloc.add(
                      const TonWalletTransactionsEvent.preloadTransactions(),
                    ),
                    child: FadingEdgeScrollView.fromScrollView(
                      child: ListView.separated(
                        shrinkWrap: true,
                        controller: _historyScrollController,
                        itemBuilder: (context, index) => WalletTransactionHolder(
                          transaction: transactions[index],
                          icon: Image.asset(Assets.images.ton.path),
                        ),
                        separatorBuilder: (_, __) => const Divider(height: 1, thickness: 1),
                        itemCount: transactions.length,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          orElse: () => const SizedBox(),
        ),
      );

  Widget _assetButton({
    required String asset,
    required String title,
    VoidCallback? onTap,
  }) =>
      CrystalButton.custom(
        onTap: onTap,
        configuration: const CrystalButtonConfiguration(
          backgroundColor: CrystalColor.secondary,
          textColor: CrystalColor.fontHeaderDark,
          splashColor: CrystalColor.accent,
          highlightColor: CrystalColor.accent,
          padding: EdgeInsets.symmetric(vertical: 12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              asset,
              color: CrystalColor.fontHeaderDark,
            ),
            const Flexible(child: CrystalDivider(width: 12, minWidth: 4)),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
}
