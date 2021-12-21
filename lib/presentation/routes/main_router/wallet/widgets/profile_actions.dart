import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../domain/blocs/account/account_info_bloc.dart';
import '../../../../../../../../domain/blocs/ton_wallet/ton_wallet_info_bloc.dart';
import '../../../../../../../../injection.dart';
import '../../../../../domain/blocs/key/keys_bloc.dart';
import '../../../../design/design.dart';
import '../modals/add_asset_modal/show_add_asset_modal.dart';
import '../modals/deploy_wallet_flow/start_deploy_wallet_flow.dart';
import '../modals/receive_modal/show_receive_modal.dart';
import '../modals/send_transaction_flow/start_send_transaction_flow.dart';
import 'wallet_button.dart';

class ProfileActions extends StatefulWidget {
  final String address;

  const ProfileActions({
    Key? key,
    required this.address,
  }) : super(key: key);

  @override
  _ProfileActionsState createState() => _ProfileActionsState();
}

class _ProfileActionsState extends State<ProfileActions> {
  final tonWalletInfoBloc = getIt.get<TonWalletInfoBloc>();
  final accountInfoBloc = getIt.get<AccountInfoBloc>();

  @override
  void initState() {
    super.initState();
    tonWalletInfoBloc.add(TonWalletInfoEvent.load(widget.address));
    accountInfoBloc.add(AccountInfoEvent.load(widget.address));
  }

  @override
  void didUpdateWidget(covariant ProfileActions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.address != widget.address) {
      tonWalletInfoBloc.add(TonWalletInfoEvent.load(widget.address));
      accountInfoBloc.add(AccountInfoEvent.load(widget.address));
    }
  }

  @override
  void dispose() {
    tonWalletInfoBloc.close();
    accountInfoBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          WalletButton(
            onTap: () async => showAddAssetModal(
              context: context,
              address: widget.address,
            ),
            title: LocaleKeys.wallet_screen_actions_add_asset.tr(),
            icon: const OverflowBox(
              maxHeight: 30,
              maxWidth: 30,
              child: Center(
                child: Icon(
                  Icons.add,
                  size: 30,
                  color: CrystalColor.secondary,
                ),
              ),
            ),
          ),
          BlocBuilder<AccountInfoBloc, AssetsList?>(
            bloc: accountInfoBloc,
            builder: (context, state) => WalletButton(
              onTap: state != null
                  ? () => showReceiveModal(
                        context: context,
                        address: state.address,
                      )
                  : null,
              title: LocaleKeys.actions_receive.tr(),
              icon: Assets.images.iconReceive.svg(
                color: CrystalColor.secondary,
              ),
            ),
          ),
          BlocBuilder<KeysBloc, KeysState>(
            bloc: context.watch<KeysBloc>(),
            builder: (context, keysState) => BlocBuilder<TonWalletInfoBloc, TonWalletInfo?>(
              bloc: tonWalletInfoBloc,
              builder: (context, infoState) {
                final publicKey = keysState.currentKey?.publicKey;
                final isCustodian = infoState?.custodians?.any((e) => e == publicKey) ?? false;
                final requiresSeparateDeploy = infoState?.details.requiresSeparateDeploy ?? false;
                final isDeployed = infoState?.contractState.isDeployed ?? false;

                if (publicKey != null && isCustodian) {
                  if (!requiresSeparateDeploy || isDeployed) {
                    return WalletButton(
                      onTap: () => startSendTransactionFlow(
                        context: context,
                        address: widget.address,
                        publicKey: publicKey,
                      ),
                      title: LocaleKeys.actions_send.tr(),
                      icon: Assets.images.iconSend.svg(
                        color: CrystalColor.secondary,
                      ),
                    );
                  } else {
                    return WalletButton(
                      onTap: () => startDeployWalletFlow(
                        context: context,
                        address: widget.address,
                        publicKey: publicKey,
                      ),
                      title: LocaleKeys.actions_deploy.tr(),
                      icon: Assets.images.iconDeploy.svg(
                        color: CrystalColor.secondary,
                      ),
                    );
                  }
                } else {
                  return WalletButton(
                    onTap: () {},
                    title: LocaleKeys.actions_send.tr(),
                    icon: Assets.images.iconSend.svg(
                      color: CrystalColor.secondary,
                    ),
                  );
                }
              },
            ),
          ),
        ],
      );
}
