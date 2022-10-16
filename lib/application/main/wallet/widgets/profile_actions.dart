import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/async_value_stream_provider.dart';
import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/application/main/wallet/modals/add_asset_modal/show_add_asset_modal.dart';
import 'package:ever_wallet/application/main/wallet/modals/deploy_wallet_flow/start_deploy_wallet_flow.dart';
import 'package:ever_wallet/application/main/wallet/modals/receive_modal/show_receive_modal.dart';
import 'package:ever_wallet/application/main/wallet/modals/send_transaction_flow/start_send_transaction_flow.dart';
import 'package:ever_wallet/application/main/wallet/widgets/wallet_button.dart';
import 'package:ever_wallet/data/repositories/accounts_repository.dart';
import 'package:ever_wallet/data/repositories/ton_wallets_repository.dart';
import 'package:ever_wallet/generated/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:provider/provider.dart';

class ProfileActions extends StatelessWidget {
  final String address;

  const ProfileActions({
    super.key,
    required this.address,
  });

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          WalletButton(
            onTap: () async => showAddAssetModal(
              context: context,
              address: address,
            ),
            title: AppLocalizations.of(context)!.add_asset,
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
          WalletButton(
            onTap: () => showReceiveModal(
              context: context,
              address: address,
            ),
            title: AppLocalizations.of(context)!.receive,
            icon: Assets.images.iconReceive.svg(
              color: CrystalColor.secondary,
            ),
          ),
          AsyncValueStreamProvider<List<String>?>(
            create: (context) =>
                context.read<TonWalletsRepository>().localCustodiansStream(address),
            builder: (context, child) {
              final localCustodians = context.watch<AsyncValue<List<String>?>>().maybeWhen(
                    ready: (value) => value,
                    orElse: () => null,
                  );

              return AsyncValueStreamProvider<AssetsList>(
                create: (context) => context
                    .read<AccountsRepository>()
                    .accountsStream
                    .expand((e) => e)
                    .where((e) => e.address == address),
                builder: (context, child) {
                  final account = context.watch<AsyncValue<AssetsList>>().maybeWhen(
                        ready: (value) => value,
                        orElse: () => null,
                      );

                  return AsyncValueStreamProvider<TonWalletDetails>(
                    create: (context) =>
                        context.read<TonWalletsRepository>().detailsStream(address),
                    builder: (context, child) {
                      final details = context.watch<AsyncValue<TonWalletDetails>>().maybeWhen(
                            ready: (value) => value,
                            orElse: () => null,
                          );

                      return AsyncValueStreamProvider<ContractState>(
                        create: (context) =>
                            context.read<TonWalletsRepository>().contractStateStream(address),
                        builder: (context, child) {
                          final contractState =
                              context.watch<AsyncValue<ContractState>>().maybeWhen(
                                    ready: (value) => value,
                                    orElse: () => null,
                                  );

                          if (account != null && details != null && contractState != null) {
                            final requiresSeparateDeploy = details.requiresSeparateDeploy;

                            if (!requiresSeparateDeploy) {
                              return WalletButton(
                                onTap: () => startSendTransactionFlow(
                                  context: context,
                                  address: address,
                                  publicKeys: [account.publicKey],
                                ),
                                title: AppLocalizations.of(context)!.send,
                                icon: Assets.images.iconSend.svg(
                                  color: CrystalColor.secondary,
                                ),
                              );
                            }

                            final isDeployed = contractState.isDeployed;

                            if (isDeployed) {
                              return WalletButton(
                                onTap: localCustodians != null && localCustodians.isNotEmpty
                                    ? () => startSendTransactionFlow(
                                          context: context,
                                          address: address,
                                          publicKeys: localCustodians,
                                        )
                                    : null,
                                title: AppLocalizations.of(context)!.send,
                                icon: Assets.images.iconSend.svg(
                                  color: CrystalColor.secondary,
                                ),
                              );
                            } else {
                              return WalletButton(
                                onTap: () => startDeployWalletFlow(
                                  context: context,
                                  address: address,
                                  publicKey: account.publicKey,
                                ),
                                title: AppLocalizations.of(context)!.deploy,
                                icon: Assets.images.iconDeploy.svg(
                                  color: CrystalColor.secondary,
                                ),
                              );
                            }
                          } else {
                            return WalletButton(
                              title: AppLocalizations.of(context)!.send,
                              icon: Assets.images.iconSend.svg(
                                color: CrystalColor.secondary,
                              ),
                            );
                          }
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      );
}
