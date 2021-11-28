import 'dart:io' show Platform;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../../theme.dart';
import '../crystal_ink_well.dart';

class FocusedMenuController {
  _FocusedMenuHolderState? _state;

  void openMenu(BuildContext context) => _state?.openMenu(context);
}

class FocusedMenuHolder extends StatefulWidget {
  final Widget Function(bool isOpened) child;
  final double menuItemExtent;
  final double? menuWidth;
  final List<FocusedMenuItem> menuItems;
  final bool animateMenuItems;
  final BoxDecoration? menuBoxDecoration;
  final VoidCallback? onPressed;
  final Duration duration;
  final double blurSize;
  final Color? blurBackgroundColor;
  final double bottomOffsetHeight;
  final Offset menuOffset;
  final FocusedMenuController? controller;

  final bool openWithTap;

  const FocusedMenuHolder({
    Key? key,
    required this.child,
    this.onPressed,
    required this.menuItems,
    this.duration = const Duration(milliseconds: 100),
    this.menuBoxDecoration,
    this.menuItemExtent = 50,
    this.animateMenuItems = true,
    this.blurSize = 4,
    this.blurBackgroundColor,
    this.menuWidth,
    this.bottomOffsetHeight = 0,
    this.menuOffset = Offset.zero,
    this.openWithTap = false,
    this.controller,
  }) : super(key: key);

  @override
  _FocusedMenuHolderState createState() => _FocusedMenuHolderState();
}

class _FocusedMenuHolderState extends State<FocusedMenuHolder> {
  GlobalKey containerKey = GlobalKey();
  Offset childOffset = Offset.zero;
  Size childSize = Size.zero;

  @override
  void didUpdateWidget(covariant FocusedMenuHolder oldWidget) {
    widget.controller?._state = this;
    super.didUpdateWidget(oldWidget);
  }

  void updateOffset() {
    final renderBox = containerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    setState(() {
      childOffset = Offset(offset.dx, offset.dy);
      childSize = size;
    });
  }

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: containerKey,
      onTap: () async {
        widget.onPressed?.call();
        if (widget.openWithTap) {
          await openMenu(context);
        }
      },
      onLongPress: () async {
        if (!widget.openWithTap) {
          HapticFeedback.heavyImpact();
          await openMenu(context);
        }
      },
      child: widget.child(false),
    );
  }

  Future<void> openMenu(BuildContext context) async {
    updateOffset();
    await Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: widget.duration,
        reverseTransitionDuration: widget.duration,
        pageBuilder: (context, animation, secondaryAnimation) => AnimatedBuilder(
          animation: animation,
          builder: (context, child) => FadeTransition(opacity: animation, child: child),
          child: _FocusedMenuDetails(
            itemExtent: widget.menuItemExtent,
            menuBoxDecoration: widget.menuBoxDecoration,
            childOffset: childOffset,
            childSize: childSize,
            menuItems: widget.menuItems,
            blurSize: widget.blurSize,
            menuWidth: widget.menuWidth,
            blurBackgroundColor: widget.blurBackgroundColor ?? Colors.black.withOpacity(0.7),
            animateMenu: widget.animateMenuItems,
            bottomOffsetHeight: widget.bottomOffsetHeight,
            menuOffset: widget.menuOffset,
            child: widget.child(true),
          ),
        ),
        fullscreenDialog: true,
        opaque: false,
      ),
    );
  }
}

class _FocusedMenuDetails extends StatelessWidget {
  final List<FocusedMenuItem> menuItems;
  final BoxDecoration? menuBoxDecoration;
  final Offset childOffset;
  final double itemExtent;
  final Size childSize;
  final Widget child;
  final bool animateMenu;
  final double blurSize;
  final double? menuWidth;
  final Color blurBackgroundColor;
  final double bottomOffsetHeight;
  final Offset menuOffset;

  const _FocusedMenuDetails({
    Key? key,
    required this.menuItems,
    required this.child,
    required this.childOffset,
    required this.childSize,
    required this.menuBoxDecoration,
    required this.itemExtent,
    required this.animateMenu,
    required this.blurSize,
    required this.blurBackgroundColor,
    required this.menuWidth,
    required this.bottomOffsetHeight,
    required this.menuOffset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final maxMenuHeight = size.height * 0.45;
    final listHeight = menuItems.length * itemExtent + (menuItems.length - 1);

    final maxMenuWidth = menuWidth ?? (size.width * 0.70);
    final menuHeight = listHeight < maxMenuHeight ? listHeight : maxMenuHeight;
    final leftOffset = (childOffset.dx + maxMenuWidth) < size.width
        ? childOffset.dx
        : (childOffset.dx - maxMenuWidth + childSize.width);

    final isBelow = (childOffset.dy + menuHeight + childSize.height) < size.height - bottomOffsetHeight;
    final topOffset =
        isBelow ? childOffset.dy + childSize.height + menuOffset.dy : childOffset.dy - menuHeight - menuOffset.dy;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: blurSize > 0
                ? BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: blurSize, sigmaY: blurSize),
                    child: ColoredBox(
                      color: blurBackgroundColor,
                    ),
                  )
                : ColoredBox(color: blurBackgroundColor),
          ),
          Positioned(
            top: topOffset,
            right: size.width - (leftOffset + childSize.width) + menuOffset.dx,
            child: SizedBox(
              width: maxMenuWidth,
              child: DecoratedBox(
                decoration: menuBoxDecoration ?? const BoxDecoration(),
                child: IntrinsicWidth(
                  child: Material(
                    elevation: 1,
                    type: MaterialType.card,
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(Platform.isIOS ? 13 : 4),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: PlatformWidget(
                            cupertino: (context, _) => BackdropFilter(
                              filter: ImageFilter.blur(sigmaY: 30, sigmaX: 30),
                              child: const ColoredBox(color: Colors.transparent),
                            ),
                          ),
                        ),
                        PlatformWidgetBuilder(
                          material: (context, child, _) => ColoredBox(
                            color: CrystalColor.primary,
                            child: child,
                          ),
                          cupertino: (context, child, _) => ColoredBox(
                            color: const Color.fromRGBO(237, 237, 237, 0.8),
                            child: child,
                          ),
                          child: ListView.separated(
                            itemCount: menuItems.length,
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            separatorBuilder: (_, __) => Divider(
                              height: 1,
                              thickness: 1,
                              color: Platform.isIOS ? const Color.fromRGBO(60, 60, 67, 0.36) : CrystalColor.divider,
                            ),
                            itemBuilder: (context, index) {
                              final item = menuItems[index];
                              final itemWidget = _itemBuilder(
                                text: item.title,
                                color: item.titleColor ?? CrystalColor.fontDark,
                                icon: item.materialIcon,
                                cupertinoIcon: item.cupertinoIcon,
                                onTap: () {
                                  Navigator.pop(context);
                                  item.onPressed();
                                },
                              );
                              if (animateMenu) {
                                return TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 1, end: 0),
                                  duration: Duration(milliseconds: index * 200),
                                  builder: (context, value, child) => Transform(
                                    transform: Matrix4.rotationX(1.5708 * value),
                                    alignment: Alignment.bottomCenter,
                                    child: child,
                                  ),
                                  child: itemWidget,
                                );
                              } else {
                                return itemWidget;
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: childOffset.dy,
            left: childOffset.dx,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: Navigator.of(context).pop,
              child: IgnorePointer(
                child: SizedBox(
                  width: childSize.width,
                  height: childSize.height,
                  child: Material(
                    type: MaterialType.transparency,
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemBuilder({
    required String text,
    required VoidCallback onTap,
    Color color = CrystalColor.fontDark,
    IconData? icon,
    IconData? cupertinoIcon,
  }) =>
      Material(
        type: MaterialType.transparency,
        child: CrystalInkWell(
          onTap: onTap,
          splashColor: color,
          highlightColor: color,
          child: Container(
            height: itemExtent,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: PlatformWidgetBuilder(
              material: (context, child, _) => Row(
                children: [
                  if (icon != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8, right: 20),
                      child: SizedBox(
                        width: 24,
                        child: Icon(icon, color: color, size: 24),
                      ),
                    ),
                  child!,
                ],
              ),
              cupertino: (context, child, _) => Row(
                children: [
                  child!,
                  if (cupertinoIcon != null) ...[
                    const Spacer(),
                    Icon(cupertinoIcon, color: color, size: 22),
                  ],
                ],
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: Platform.isIOS ? 17 : 16,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      );
}

class FocusedMenuItem {
  Color? backgroundColor;
  String title;
  Color? titleColor;
  IconData? materialIcon;
  IconData? cupertinoIcon;
  Function onPressed;

  FocusedMenuItem({
    this.backgroundColor,
    required this.title,
    this.materialIcon,
    this.cupertinoIcon,
    required this.onPressed,
    this.titleColor,
  });
}
