import 'package:collection/collection.dart';
import 'package:ever_wallet/application/bloc/token_wallet/token_wallet_transactions_bloc.dart';
import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/async_value_stream_provider.dart';
import 'package:ever_wallet/application/common/extensions.dart';
import 'package:ever_wallet/application/common/general/flushbar.dart';
import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/application/common/widgets/custom_close_button.dart';
import 'package:ever_wallet/application/common/widgets/preload_transactions_listener.dart';
import 'package:ever_wallet/application/common/widgets/token_address_generated_icon.dart';
import 'package:ever_wallet/application/common/widgets/token_asset_icon.dart';
import 'package:ever_wallet/application/common/widgets/wallet_action_button.dart';
import 'package:ever_wallet/application/main/wallet/history/transactions_holders/token_wallet_transaction_holder.dart';
import 'package:ever_wallet/application/main/wallet/modals/receive_modal/show_receive_modal.dart';
import 'package:ever_wallet/application/main/wallet/modals/token_send_transaction_flow/start_token_send_transaction_flow.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/data/models/token_wallet_ordinary_transaction.dart';
import 'package:ever_wallet/data/repositories/token_wallets_repository.dart';
import 'package:ever_wallet/data/repositories/ton_wallets_repository.dart';
import 'package:ever_wallet/generated/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:gap/gap.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

class TokenAssetInfoModalBody extends StatefulWidget {
  final String owner;
  final String rootTokenContract;
  final String name;
  final String symbol;
  final int decimals;
  final TokenWalletVersion version;
  final String? logoURI;

  const TokenAssetInfoModalBody({
    super.key,
    required this.owner,
    required this.rootTokenContract,
    required this.name,
    required this.symbol,
    required this.decimals,
    required this.version,
    this.logoURI,
  });

  @override
  _TokenAssetInfoModalBodyState createState() => _TokenAssetInfoModalBodyState();
}

class _TokenAssetInfoModalBodyState extends State<TokenAssetInfoModalBody> {
  @override
  Widget build(BuildContext context) => AsyncValueStreamProvider<String>(
        create: (context) => context.read<TokenWalletsRepository>().balanceStream(
              owner: widget.owner,
              rootTokenContract: widget.rootTokenContract,
            ),
        builder: (context, child) {
          final balance = context.watch<AsyncValue<String>>().maybeWhen(
                ready: (value) => value,
                orElse: () => null,
              );

          return balance != null
              ? BlocProvider<TokenWalletTransactionsBloc>(
                  key: ValueKey('${widget.owner}_${widget.rootTokenContract}'),
                  create: (context) => TokenWalletTransactionsBloc(
                    context.read<TokenWalletsRepository>(),
                    widget.owner,
                    widget.rootTokenContract,
                  ),
                  child: BlocBuilder<TokenWalletTransactionsBloc, TokenWalletTransactionsState>(
                    builder: (context, state) {
                      final transactionsState = state.when(
                        initial: () => <TokenWalletOrdinaryTransaction>[],
                        loading: (transactions) => transactions,
                        ready: (transactions) => transactions,
                        error: (error) => <TokenWalletOrdinaryTransaction>[],
                      );

                      final loading = state.maybeWhen(
                        loading: (transactions) => true,
                        orElse: () => false,
                      );

                      return Material(
                        color: Colors.white,
                        child: SafeArea(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              header(balance),
                              Expanded(
                                child: history(
                                  transactionsState: transactionsState,
                                  loading: loading,
                                  version: widget.version,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              : const SizedBox();
        },
      );

  Widget header(String balance) => Container(
        padding: const EdgeInsets.all(16),
        color: CrystalColor.accentBackground,
        child: Column(
          children: [
            info(balance),
            const Gap(24),
            actions(),
          ],
        ),
      );

  Widget info(String balance) => Row(
        children: [
          icon(version: widget.version),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                balanceText(balance),
                const Gap(4),
                nameText(),
              ],
            ),
          ),
          const CustomCloseButton(),
        ],
      );

  Widget icon({
    required TokenWalletVersion version,
  }) =>
      widget.logoURI != null
          ? TokenAssetIcon(
              logoURI: widget.logoURI!,
              version: version,
            )
          : TokenAddressGeneratedIcon(
              address: widget.rootTokenContract,
              version: version,
            );

  Widget balanceText(String balance) => Text(
        '${balance.toTokens(widget.decimals).removeZeroes().formatValue()} ${widget.symbol}',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      );

  Widget nameText() => Text(
        widget.name,
        style: const TextStyle(
          fontSize: 16,
        ),
      );

  Widget actions() => AsyncValueStreamProvider<List<String>?>(
        create: (context) =>
            context.read<TonWalletsRepository>().localCustodiansStream(widget.owner),
        builder: (context, child) {
          final custodians = context.watch<AsyncValue<List<String>?>>().maybeWhen(
                ready: (value) => value,
                orElse: () => null,
              );

          final receiveButton = WalletActionButton(
            icon: Assets.images.iconReceive,
            title: AppLocalizations.of(context)!.receive,
            onPressed: () => showReceiveModal(
              context: context,
              address: widget.owner,
            ),
          );

          WalletActionButton? actionButton;

          if (custodians != null) {
            actionButton = WalletActionButton(
              icon: Assets.images.iconSend,
              title: AppLocalizations.of(context)!.send,
              onPressed: custodians.isNotEmpty
                  ? () => startTokenSendTransactionFlow(
                        context: context,
                        owner: widget.owner,
                        rootTokenContract: widget.rootTokenContract,
                        publicKeys: custodians,
                      )
                  : () => showFlushbar(
                        context,
                        message: context.localization.add_custodians_to_send_via_multisig,
                      ),
            );
          }

          return Row(
            children: [
              Expanded(
                child: receiveButton,
              ),
              if (actionButton != null) ...[
                const Gap(16),
                Expanded(
                  child: actionButton,
                ),
              ],
            ],
          );
        },
      );

  Widget history({
    required List<TokenWalletOrdinaryTransaction> transactionsState,
    required bool loading,
    required TokenWalletVersion version,
  }) =>
      Column(
        children: [
          historyTitle(transactionsState),
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
                  version: version,
                ),
                loader(loading: loading),
              ],
            ),
          ),
        ],
      );

  Widget historyTitle(List<TokenWalletOrdinaryTransaction> state) => Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(
              AppLocalizations.of(context)!.history,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            if (state.isEmpty)
              Text(
                AppLocalizations.of(context)!.transactions_empty,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black45,
                ),
              ),
          ],
        ),
      );

  Widget list({
    required List<TokenWalletOrdinaryTransaction> transactionsState,
    required TokenWalletVersion version,
  }) =>
      RawScrollbar(
        thickness: 4,
        minThumbLength: 48,
        thumbColor: CrystalColor.secondary,
        radius: const Radius.circular(8),
        controller: ModalScrollController.of(context),
        child: PreloadTransactionsListener(
          scrollController: ModalScrollController.of(context)!,
          onNotification: () {
            final prevTransactionLt = transactionsState.lastOrNull?.prevTransactionLt;

            if (prevTransactionLt == null) return;

            context
                .read<TokenWalletTransactionsBloc>()
                .add(TokenWalletTransactionsEvent.preload(prevTransactionLt));
          },
          child: ListView.separated(
            controller: ModalScrollController.of(context),
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) => TokenWalletTransactionHolder(
              transaction: transactionsState[index],
              currency: widget.symbol,
              decimals: widget.decimals,
              icon: icon(version: version),
            ),
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              thickness: 1,
            ),
            itemCount: transactionsState.length,
          ),
        ),
      );

  Widget loader({required bool loading}) => IgnorePointer(
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
