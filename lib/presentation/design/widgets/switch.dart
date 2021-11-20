import 'package:flutter/material.dart';

import '../../../../../../generated/assets.gen.dart';
import '../theme.dart';
import 'badge.dart';

const _kSwitchAnimationDuration = Duration(milliseconds: 150);

class CrystalSwitch extends StatelessWidget {
  const CrystalSwitch({
    Key? key,
    required this.isActive,
    this.onTap,
  }) : super(key: key);

  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          width: 44,
          duration: _kSwitchAnimationDuration,
          alignment: isActive ? Alignment.centerRight : Alignment.centerLeft,
          padding: const EdgeInsets.all(2),
          decoration: ShapeDecoration(
            shape: const StadiumBorder(),
            color: isActive ? CrystalColor.success : CrystalColor.icon.withOpacity(onTap != null ? 1 : 0.5),
          ),
          child: CircleIcon(
            color: CrystalColor.primary,
            size: 24,
            icon: AnimatedOpacity(
              duration: _kSwitchAnimationDuration * (isActive ? 1 : 0.75),
              opacity: isActive ? 1 : 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6, 6, 4.5, 6),
                child: Image.asset(
                  Assets.images.iconDone.path,
                  color: CrystalColor.success,
                ),
              ),
            ),
          ),
        ),
      );
}
