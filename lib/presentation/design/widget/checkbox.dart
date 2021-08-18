import 'package:flutter/material.dart';

import '../../../generated/assets.gen.dart';
import '../theme.dart';

class CrystalCheckbox extends StatelessWidget {
  const CrystalCheckbox({
    Key? key,
    required this.value,
    this.tristate = false,
    this.alwaysShowSelection = false,
    this.onChanged,
  }) : super(key: key);

  final bool? value;
  final bool tristate;
  final bool alwaysShowSelection;
  final Function(bool?)? onChanged;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onChanged != null ? _onTap : null,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: kThemeAnimationDuration,
          width: 18.0,
          height: 18.0,
          decoration: BoxDecoration(
              color: value ?? true
                  ? CrystalColor.accent
                  : alwaysShowSelection
                      ? CrystalColor.secondary
                      : CrystalColor.primary,
              border: value == false && !alwaysShowSelection ? Border.all(color: CrystalColor.icon) : const Border()),
          child: AnimatedSwitcher(
            duration: kThemeAnimationDuration,
            child: _icon,
          ),
        ),
      );

  Widget get _icon {
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
        width: 10.0,
        key: UniqueKey(),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  void _onTap() {
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
