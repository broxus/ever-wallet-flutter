import 'package:flutter/material.dart';

import '../../../design/design.dart';
import '../../../design/utils.dart';

class WalletAssetHolder extends StatelessWidget {
  final String name;
  final String balance;
  final Widget icon;
  final VoidCallback onTap;

  const WalletAssetHolder({
    Key? key,
    required this.name,
    required this.balance,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Material(
        type: MaterialType.card,
        color: CrystalColor.primary,
        child: CrystalInkWell(
          onTap: onTap,
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
                    child: icon,
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
                          formatValue(balance),
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
                          name,
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
                const SizedBox(
                  height: 20,
                  width: 20,
                  child: Center(
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: CrystalColor.icon,
                      size: 14,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
}
