import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../domain/blocs/account/account_info_bloc.dart';
import '../../../../../../../../domain/blocs/ton_wallet/ton_wallet_info_bloc.dart';
import '../../../../../../../../injection.dart';
import '../../../../../domain/models/account.dart';
import '../../../../design/design.dart';
import '../../../../design/widgets/crystal_bottom_sheet.dart';
import '../modals/add_asset_flow/add_asset_modal.dart';
import '../modals/deploy_wallet_flow/start_deploy_wallet_flow.dart';
import '../modals/receive_modal/show_receive_modal.dart';
import '../modals/send_transaction_flow/start_send_transaction_flow.dart';
import 'wallet_button.dart';

class ProfileActions extends StatefulWidget {
  final String address;
  final bool isExternal;

  const ProfileActions({
    Key? key,
    required this.address,
    this.isExternal = false,
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
    accountInfoBloc.add(
      AccountInfoEvent.load(
        address: widget.address,
        isExternal: widget.isExternal,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant ProfileActions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.address != widget.address) {
      tonWalletInfoBloc.add(TonWalletInfoEvent.load(widget.address));
      accountInfoBloc.add(
        AccountInfoEvent.load(
          address: widget.address,
          isExternal: widget.isExternal,
        ),
      );
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
          if (!widget.isExternal)
            WalletButton(
              onTap: () async {
                await showCrystalBottomSheet(
                  context,
                  padding: EdgeInsets.zero,
                  draggable: false,
                  wrapIntoAnimatedSize: false,
                  expand: true,
                  avoidBottomInsets: false,
                  body: AddAssetModal(
                    address: widget.address,
                  ),
                );
              },
              title: LocaleKeys.wallet_screen_actions_add_asset.tr(),
              icon: const Icon(
                Icons.add,
                color: CrystalColor.secondary,
              ),
            ),
          BlocBuilder<AccountInfoBloc, Account?>(
            bloc: accountInfoBloc,
            builder: (context, state) => WalletButton(
              onTap: state != null
                  ? () => showReceiveModal(
                        context: context,
                        address: state.when(
                          internal: (assetsList) => assetsList.address,
                          external: (assetsList) => assetsList.address,
                        ),
                      )
                  : null,
              title: LocaleKeys.actions_receive.tr(),
              icon: Assets.images.iconReceive.svg(
                color: CrystalColor.secondary,
              ),
            ),
          ),
          if (!widget.isExternal)
            BlocBuilder<TonWalletInfoBloc, TonWalletInfo?>(
              bloc: tonWalletInfoBloc,
              builder: (context, state) => state != null
                  ? !state.details.requiresSeparateDeploy || state.contractState.isDeployed
                      ? WalletButton(
                          onTap: () => startSendTransactionFlow(
                            context: context,
                            address: state.address,
                          ),
                          title: LocaleKeys.actions_send.tr(),
                          icon: Assets.images.iconSend.svg(
                            color: CrystalColor.secondary,
                          ),
                        )
                      : WalletButton(
                          onTap: () => startDeployWalletFlow(
                            context: context,
                            address: state.address,
                          ),
                          title: LocaleKeys.actions_deploy.tr(),
                          icon: Assets.images.iconDeploy.svg(
                            color: CrystalColor.secondary,
                          ),
                        )
                  : const SizedBox.square(dimension: 56),
            ),
        ],
      );
}
