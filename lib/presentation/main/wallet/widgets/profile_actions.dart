import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../providers/account/account_info_provider.dart';
import '../../../../../providers/key/current_key_provider.dart';
import '../../../../../providers/key/keys_provider.dart';
import '../../../../../providers/ton_wallet/ton_wallet_info_provider.dart';
import '../../../../generated/assets.gen.dart';
import '../../../common/theme.dart';
import '../modals/add_asset_modal/show_add_asset_modal.dart';
import '../modals/deploy_wallet_flow/start_deploy_wallet_flow.dart';
import '../modals/receive_modal/show_receive_modal.dart';
import '../modals/send_transaction_flow/start_send_transaction_flow.dart';
import 'wallet_button.dart';

class ProfileActions extends StatelessWidget {
  final String address;

  const ProfileActions({
    Key? key,
    required this.address,
  }) : super(key: key);

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
          Consumer(
            builder: (context, ref, child) {
              final value = ref.watch(accountInfoProvider(address)).asData?.value;

              return WalletButton(
                onTap: value != null
                    ? () => showReceiveModal(
                          context: context,
                          address: value.address,
                        )
                    : null,
                title: AppLocalizations.of(context)!.receive,
                icon: Assets.images.iconReceive.svg(
                  color: CrystalColor.secondary,
                ),
              );
            },
          ),
          Consumer(
            builder: (context, ref, child) {
              final keys = ref.watch(keysProvider).asData?.value ?? {};
              final currentKey = ref.watch(currentKeyProvider).asData?.value;
              final tonWalletInfo = ref.watch(tonWalletInfoProvider(address)).asData?.value;

              if (currentKey != null && tonWalletInfo != null) {
                final requiresSeparateDeploy = tonWalletInfo.details.requiresSeparateDeploy;

                if (!requiresSeparateDeploy) {
                  return WalletButton(
                    onTap: () => startSendTransactionFlow(
                      context: context,
                      address: address,
                      publicKeys: [tonWalletInfo.publicKey],
                    ),
                    title: AppLocalizations.of(context)!.send,
                    icon: Assets.images.iconSend.svg(
                      color: CrystalColor.secondary,
                    ),
                  );
                }

                final isDeployed = tonWalletInfo.contractState.isDeployed;

                if (isDeployed) {
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

                  return WalletButton(
                    onTap: publicKeys.isNotEmpty
                        ? () => startSendTransactionFlow(
                              context: context,
                              address: address,
                              publicKeys: publicKeys,
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
                      publicKey: tonWalletInfo.publicKey,
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
          ),
        ],
      );
}
