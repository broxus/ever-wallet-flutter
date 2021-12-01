import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../../../injection.dart';
import '../../../../../../domain/blocs/ton_wallet/ton_wallet_info_bloc.dart';
import '../../../../../../domain/blocs/ton_wallet/ton_wallet_transactions_bloc.dart';
import '../../../../../../domain/models/ton_wallet_info.dart';
import '../../../../../design/design.dart';
import '../../../../../design/widgets/custom_close_button.dart';
import '../../../../../design/widgets/preload_transactions_listener.dart';
import '../../../../../design/widgets/ton_asset_icon.dart';
import '../../../../../design/widgets/wallet_action_button.dart';
import '../../../main_router_page.dart';
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

  @override
  void initState() {
    super.initState();
    infoBloc.add(
      TonWalletInfoEvent.load(widget.address),
    );
    transactionsBloc.add(
      TonWalletTransactionsEvent.load(widget.address),
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
    }
  }

  @override
  void dispose() {
    infoBloc.close();
    transactionsBloc.close();
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
                context: mainRouterPageKey.currentContext ?? context,
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
                        context: mainRouterPageKey.currentContext ?? context,
                        address: widget.address,
                      )
                  : () => startDeployWalletFlow(
                        context: mainRouterPageKey.currentContext ?? context,
                        address: widget.address,
                      ),
            ),
          ),
        ],
      );

  Widget history() => BlocBuilder<TonWalletTransactionsBloc, List<TonWalletTransactionWithData>>(
        bloc: transactionsBloc,
        builder: (context, state) => Column(
          children: [
            historyTitle(state),
            const Divider(
              height: 1,
              thickness: 1,
            ),
            Flexible(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  list(state),
                  loader(),
                ],
              ),
            ),
          ],
        ),
      );

  Widget historyTitle(List<TonWalletTransactionWithData> state) => Padding(
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
            if (state.isEmpty)
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

  Widget list(List<TonWalletTransactionWithData> state) => RawScrollbar(
        thickness: 4,
        minThumbLength: 48,
        thumbColor: CrystalColor.secondary,
        radius: const Radius.circular(8),
        controller: ModalScrollController.of(context),
        child: PreloadTransactionsListener(
          prevTransactionId: state.lastOrNull?.transaction.prevTransactionId,
          onLoad: () => transactionsBloc.add(const TonWalletTransactionsEvent.preload()),
          child: ListView.separated(
            controller: ModalScrollController.of(context),
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) => TonWalletTransactionHolder(
              transactionWithData: state[index],
            ),
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              thickness: 1,
            ),
            itemCount: state.length,
          ),
        ),
      );

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
