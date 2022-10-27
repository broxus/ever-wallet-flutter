import 'package:flutter/material.dart';
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

  return showMaterialModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      ),
    ),
    builder: (context) => constrainedBuilder(context),
  );
}
