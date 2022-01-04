import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../../../domain/blocs/token_wallet/token_wallet_info_bloc.dart';
import '../../../../../../../../../../domain/blocs/token_wallet/token_wallet_transactions_bloc.dart';
import '../../../../../../../../../../injection.dart';
import '../../../../../../domain/blocs/key/keys_bloc.dart';
import '../../../../../../domain/blocs/ton_wallet/ton_wallet_info_bloc.dart';
import '../../../../../design/design.dart';
import '../../../../../design/widgets/address_generated_icon.dart';
import '../../../../../design/widgets/custom_close_button.dart';
import '../../../../../design/widgets/preload_transactions_listener.dart';
import '../../../../../design/widgets/token_asset_icon.dart';
import '../../../../../design/widgets/wallet_action_button.dart';
import '../../history/token_wallet_transaction_holder.dart';
import '../receive_modal/show_receive_modal.dart';
import '../token_send_transaction_flow/start_token_send_transaction_flow.dart';

class TokenAssetInfoModalBody extends StatefulWidget {
  final String owner;
  final String rootTokenContract;
  final String? icon;

  const TokenAssetInfoModalBody({
    Key? key,
    required this.owner,
    required this.rootTokenContract,
    this.icon,
  }) : super(key: key);

  @override
  _TokenAssetInfoModalBodyState createState() => _TokenAssetInfoModalBodyState();
}

class _TokenAssetInfoModalBodyState extends State<TokenAssetInfoModalBody> {
  final tonWalletInfoBloc = getIt.get<TonWalletInfoBloc>();
  final tokenWalletInfoBloc = getIt.get<TokenWalletInfoBloc>();
  final tokenWalletTransactionsBloc = getIt.get<TokenWalletTransactionsBloc>();

  @override
  void initState() {
    super.initState();
    tonWalletInfoBloc.add(
      TonWalletInfoEvent.load(widget.owner),
    );
    tokenWalletInfoBloc.add(
      TokenWalletInfoEvent.load(
        owner: widget.owner,
        rootTokenContract: widget.rootTokenContract,
      ),
    );
    tokenWalletTransactionsBloc.add(
      TokenWalletTransactionsEvent.load(
        owner: widget.owner,
        rootTokenContract: widget.rootTokenContract,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant TokenAssetInfoModalBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.owner != widget.owner || oldWidget.rootTokenContract != widget.rootTokenContract) {
      tonWalletInfoBloc.add(
        TonWalletInfoEvent.load(widget.owner),
      );
      tokenWalletInfoBloc.add(
        TokenWalletInfoEvent.load(
          owner: widget.owner,
          rootTokenContract: widget.rootTokenContract,
        ),
      );
      tokenWalletTransactionsBloc.add(
        TokenWalletTransactionsEvent.load(
          owner: widget.owner,
          rootTokenContract: widget.rootTokenContract,
        ),
      );
    }
  }

  @override
  void dispose() {
    tonWalletInfoBloc.close();
    tokenWalletInfoBloc.close();
    tokenWalletTransactionsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<TokenWalletInfoBloc, TokenWalletInfo?>(
        bloc: tokenWalletInfoBloc,
        builder: (context, state) => state != null
            ? Material(
                color: Colors.white,
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      header(
                        owner: state.owner,
                        balance: state.balance,
                        contractState: state.contractState,
                        symbol: state.symbol,
                      ),
                      Expanded(
                        child: history(symbol: state.symbol),
                      ),
                    ],
                  ),
                ),
              )
            : const SizedBox(),
      );

  Widget header({
    required String owner,
    required String balance,
    required ContractState contractState,
    required Symbol symbol,
  }) =>
      Container(
        padding: const EdgeInsets.all(16),
        color: CrystalColor.accentBackground,
        child: Column(
          children: [
            info(
              balance: balance,
              symbol: symbol,
            ),
            const SizedBox(height: 24),
            actions(
              owner: owner,
              symbol: symbol,
            ),
          ],
        ),
      );

  Widget info({
    required String balance,
    required Symbol symbol,
  }) =>
      Row(
        children: [
          icon(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                balanceText(
                  balance: balance,
                  symbol: symbol,
                ),
                const SizedBox(height: 4),
                nameText(symbol),
              ],
            ),
          ),
          const CustomCloseButton(),
        ],
      );

  Widget icon() => widget.icon != null
      ? TokenAssetIcon(
          icon: widget.icon!,
        )
      : AddressGeneratedIcon(
          address: widget.rootTokenContract,
        );

  Widget balanceText({
    required String balance,
    required Symbol symbol,
  }) =>
      Text(
        '${balance.toTokens(symbol.decimals).removeZeroes().formatValue()} ${symbol.name}',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      );

  Widget nameText(Symbol symbol) => Text(
        symbol.fullName,
        style: const TextStyle(
          fontSize: 16,
        ),
      );

  Widget actions({
    required String owner,
    required Symbol symbol,
  }) =>
      BlocBuilder<KeysBloc, KeysState>(
        bloc: context.watch<KeysBloc>(),
        builder: (context, keysState) => BlocBuilder<TonWalletInfoBloc, TonWalletInfo?>(
          bloc: tonWalletInfoBloc,
          builder: (context, tonWalletInfoState) {
            final receiveButton = WalletActionButton(
              icon: Assets.images.iconReceive,
              title: LocaleKeys.actions_receive.tr(),
              onPressed: () => showReceiveModal(
                context: context,
                address: owner,
              ),
            );

            WalletActionButton? actionButton;

            if (keysState.currentKey != null && tonWalletInfoState != null) {
              final publicKey = keysState.currentKey!.publicKey;

              final keys = [
                ...keysState.keys.keys,
                ...keysState.keys.values.whereNotNull().expand((e) => e),
              ];
              final publicKeys =
                  tonWalletInfoState.custodians?.where((e) => keys.any((el) => el.publicKey == e)).toList() ??
                      [publicKey];

              actionButton = WalletActionButton(
                icon: Assets.images.iconSend,
                title: LocaleKeys.actions_send.tr(),
                onPressed: () => startTokenSendTransactionFlow(
                  context: context,
                  owner: owner,
                  rootTokenContract: symbol.rootTokenContract,
                  publicKeys: publicKeys,
                ),
              );
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
        ),
      );

  Widget history({
    required Symbol symbol,
  }) =>
      BlocBuilder<TokenWalletTransactionsBloc, List<TokenWalletTransactionWithData>>(
        bloc: tokenWalletTransactionsBloc,
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
                  list(
                    state: state,
                    symbol: symbol,
                  ),
                  loader(),
                ],
              ),
            ),
          ],
        ),
      );

  Widget historyTitle(List<TokenWalletTransactionWithData> state) => Padding(
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

  Widget list({
    required List<TokenWalletTransactionWithData> state,
    required Symbol symbol,
  }) =>
      RawScrollbar(
        thickness: 4,
        minThumbLength: 48,
        thumbColor: CrystalColor.secondary,
        radius: const Radius.circular(8),
        controller: ModalScrollController.of(context),
        child: PreloadTransactionsListener(
          prevTransactionId: state.lastOrNull?.transaction.prevTransactionId,
          onLoad: () => tokenWalletTransactionsBloc.add(const TokenWalletTransactionsEvent.preload()),
          child: ListView.separated(
            controller: ModalScrollController.of(context),
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) => TokenWalletTransactionHolder(
              transactionWithData: state[index],
              currency: symbol.name,
              decimals: symbol.decimals,
              icon: icon(),
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
        stream: tokenWalletTransactionsBloc.sideEffectsStream,
        builder: (context, snapshot) => IgnorePointer(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: !(snapshot.data ?? false)
                ? const SizedBox()
                : Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black12,
                    child: Center(
                      child: PlatformCircularProgressIndicator(),
                    ),
                  ),
          ),
        ),
      );
}
