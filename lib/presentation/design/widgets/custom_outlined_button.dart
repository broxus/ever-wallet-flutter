import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../../design/design.dart';

class CustomOutlinedButton extends StatelessWidget {
  final void Function()? onPressed;
  final String text;

  const CustomOutlinedButton({
    Key? key,
    required this.onPressed,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: SizedBox(
          width: double.infinity,
          key: ValueKey(onPressed != null),
          child: PlatformWidget(
            cupertino: (_, __) => CupertinoButton(
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.zero,
              onPressed: onPressed,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: CrystalColor.accent,
                    width: 0.5,
                  ),
                ),
                width: double.infinity,
                alignment: Alignment.center,
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.button?.copyWith(color: CrystalColor.accent),
                ),
              ),
            ),
            material: (_, __) => OutlinedButton(
              onPressed: onPressed,
              style: ButtonStyle(
                padding: MaterialStateProperty.all(const EdgeInsets.all(12)),
                elevation: MaterialStateProperty.all(0),
                shape: MaterialStateProperty.all(
                  const BeveledRectangleBorder(
                    side: BorderSide(color: CrystalColor.accent),
                  ),
                ),
                foregroundColor: MaterialStateProperty.all(CrystalColor.accent),
                side: MaterialStateProperty.all(
                  BorderSide(
                    color: CrystalColor.accent.withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
              ),
              child: Text(text),
            ),
          ),
        ),
      );
}
