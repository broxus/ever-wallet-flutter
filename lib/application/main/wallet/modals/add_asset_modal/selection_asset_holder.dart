import 'package:ever_wallet/application/common/constants.dart';
import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/application/common/widgets/marquee_widget.dart';
import 'package:ever_wallet/application/common/widgets/token_address_generated_icon.dart';
import 'package:ever_wallet/application/common/widgets/token_asset_icon.dart';
import 'package:ever_wallet/data/extensions.dart';
import 'package:ever_wallet/data/models/token_contract_asset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

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
          version: asset.version.toTokenWalletVersion(),
        )
      : TokenAddressGeneratedIcon(
          address: asset.address,
          version: asset.version.toTokenWalletVersion(),
        );

  Widget name() => MarqueeWidget(
        child: Text(
          asset.symbol.replaceAll('-', kNonBreakingHyphen),
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
          asset.name.replaceAll('-', kNonBreakingHyphen),
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
