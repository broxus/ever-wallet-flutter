import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../design.dart';

class CustomElevatedButton extends StatelessWidget {
  final void Function()? onPressed;
  final String text;

  const CustomElevatedButton({
    Key? key,
    required this.onPressed,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: SizedBox(
          key: ValueKey(onPressed != null),
          width: double.infinity,
          child: PlatformWidget(
            cupertino: (_, __) => CupertinoButton(
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.zero,
              onPressed: onPressed,
              child: Container(
                padding: const EdgeInsets.all(12),
                color: onPressed != null ? CrystalColor.accent : CrystalColor.accent.withOpacity(0.5),
                width: double.infinity,
                alignment: Alignment.center,
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.button?.copyWith(color: Colors.white),
                ),
              ),
            ),
            material: (_, __) => ElevatedButton(
              onPressed: onPressed,
              style: ButtonStyle(
                padding: MaterialStateProperty.all(const EdgeInsets.all(12)),
                elevation: MaterialStateProperty.all(0),
                shape: MaterialStateProperty.all(const BeveledRectangleBorder()),
                foregroundColor: MaterialStateProperty.all(Colors.white),
                backgroundColor: MaterialStateProperty.resolveWith(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.disabled)) {
                      return CrystalColor.accent.withOpacity(0.5);
                    }

                    return CrystalColor.accent;
                  },
                ),
              ),
              child: Text(text),
            ),
          ),
        ),
      );
}
