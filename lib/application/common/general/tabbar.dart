import 'package:ever_wallet/application/common/general/button/push_state_scale_widget.dart';
import 'package:flutter/material.dart';

typedef EWTabBarBuilder<T> = Widget Function(BuildContext context, T value, bool isActive);

class EWTabBar<T> extends StatelessWidget {
  final List<T> values;
  final EWTabBarBuilder<T> builder;
  final ValueChanged<T> onChanged;
  final T selectedValue;

  final Color selectedColor;
  final Color unselectedColor;

  final bool expanded;

  const EWTabBar({
    required this.values,
    required this.builder,
    required this.selectedValue,
    required this.onChanged,
    required this.selectedColor,
    this.expanded = false,
    super.key,
    this.unselectedColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: values
          .map(
            (v) => expanded ? Expanded(child: _item(context, v)) : _item(context, v),
          )
          .toList(),
    );
  }

  Widget _item(BuildContext context, T v) {
    return Container(
      height: 43,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: v == selectedValue ? selectedColor : unselectedColor,
          ),
        ),
      ),
      child: PushStateScaleWidget(
        onPressed: () => onChanged(v),
        child: builder(context, v, selectedValue == v),
      ),
    );
  }
}
