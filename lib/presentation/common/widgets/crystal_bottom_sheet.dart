import 'dart:io';

import 'package:expand_tap_area/expand_tap_area.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../theme.dart';
import 'circle_icon.dart';

Future<T?> showCrystalBottomSheet<T>(
  BuildContext context, {
  String? title,
  required Widget body,
  Widget? closeButton,
  EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 16),
  bool expand = false,
  bool hasTitleDivider = false,
  bool draggable = true,
  bool dismissible = true,
  bool wrapIntoAnimatedSize = true,
  bool avoidBottomInsets = true,
  Color barrierColor = CrystalColor.modalBackground,
}) {
  final _hasTitleDivider = title != null && hasTitleDivider;
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
    builder: (context) => Material(
      color: CrystalColor.primary,
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
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16) + const EdgeInsets.only(top: 16),
                    height: 32,
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        color: CrystalColor.fontDark,
                      ),
                    ),
                  ),
                if (_hasTitleDivider)
                  const SizedBox(
                    height: 12,
                  ),
                Flexible(
                  child: Padding(
                    padding: padding,
                    child: body,
                  ),
                ),
              ],
            ),
            if (!Platform.isIOS || !draggable)
              Positioned(
                top: 0,
                right: 0,
                child: ExpandTapWidget(
                  tapPadding: const EdgeInsets.all(12),
                  onTap: Navigator.of(context).maybePop,
                  child: closeButton ?? _getCloseButton(),
                ),
              ),
            if (_hasTitleDivider)
              const Padding(
                padding: EdgeInsets.only(top: 60),
                child: Divider(
                  thickness: 1,
                  height: 1,
                ),
              ),
            if (Platform.isIOS && draggable)
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
                      color: CrystalColor.cursorColor,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

Widget _getCloseButton() => Padding(
      padding: const EdgeInsets.all(10),
      child: CircleIcon(
        size: 24,
        color: Platform.isIOS ? CrystalColor.iconBackground : Colors.transparent,
        icon: Icon(
          Icons.close,
          color: Platform.isIOS ? CrystalColor.fontDark : CrystalColor.fontTitleSecondaryDark,
          size: 20,
        ),
      ),
    );

class _ContainerWidget extends StatefulWidget {
  const _ContainerWidget({
    Key? key,
    required this.child,
    this.animated = true,
  }) : super(key: key);

  final Widget child;
  final bool animated;

  @override
  __ContainerWidgetState createState() => __ContainerWidgetState();
}

class __ContainerWidgetState extends State<_ContainerWidget> {
  @override
  Widget build(BuildContext context) => Container(
        margin: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 24,
        ),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: CrystalColor.primary,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(Platform.isIOS ? 12 : 0),
          ),
        ),
        width: double.infinity,
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
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
