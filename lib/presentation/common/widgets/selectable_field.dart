import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_portal/flutter_portal.dart';

import '../../../generated/codegen_loader.g.dart';
import 'animated_visibility.dart';
import 'crystal_flushbar.dart';

class SelectableField extends StatefulWidget {
  final String value;
  final Widget child;

  const SelectableField({
    Key? key,
    required this.value,
    required this.child,
  }) : super(key: key);

  @override
  _SelectableFieldState createState() => _SelectableFieldState();
}

class _SelectableFieldState extends State<SelectableField> {
  bool isOpen = false;

  @override
  Widget build(BuildContext context) => PortalEntry(
        visible: isOpen,
        portal: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => isOpen = false),
        ),
        child: PortalEntry(
          visible: isOpen,
          portalAnchor: Alignment.bottomCenter,
          childAnchor: Alignment.topCenter,
          portal: label(),
          child: child(context),
        ),
      );

  Widget label() => Container(
        margin: const EdgeInsets.all(8),
        child: AnimatedVisibility(
          duration: const Duration(milliseconds: 100),
          visible: isOpen,
          child: Material(
            color: Colors.white,
            elevation: 8,
            child: InkWell(
              onTap: () async {
                setState(() => isOpen = false);
                HapticFeedback.selectionClick();

                await Clipboard.setData(ClipboardData(text: widget.value));

                if (!mounted) return;

                showCrystalFlushbar(
                  context,
                  message: LocaleKeys.copied.tr(),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  LocaleKeys.copy.tr(),
                  style: const TextStyle(
                    letterSpacing: 0.75,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  Widget child(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() => isOpen = true);
            HapticFeedback.selectionClick();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            padding: const EdgeInsets.all(8),
            foregroundDecoration: BoxDecoration(
              color: isOpen ? Theme.of(context).focusColor : null,
            ),
            child: widget.child,
          ),
        ),
      );
}
