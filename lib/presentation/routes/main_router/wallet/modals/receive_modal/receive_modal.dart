import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../design/design.dart';
import '../../../../../design/widgets/address_card.dart';
import '../../../../../design/widgets/crystal_flushbar.dart';
import '../../../../../design/widgets/custom_elevated_button.dart';
import '../../../../../design/widgets/custom_outlined_button.dart';
import '../../../../../design/widgets/modal_header.dart';

class ReceiveModalBody extends StatefulWidget {
  final String address;

  const ReceiveModalBody({
    Key? key,
    required this.address,
  }) : super(key: key);

  @override
  State<ReceiveModalBody> createState() => _ReceiveModalBodyState();
}

class _ReceiveModalBodyState extends State<ReceiveModalBody> {
  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ModalHeader(
                  text: 'Your address to receive funds',
                ),
                const SizedBox(height: 16),
                card(),
                const SizedBox(height: 16),
                copyButton(),
                const SizedBox(height: 16),
                shareButton(),
              ],
            ),
          ),
        ),
      );

  Widget card() => AddressCard(address: widget.address);

  Widget copyButton() => CustomElevatedButton(
        onPressed: onCopyPressed,
        text: 'Copy address',
      );

  Future<void> onCopyPressed() async {
    await Clipboard.setData(ClipboardData(text: widget.address));

    if (!mounted) return;

    showCrystalFlushbar(
      context,
      message: LocaleKeys.receive_wallet_modal_message_copied.tr(),
    );
  }

  Widget shareButton() => CustomOutlinedButton(
        onPressed: onSharePressed,
        text: 'Share',
      );

  Future<void> onSharePressed() => Share.share(
        LocaleKeys.receive_wallet_modal_message_share.tr(
          args: [widget.address],
        ),
      );
}
