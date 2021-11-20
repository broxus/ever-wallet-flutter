import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../design.dart';
import '../theme.dart';

class AddressCard extends StatelessWidget {
  const AddressCard({
    Key? key,
    required this.address,
  }) : super(key: key);

  final String address;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
        color: CrystalColor.grayBackground,
        child: LayoutBuilder(
          builder: (context, constraints) => Row(
            children: [
              QrImage(
                size: constraints.maxWidth * 0.45,
                padding: const EdgeInsets.all(12),
                foregroundColor: CrystalColor.fontDark,
                backgroundColor: CrystalColor.primary,
                data: address,
              ),
              const CrystalDivider(width: 16),
              Expanded(
                child: SelectionWidget(
                  configuration: const SelectionConfiguration(
                    openOnTap: true,
                    openOnHold: false,
                    highlightColor: CrystalColor.secondary,
                  ),
                  overlay: (context) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Material(
                      type: MaterialType.card,
                      color: CrystalColor.secondary,
                      borderRadius: BorderRadius.circular(4),
                      clipBehavior: Clip.antiAlias,
                      child: CrystalInkWell(
                        splashColor: CrystalColor.background,
                        highlightColor: CrystalColor.background,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          Clipboard.setData(ClipboardData(text: address));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          color: CrystalColor.secondaryBackground,
                          child: Text(
                            LocaleKeys.actions_copy.tr(),
                            style: const TextStyle(
                              color: CrystalColor.fontDark,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  child: (highlighted) => Text(
                    address,
                    style: const TextStyle(
                      color: CrystalColor.fontDark,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
