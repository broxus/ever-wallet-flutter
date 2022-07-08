import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class SuffixLoaderIcon extends StatelessWidget {
  const SuffixLoaderIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox.square(
            dimension: 20,
            child: PlatformCircularProgressIndicator(
              material: (context, platform) => MaterialProgressIndicatorData(strokeWidth: 2),
            ),
          ),
        ],
      );
}
