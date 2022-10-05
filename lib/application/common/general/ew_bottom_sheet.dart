import 'package:ever_wallet/application/common/general/button/primary_icon_button.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

Future<T?> showEWBottomSheet<T>(
  BuildContext context, {
  String? title,
  required WidgetBuilder body,
  Widget? closeButton,
  EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 16),
  bool expand = false,
  bool draggable = false,
  bool needCloseButton = true,
  bool dismissible = true,
  bool wrapIntoAnimatedSize = true,
  bool avoidBottomInsets = true,
  Color barrierColor = ColorsRes.modalBarrier,
}) {
  return showCustomModalBottomSheet<T>(
    expand: expand,
    context: context,
    isDismissible: dismissible,
    useRootNavigator: true,
    enableDrag: draggable,
    barrierColor: barrierColor,
    containerWidget: (context, animation, child) => _ContainerWidget(
      animated: wrapIntoAnimatedSize,
      child: child,
    ),
    builder: (context) {
      final themeStyle = context.themeStyle;

      return Material(
        color: themeStyle.colors.secondaryBackgroundColor,
        child: Padding(
          padding: avoidBottomInsets ? MediaQuery.of(context).viewInsets : EdgeInsets.zero,
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (title != null)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16) +
                          const EdgeInsets.only(top: 16, right: 16),
                      child: Text(title, style: themeStyle.styles.sheetHeaderStyle),
                    ),
                  Flexible(child: Padding(padding: padding, child: body(context))),
                ],
              ),
              if (needCloseButton)
                Positioned(
                  top: 0,
                  right: 0,
                  child: closeButton ?? _getCloseButton(),
                ),
              if (draggable)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      height: 3,
                      width: 48,
                      margin: const EdgeInsets.only(top: 6, bottom: 6),
                      decoration: const ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        color: ColorsRes.black,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _getCloseButton() => Builder(
      builder: (context) {
        return PrimaryIconButton(
          onPressed: Navigator.of(context).maybePop,
          icon: const Icon(Icons.close, color: ColorsRes.grey, size: 20),
        );
      },
    );

class _ContainerWidget extends StatefulWidget {
  const _ContainerWidget({
    required this.child,
    this.animated = true,
  });

  final Widget child;
  final bool animated;

  @override
  __ContainerWidgetState createState() => __ContainerWidgetState();
}

class __ContainerWidgetState extends State<_ContainerWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
      ),
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      width: double.infinity,
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: widget.animated
            ? AnimatedSize(
                duration: kThemeAnimationDuration,
                reverseDuration: kThemeAnimationDuration,
                curve: Curves.decelerate,
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                child: widget.child,
              )
            : widget.child,
      ),
    );
  }
}
