import 'package:ever_wallet/application/common/general/button/push_state_scale_widget.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

typedef EWTabBarBuilder<T> = Widget Function(BuildContext context, T value, bool isActive);

class EWTabBar<T> extends StatelessWidget {
  final List<T> values;
  final EWTabBarBuilder<T> builder;
  final ValueChanged<T> onChanged;
  final T selectedValue;

  const EWTabBar({
    required this.values,
    required this.builder,
    required this.selectedValue,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.themeStyle.colors;

    return Row(
      children: values
          .map(
            (v) => Container(
              height: 43,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: v == selectedValue ? colors.primaryButtonColor : Colors.transparent,
                  ),
                ),
              ),
              child: PushStateScaleWidget(
                onPressed: () => onChanged(v),
                child: builder(context, v, selectedValue == v),
              ),
            ),
          )
          .toList(),
    );
  }
}
