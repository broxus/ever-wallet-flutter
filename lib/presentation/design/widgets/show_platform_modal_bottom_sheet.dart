import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

Future<T?> showPlatformModalBottomSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
}) {
  Widget constrainedBuilder(BuildContext context) => ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.longestSide / 2,
          maxHeight: MediaQuery.of(context).size.longestSide - MediaQuery.of(context).viewPadding.top,
        ),
        child: MediaQuery.removeViewPadding(
          context: context,
          removeTop: true,
          child: builder(context),
        ),
      );

  if (isMaterial(context)) {
    return showMaterialModalBottomSheet(
      context: context,
      builder: (context) => constrainedBuilder(context),
    );
  } else if (isCupertino(context)) {
    return showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => constrainedBuilder(context),
    );
  } else {
    return throw UnsupportedError('This platform is not supported: $defaultTargetPlatform');
  }
}
