import 'package:flutter/material.dart';

import '../../../common/theme.dart';

class WalletAssetHolder extends StatelessWidget {
  final Widget icon;
  final String balance;
  final String balanceUsdt;
  final VoidCallback onTap;

  const WalletAssetHolder({
    Key? key,
    required this.icon,
    required this.balance,
    required this.balanceUsdt,
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
                leading(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      title(),
                      const SizedBox(height: 4),
                      subtitle(),
                    ],
                  ),
                ),
                arrow()
              ],
            ),
          ),
        ),
      );

  Widget leading() => icon;

  Widget title() => Text(
        balance,
        style: const TextStyle(
          fontSize: 18,
          letterSpacing: 0.5,
          fontWeight: FontWeight.w700,
          color: CrystalColor.fontDark,
        ),
      );

  Widget subtitle() => Text(
        balanceUsdt,
        style: const TextStyle(
          fontSize: 14,
          letterSpacing: 0.75,
          color: CrystalColor.fontSecondaryDark,
        ),
      );

  Widget arrow() => const Icon(
        Icons.arrow_forward_ios,
        color: CrystalColor.icon,
        size: 14,
      );
}
