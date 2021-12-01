import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:tuple/tuple.dart';

import 'animated_visibility.dart';

class CustomPopupMenu extends StatefulWidget {
  final Alignment portalAnchor;
  final Alignment childAnchor;
  final List<Tuple2<String, VoidCallback>> items;
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
    final list = widget.items.map<Widget>((e) => item(e)).toList().fold<List<Widget>>(
      <Widget>[],
      (previousValue, element) => [
        if (previousValue.isNotEmpty) ...[
          ...previousValue,
          divider(),
        ],
        element,
      ],
    );

    return PortalEntry(
      visible: isOpen,
      portal: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => isOpen = false),
      ),
      child: PortalEntry(
        visible: isOpen,
        portalAnchor: widget.portalAnchor,
        childAnchor: widget.childAnchor,
        portal: menu(list),
        child: child(),
      ),
    );
  }

  Widget item(Tuple2<String, VoidCallback> element) => ListTile(
        title: Text(element.item1),
        onTap: () {
          element.item2();
          setState(() => isOpen = false);
        },
      );

  Widget divider() => const Divider(
        height: 1,
        thickness: 1,
      );

  Widget menu(List<Widget> list) => AnimatedVisibility(
        duration: const Duration(milliseconds: 100),
        visible: isOpen,
        child: Material(
          color: Colors.white,
          elevation: 8,
          child: IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: list,
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
