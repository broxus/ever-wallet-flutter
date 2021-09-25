import 'package:collection/collection.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../domain/blocs/token_wallet/token_wallet_info_bloc.dart';
import '../../../../../domain/blocs/token_wallet/token_wallet_transactions_bloc.dart';
import '../../../../../injection.dart';
import '../../../../design/design.dart';
import '../../../../design/utils.dart';
import '../../../../design/widget/crystal_bottom_sheet.dart';
import '../../../../design/widget/preload_transactions_listener.dart';
import '../../history/transaction_holder.dart';
import '../receive_modal.dart';
import '../token_send_transaction_flow/token_send_transaction_flow.dart';

class TokenAssetObserver extends StatefulWidget {
  final String owner;
  final String rootTokenContract;

  const TokenAssetObserver._({
    Key? key,
    required this.owner,
    required this.rootTokenContract,
  }) : super(key: key);

  static Future<void> open({
    required BuildContext context,
    required String owner,
    required String rootTokenContract,
    String? logoURI,
  }) =>
      showCrystalBottomSheet(
        context,
        expand: false,
        padding: EdgeInsets.zero,
        avoidBottomInsets: false,
        barrierColor: CrystalColor.modalBackground.withOpacity(0.7),
        body: TokenAssetObserver._(
          owner: owner,
          rootTokenContract: rootTokenContract,
        ),
      );

  @override
  _TokenAssetObserverState createState() => _TokenAssetObserverState();
}

class _TokenAssetObserverState extends State<TokenAssetObserver> {
  final _historyScrollController = ScrollController();
  late final TokenWalletInfoBloc tokenWalletInfoBloc;
  late final TokenWalletTransactionsBloc tokenWalletTransactionsBloc;

  @override
  void initState() {
    super.initState();
    tokenWalletInfoBloc = getIt.get<TokenWalletInfoBloc>(
      param1: widget.owner,
      param2: widget.rootTokenContract,
    );
    tokenWalletTransactionsBloc = getIt.get<TokenWalletTransactionsBloc>(
      param1: widget.owner,
      param2: widget.rootTokenContract,
    );
  }

  @override
  void dispose() {
    _historyScrollController.dispose();
    tokenWalletInfoBloc.close();
    tokenWalletTransactionsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<TokenWalletInfoBloc, TokenWalletInfoState>(
        bloc: tokenWalletInfoBloc,
        builder: (context, state) => state.maybeWhen(
          ready: (logoURI, address, balance, contractState, owner, symbol, version, ownerPublicKey) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(
                logoURI: logoURI,
                owner: owner,
                balance: balance,
                contractState: contractState,
                symbol: symbol,
                ownerPublicKey: ownerPublicKey,
              ),
              Flexible(
                child: _history(
                  symbol: symbol,
                ),
              ),
            ],
          ),
          orElse: () => const SizedBox(),
        ),
      );

  Widget _header({
    required String? logoURI,
    required String owner,
    required String balance,
    required ContractState contractState,
    required Symbol symbol,
    required String ownerPublicKey,
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
                    child: logoURI != null ? getTokenAssetIcon(logoURI) : getRandomTokenAssetIcon(symbol.name.hashCode),
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
                          formatValue(balance),
                          style: const TextStyle(
                            fontSize: 20,
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w700,
                            color: CrystalColor.fontDark,
                          ),
                        ),
                      ),
                      const CrystalDivider(height: 4),
                      SizedBox(
                        height: 20,
                        child: Text(
                          symbol.symbol,
                          style: const TextStyle(
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
              owner: owner,
              symbol: symbol,
              isDeployed: contractState.isDeployed,
              ownerPublicKey: ownerPublicKey,
            ),
          ],
        ),
      );

  Widget _headerActions({
    required String owner,
    required Symbol symbol,
    required bool isDeployed,
    required String ownerPublicKey,
  }) =>
      AnimatedSwitcher(
        duration: kThemeAnimationDuration,
        child: Row(
          children: [
            Expanded(
              child: _assetButton(
                asset: Assets.images.iconReceive.path,
                title: LocaleKeys.actions_receive.tr(),
                onTap: () => showCrystalBottomSheet(
                  context,
                  body: ReceiveModalBody(
                    textAsTitle: true,
                    address: owner,
                  ),
                ),
              ),
            ),
            const CrystalDivider(width: 10),
            Expanded(
              child: _assetButton(
                onTap: () => TokenSendTransactionFlow.start(
                  context: context,
                  owner: owner,
                  rootTokenContract: symbol.rootTokenContract,
                  ownerPublicKey: ownerPublicKey,
                ),
                asset: Assets.images.iconSend.path,
                title: LocaleKeys.actions_send.tr(),
              ),
            ),
          ],
        ),
      );

  Widget _history({
    required Symbol symbol,
  }) =>
      BlocBuilder<TokenWalletTransactionsBloc, TokenWalletTransactionsState>(
        bloc: tokenWalletTransactionsBloc,
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
                    onLoad: () =>
                        tokenWalletTransactionsBloc.add(const TokenWalletTransactionsEvent.preloadTransactions()),
                    child: FadingEdgeScrollView.fromScrollView(
                      child: ListView.separated(
                        shrinkWrap: true,
                        controller: _historyScrollController,
                        itemBuilder: (context, index) => WalletTransactionHolder(
                          transaction: transactions[index],
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