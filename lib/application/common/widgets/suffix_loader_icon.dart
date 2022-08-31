import 'package:flutter/material.dart';

class SuffixLoaderIcon extends StatelessWidget {
  const SuffixLoaderIcon({
    this.color,
    Key? key,
  }) : super(key: key);

  final Color? color;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: color),
          ),
        ],
      );
}
