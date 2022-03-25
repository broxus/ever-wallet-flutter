import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../../../generated/assets.gen.dart';
import '../theme.dart';

class WalletActionButton extends StatelessWidget {
  final SvgGenImage icon;
  final String title;
  final void Function()? onPressed;

  const WalletActionButton({
    Key? key,
    required this.icon,
    required this.title,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => PlatformWidget(
        cupertino: (_, __) => CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onPressed,
          child: Container(
            width: double.infinity,
            height: 40,
            alignment: Alignment.center,
            color: CrystalColor.secondary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon.svg(
                  color: CrystalColor.actionButtonDark,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: CrystalColor.actionButtonDark,
                    fontFamily: Theme.of(context).textTheme.button?.fontFamily,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        material: (_, __) => ElevatedButton(
          onPressed: onPressed,
          style: ButtonStyle(
            padding: MaterialStateProperty.all(const EdgeInsets.all(12)),
            elevation: MaterialStateProperty.all(0),
            shape: MaterialStateProperty.all(const BeveledRectangleBorder()),
            foregroundColor: MaterialStateProperty.all(CrystalColor.actionButtonDark),
            backgroundColor: MaterialStateProperty.resolveWith(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.disabled)) {
                  return CrystalColor.secondary.withOpacity(0.5);
                }

                return CrystalColor.secondary;
              },
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon.svg(
                color: CrystalColor.actionButtonDark,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );
}
