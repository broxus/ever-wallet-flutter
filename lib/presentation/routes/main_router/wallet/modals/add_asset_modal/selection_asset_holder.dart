import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../../../../../../../../../../domain/models/token_contract_asset.dart';
import '../../../../../design/design.dart';
import '../../../../../design/widgets/asset_icon.dart';

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
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
            child: Row(
              children: [
                icon(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      name(),
                      const SizedBox(height: 2),
                      fullName(),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                assetSwitch(),
              ],
            ),
          ),
        ),
      );

  Widget icon() => SizedBox.square(
        dimension: 36,
        child: AssetIcon(
          svgIcon: asset.svgIcon,
          gravatarIcon: asset.gravatarIcon,
        ),
      );

  Widget name() => SizedBox(
        height: 24,
        child: Text(
          asset.symbol,
          style: const TextStyle(
            fontSize: 18,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w700,
            color: CrystalColor.fontDark,
          ),
        ),
      );

  Widget fullName() => SizedBox(
        height: 20,
        child: Text(
          asset.name,
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
