import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../common/widgets/address_card.dart';
import '../../../../common/widgets/crystal_flushbar.dart';
import '../../../../common/widgets/custom_elevated_button.dart';
import '../../../../common/widgets/custom_outlined_button.dart';
import '../../../../common/widgets/modal_header.dart';

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
                ModalHeader(
                  text: AppLocalizations.of(context)!.address_receive_funds,
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
        text: AppLocalizations.of(context)!.copy_address,
      );

  Future<void> onCopyPressed() async {
    await Clipboard.setData(ClipboardData(text: widget.address));

    if (!mounted) return;

    showCrystalFlushbar(
      context,
      message: AppLocalizations.of(context)!.copied,
    );
  }

  Widget shareButton() => CustomOutlinedButton(
        onPressed: onSharePressed,
        text: AppLocalizations.of(context)!.share,
      );

  Future<void> onSharePressed() => Share.share(AppLocalizations.of(context)!.share_wallet_address(widget.address));
}
