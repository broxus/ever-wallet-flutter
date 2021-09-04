import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../design/design.dart';

class ReceiveModalBody extends StatelessWidget {
  final String address;
  final bool textAsTitle;

  const ReceiveModalBody({
    Key? key,
    required this.address,
    this.textAsTitle = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SafeArea(
        minimum: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: textAsTitle ? const EdgeInsets.only(right: 24, bottom: 16) : EdgeInsets.zero,
              child: Text(
                LocaleKeys.receive_wallet_modal_title.tr(args: ['']),
                style: TextStyle(
                  fontSize: textAsTitle ? 24 : 16,
                  color: CrystalColor.fontDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const CrystalDivider(height: 8),
            AddressCard(address: address),
            const CrystalDivider(height: 24),
            Row(
              children: [
                Expanded(
                  child: CrystalButton(
                    onTap: () => _onCopyAddress(context),
                    type: CrystalButtonType.outline,
                    text: LocaleKeys.actions_copy.tr(),
                  ),
                ),
                const CrystalDivider(width: 12),
                Expanded(
                  child: CrystalButton(
                    onTap: () => _onShareAddress(context),
                    text: LocaleKeys.actions_share.tr(),
                  ),
                )
              ],
            ),
          ],
        ),
      );

  Future<void> _onShareAddress(BuildContext context) async {
    await Share.share(LocaleKeys.receive_wallet_modal_message_share.tr(args: [address]));
  }

  Future<void> _onCopyAddress(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: address));
    showCrystalFlushbar(context, message: LocaleKeys.receive_wallet_modal_message_copied.tr());
  }
}
