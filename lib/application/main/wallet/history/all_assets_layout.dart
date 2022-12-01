import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/async_value_stream_provider.dart';
import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/application/main/wallet/history/token_wallet_asset_holder.dart';
import 'package:ever_wallet/application/main/wallet/history/ton_wallet_asset_holder.dart';
import 'package:ever_wallet/data/extensions.dart';
import 'package:ever_wallet/data/models/token_contract_asset.dart';
import 'package:ever_wallet/data/repositories/ton_assets_repository.dart';
import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class AllAssetsLayout extends StatelessWidget {
  final String address;
  final ScrollController controller;

  const AllAssetsLayout({
    super.key,
    required this.address,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) =>
      AsyncValueStreamProvider<Tuple2<TonWalletAsset, List<TokenContractAsset>>>(
        create: (context) => context.read<TonAssetsRepository>().accountAssets(address),
        builder: (context, child) {
          final accountAssets = context
              .watch<AsyncValue<Tuple2<TonWalletAsset, List<TokenContractAsset>>>>()
              .maybeWhen(
                ready: (value) => value,
                orElse: () => null,
              );

          final tonWalletAsset = accountAssets?.item1;
          final tokenContractAssets = accountAssets?.item2 ?? [];

          final list = [
            if (tonWalletAsset != null)
              TonWalletAssetHolder(
                key: ValueKey(tonWalletAsset.address),
                address: tonWalletAsset.address,
              ),
            if (tonWalletAsset != null)
              ...tokenContractAssets
                  .map(
                    (tokenContractAsset) => TokenWalletAssetHolder(
                      key: ValueKey(tokenContractAsset.address),
                      owner: tonWalletAsset.address,
                      rootTokenContract: tokenContractAsset.address,
                      name: tokenContractAsset.name,
                      symbol: tokenContractAsset.symbol,
                      decimals: tokenContractAsset.decimals,
                      version: tokenContractAsset.version.toTokenWalletVersion(),
                      logoURI: tokenContractAsset.logoURI,
                    ),
                  )
                  .toList(),
          ];

          return AnimatedSwitcher(
            duration: kThemeAnimationDuration,
            child: list.isNotEmpty
                ? ListView.separated(
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    controller: controller,
                    itemCount: list.length,
                    separatorBuilder: (_, __) => Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      color: CrystalColor.divider,
                    ),
                    itemBuilder: (context, index) => list[index],
                  )
                : const SizedBox(),
          );
        },
      );
}
