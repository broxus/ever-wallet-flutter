import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_portal/flutter_portal.dart';

import '../theme.dart';
import 'animated_visibility.dart';
import 'crystal_flushbar.dart';

class WalletCardSelectableField extends StatefulWidget {
  final String text;
  final String value;

  const WalletCardSelectableField({
    Key? key,
    required this.text,
    required this.value,
  }) : super(key: key);

  @override
  _WalletCardSelectableFieldState createState() => _WalletCardSelectableFieldState();
}

class _WalletCardSelectableFieldState extends State<WalletCardSelectableField> {
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
          child: child(),
        ),
      );

  Widget label() => Container(
        margin: const EdgeInsets.all(8),
        child: AnimatedVisibility(
          duration: const Duration(milliseconds: 100),
          visible: isOpen,
          child: Material(
            color: CrystalColor.secondary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(2),
            elevation: 8,
            child: InkWell(
              borderRadius: BorderRadius.circular(2),
              onTap: () async {
                setState(() => isOpen = false);
                HapticFeedback.selectionClick();

                await Clipboard.setData(ClipboardData(text: widget.value));

                if (!mounted) return;

                showCrystalFlushbar(
                  context,
                  message: 'Copied!',
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                child: Text(
                  'Copy',
                  style: TextStyle(
                    letterSpacing: 0.75,
                    color: CrystalColor.secondary.withOpacity(
                      !isOpen ? 0.6 : 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  Widget child() => Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(2),
        child: InkWell(
          borderRadius: BorderRadius.circular(2),
          onTap: () {
            setState(() => isOpen = true);
            HapticFeedback.selectionClick();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            padding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 2,
            ),
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: isOpen ? CrystalColor.secondary.withOpacity(0.2) : null,
            ),
            child: Text(
              widget.text,
              maxLines: 1,
              style: TextStyle(
                letterSpacing: 0.75,
                color: CrystalColor.secondary.withOpacity(
                  !isOpen ? 0.6 : 1,
                ),
              ),
            ),
          ),
        ),
      );
}
