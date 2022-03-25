import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../data/extensions.dart';
import '../../../../../providers/account/account_assets_provider.dart';
import '../../../common/theme.dart';
import 'token_wallet_asset_holder.dart';
import 'ton_wallet_asset_holder.dart';

class AllAssetsLayout extends StatefulWidget {
  final String address;
  final ScrollController controller;

  const AllAssetsLayout({
    Key? key,
    required this.address,
    required this.controller,
  }) : super(key: key);

  @override
  _AllAssetsLayoutState createState() => _AllAssetsLayoutState();
}

class _AllAssetsLayoutState extends State<AllAssetsLayout> {
  @override
  Widget build(BuildContext context) => Consumer(
        builder: (context, ref, child) {
          final accountAssets = ref.watch(accountAssetsProvider(widget.address)).asData?.value;

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
                    controller: widget.controller,
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
