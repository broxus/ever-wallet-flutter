import 'package:flutter/material.dart';

import '../../../../../domain/models/token_contract_asset.dart';
import '../../../../design/design.dart';
import '../../../../design/widget/asset_icon.dart';

class SelectionAssetHolder extends StatelessWidget {
  final TokenContractAsset asset;
  final bool? isSelected;
  final VoidCallback? onTap;

  const SelectionAssetHolder({
    Key? key,
    required this.asset,
    this.isSelected,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Material(
        type: MaterialType.card,
        color: CrystalColor.primary,
        child: CrystalInkWell(
          onTap: onTap,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
            child: Row(
              children: [
                CircleIcon(
                  color: Colors.transparent,
                  icon: Padding(
                    padding: const EdgeInsets.all(8),
                    child: AssetIcon(
                      svgIcon: asset.svgIcon,
                      gravatarIcon: asset.gravatarIcon,
                    ),
                  ),
                ),
                const CrystalDivider(width: 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
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
                      ),
                      const CrystalDivider(height: 2),
                      SizedBox(
                        height: 20,
                        child: Text(
                          asset.name,
                          style: const TextStyle(
                            fontSize: 14,
                            letterSpacing: 0.75,
                            color: CrystalColor.fontSecondaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected != null)
                  IgnorePointer(
                    child: CrystalSwitch(
                      isActive: isSelected!,
                      onTap: () {},
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
}
