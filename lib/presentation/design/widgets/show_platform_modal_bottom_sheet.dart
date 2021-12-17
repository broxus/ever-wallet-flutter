import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

Future<T?> showPlatformModalBottomSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext context) builder,
}) {
  Widget constrainedBuilder(BuildContext context) {
    final bottom = context.findAncestorWidgetOfExactType<MediaQuery>()!.data.viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottom),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.longestSide - MediaQuery.of(context).viewPadding.top,
      ),
      color: Colors.white,
      child: MediaQuery.removeViewInsets(
        context: context,
        removeBottom: true,
        child: MediaQuery.removeViewPadding(
          context: context,
          removeTop: true,
          child: builder(context),
        ),
      ),
    );
  }

  final showModalBottomSheet = isCupertino(context) ? showCupertinoModalBottomSheet : showMaterialModalBottomSheet;

  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    builder: (context) => constrainedBuilder(context),
  );
}
