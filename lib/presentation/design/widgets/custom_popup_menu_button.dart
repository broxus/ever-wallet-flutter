import 'package:flutter/material.dart';

class CustomPopupMenuButton<T> extends StatelessWidget {
  final List<PopupMenuEntry<T>> Function(BuildContext) itemBuilder;
  final void Function(T)? onSelected;
  final Widget? child;

  const CustomPopupMenuButton({
    Key? key,
    required this.itemBuilder,
    required this.onSelected,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => PopupMenuButton<T>(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        itemBuilder: (context) => itemBuilder(context).fold(
          [],
          (previousValue, element) => [
            if (previousValue.isNotEmpty) ...[
              ...previousValue,
              const PopupMenuDivider(height: 1),
            ],
            element,
          ],
        ),
        onSelected: onSelected,
        child: child,
      );
}
