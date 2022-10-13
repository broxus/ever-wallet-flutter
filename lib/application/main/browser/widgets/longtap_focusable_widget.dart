import 'package:ever_wallet/application/util/colors.dart';
import 'package:flutter/material.dart';

/// Widget that displays menu under [child] and make other parts of screen except of [child] dark
class LongTapFocusableWidget extends StatefulWidget {
  const LongTapFocusableWidget({
    required this.child,
    required this.menuBuilder,
    required this.onTap,
    this.longTapEnabled = true,
    this.backgroundColor,
    super.key,
  })  : assert(longTapEnabled && menuBuilder != null || !longTapEnabled);

  final Widget child;
  final WidgetBuilder? menuBuilder;
  final VoidCallback? onTap;
  final bool longTapEnabled;
  final Color? backgroundColor;

  @override
  State<LongTapFocusableWidget> createState() => _LongTapFocusableWidgetState();
}

class _LongTapFocusableWidgetState extends State<LongTapFocusableWidget> {
  final _focusableKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Material(
      key: _focusableKey,
      color: widget.backgroundColor,
      child: InkWell(
        onLongPress: !widget.longTapEnabled
            ? null
            : () {
                final render = _focusableKey.currentContext!.findRenderObject()! as RenderBox;
                Navigator.of(context).push(
                  _FocusableRouteBuilder(
                    targetRect: render.semanticBounds,
                    position: render.localToGlobal(Offset.zero),
                    menuBuilder: widget.menuBuilder!,
                  ),
                );
              },
        onTap: widget.onTap,
        child: widget.child,
      ),
    );
  }
}

class _FocusableRouteBuilder extends PageRoute<void> {
  final Rect targetRect;
  final Offset position;
  final WidgetBuilder menuBuilder;

  _FocusableRouteBuilder({
    required this.targetRect,
    required this.menuBuilder,
    required this.position,
  });

  @override
  Color get barrierColor => Colors.transparent;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => '_FocusableRouteBuilder';

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) =>
      _FocusableScreen(
        targetRect: targetRect,
        menuBuilder: menuBuilder,
        position: position,
      );

  @override
  bool get maintainState => false;

  @override
  Duration get transitionDuration => kThemeAnimationDuration;
}

class _FocusableScreen extends StatelessWidget {
  const _FocusableScreen({
    required this.targetRect,
    required this.menuBuilder,
    required this.position,
  });

  final Rect targetRect;
  final WidgetBuilder menuBuilder;
  final Offset position;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _FocusableBackgroundPainter(targetRect, position),
              ),
            ),
            Positioned(
              top: position.dy + targetRect.height + 12,
              left: position.dx,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 250),
                child: menuBuilder(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FocusableBackgroundPainter extends CustomPainter {
  _FocusableBackgroundPainter(this.targetRect, this.position);

  final Rect targetRect;
  final Offset position;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path.combine(
      PathOperation.difference,
      Path()
        ..addRect(
          Rect.fromLTRB(0, 0, size.width, size.height),
        ),
      Path()
        ..addRect(
          Rect.fromLTWH(position.dx, position.dy, targetRect.width, targetRect.height),
        ),
    );
    canvas.drawPath(
      path,
      Paint()..color = ColorsRes.black.withOpacity(0.3),
    );
  }

  @override
  bool shouldRepaint(covariant _FocusableBackgroundPainter oldDelegate) =>
      targetRect != oldDelegate.targetRect;
}
