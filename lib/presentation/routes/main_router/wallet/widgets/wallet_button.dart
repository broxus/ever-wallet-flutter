import 'package:flutter/material.dart';

import '../../../../design/design.dart';

class WalletButton extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final Widget icon;

  const WalletButton({
    Key? key,
    this.onTap,
    required this.title,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 56),
        child: Column(
          children: [
            Container(
              height: 56,
              width: 56,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                shape: const CircleBorder(),
                color: CrystalColor.secondary.withOpacity(0.16),
              ),
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: onTap,
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: icon,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                letterSpacing: 0.8,
                color: CrystalColor.secondary,
              ),
            ),
          ],
        ),
      );
}
