import 'package:flutter/material.dart';

import '../../../generated/assets.gen.dart';
import '../theme.dart';

class CrystalCheckbox extends StatelessWidget {
  final bool? value;
  final bool tristate;
  final bool alwaysShowSelection;
  final Function(bool?)? onChanged;

  const CrystalCheckbox({
    Key? key,
    required this.value,
    this.tristate = false,
    this.alwaysShowSelection = false,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onChanged != null ? onTap : null,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: kThemeAnimationDuration,
          width: 18,
          height: 18,
          decoration: BoxDecoration(
              color: value ?? true
                  ? CrystalColor.accent
                  : alwaysShowSelection
                      ? CrystalColor.secondary
                      : CrystalColor.primary,
              border: value == false && !alwaysShowSelection ? Border.all(color: CrystalColor.icon) : const Border()),
          child: AnimatedSwitcher(
            duration: kThemeAnimationDuration,
            child: icon,
          ),
        ),
      );

  Widget get icon {
    String? asset;

    if (value == null) {
      asset = Assets.images.iconMinus.path;
    } else if (value == true || alwaysShowSelection) {
      asset = Assets.images.iconDone.path;
    }

    if (asset != null) {
      return Image.asset(
        asset,
        color: CrystalColor.primary,
        width: 10,
        key: UniqueKey(),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  void onTap() {
    switch (value) {
      case false:
        onChanged!(true);
        break;
      case true:
        onChanged!(tristate ? null : false);
        break;
      case null:
        onChanged!(false);
        break;
    }
  }
}
