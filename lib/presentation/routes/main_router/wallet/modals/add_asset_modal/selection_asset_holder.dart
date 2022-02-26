import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../../../../../../data/extensions.dart';
import '../../../../../../data/models/token_contract_asset.dart';
import '../../../../../design/design.dart';
import '../../../../../design/widgets/marquee_widget.dart';
import '../../../../../design/widgets/token_address_generated_icon.dart';
import '../../../../../design/widgets/token_asset_icon.dart';

class SelectionAssetHolder extends StatelessWidget {
  final TokenContractAsset asset;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectionAssetHolder({
    Key? key,
    required this.asset,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ListTile(
        onTap: onTap,
        leading: icon(),
        title: name(),
        subtitle: fullName(),
        trailing: assetSwitch(),
      );

  Widget icon() => asset.logoURI != null
      ? TokenAssetIcon(
          logoURI: asset.logoURI!,
          version: tokenWalletVersionFromInt(asset.version),
        )
      : TokenAddressGeneratedIcon(
          address: asset.address,
          version: tokenWalletVersionFromInt(asset.version),
        );

  Widget name() => MarqueeWidget(
        child: Text(
          asset.symbol.replaceAll('-', nonBreakingHyphen),
          maxLines: 1,
          style: const TextStyle(
            fontSize: 16,
            letterSpacing: 0.75,
            fontWeight: FontWeight.w700,
            color: CrystalColor.fontDark,
          ),
        ),
      );

  Widget fullName() => MarqueeWidget(
        child: Text(
          asset.name.replaceAll('-', nonBreakingHyphen),
          maxLines: 1,
          style: const TextStyle(
            fontSize: 14,
            letterSpacing: 0.75,
            color: CrystalColor.fontSecondaryDark,
          ),
        ),
      );

  Widget assetSwitch() => IgnorePointer(
        child: PlatformSwitch(
          value: isSelected,
          onChanged: (_) {},
        ),
      );
}
