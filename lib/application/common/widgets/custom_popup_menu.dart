import 'package:ever_wallet/application/common/widgets/animated_visibility.dart';
import 'package:ever_wallet/application/common/widgets/custom_popup_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:gap/gap.dart';

class CustomPopupMenu extends StatefulWidget {
  final Alignment portalAnchor;
  final Alignment childAnchor;
  final List<CustomPopupItem> items;
  final Widget icon;

  const CustomPopupMenu({
    Key? key,
    this.portalAnchor = Alignment.topRight,
    this.childAnchor = Alignment.topRight,
    required this.items,
    required this.icon,
  }) : super(key: key);

  @override
  _CustomPopupMenuState createState() => _CustomPopupMenuState();
}

class _CustomPopupMenuState extends State<CustomPopupMenu> {
  bool isOpen = false;

  @override
  Widget build(BuildContext context) {
    final list = widget.items
        .asMap()
        .entries
        .map<Widget>(
          (e) {
            BorderRadius? borderRadius;

            if (e.key == 0) {
              borderRadius = const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              );
            } else if (e.key == widget.items.length - 1) {
              borderRadius = const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              );
            }

            return item(
              element: e.value,
              borderRadius: borderRadius,
            );
          },
        )
        .toList()
        .fold<List<Widget>>(
          <Widget>[],
          (previousValue, element) => [
            if (previousValue.isNotEmpty) ...[
              ...previousValue,
              divider(),
            ],
            element,
          ],
        );

    return PortalTarget(
      visible: isOpen,
      portalFollower: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => isOpen = false),
      ),
      child: PortalTarget(
        visible: isOpen,
        anchor: Aligned(
          follower: widget.portalAnchor,
          target: widget.childAnchor,
        ),
        portalFollower: menu(list),
        child: child(),
      ),
    );
  }

  Widget item({
    required CustomPopupItem element,
    BorderRadius? borderRadius,
  }) =>
      InkWell(
        borderRadius: borderRadius,
        onTap: () {
          element.onTap?.call();
          setState(() => isOpen = false);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (element.leading != null) ...[
                element.leading!,
                const Gap(16),
              ],
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  element.title,
                  if (element.subtitle != null) ...[
                    const Gap(4),
                    element.subtitle!,
                  ],
                ],
              ),
              if (element.trailing != null) ...[
                const Gap(16),
                element.trailing!,
              ],
            ],
          ),
        ),
      );

  Widget divider() => const Divider(
        height: 1,
        thickness: 1,
      );

  Widget menu(List<Widget> list) => AnimatedVisibility(
        duration: const Duration(milliseconds: 100),
        visible: isOpen,
        child: Material(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          elevation: 8,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: list,
              ),
            ),
          ),
        ),
      );

  Widget child() => PlatformWidget(
        cupertino: (_, __) => CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => setState(() => isOpen = true),
          child: widget.icon,
        ),
        material: (_, __) => RawMaterialButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints(),
          onPressed: () => setState(() => isOpen = true),
          child: widget.icon,
        ),
      );
}
