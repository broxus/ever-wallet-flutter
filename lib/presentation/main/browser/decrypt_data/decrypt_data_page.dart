import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../../common/widgets/custom_elevated_button.dart';
import '../../../common/widgets/custom_outlined_button.dart';
import '../../../common/widgets/modal_header.dart';
import '../../../common/widgets/sectioned_card.dart';
import '../../../common/widgets/sectioned_card_section.dart';
import '../../common/get_password_from_biometry.dart';
import '../../wallet/modals/common/password_enter_page/password_enter_page.dart';

class DecryptDataPage extends ConsumerStatefulWidget {
  final BuildContext modalContext;
  final String origin;
  final String publicKey;
  final String sourcePublicKey;

  const DecryptDataPage({
    Key? key,
    required this.modalContext,
    required this.origin,
    required this.publicKey,
    required this.sourcePublicKey,
  }) : super(key: key);

  @override
  _SendMessageModalState createState() => _SendMessageModalState();
}

class _SendMessageModalState extends ConsumerState<DecryptDataPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ModalHeader(
                  text: AppLocalizations.of(context)!.decrypt_data,
                  onCloseButtonPressed: Navigator.of(widget.modalContext).pop,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    controller: ModalScrollController.of(context),
                    physics: const ClampingScrollPhysics(),
                    child: card(),
                  ),
                ),
                const SizedBox(height: 16),
                buttons(),
              ],
            ),
          ),
        ),
      );

  Widget card() => SectionedCard(
        sections: [
          origin(),
          publicKey(),
          sourcePublicKey(),
        ],
      );

  Widget origin() => SectionedCardSection(
        title: AppLocalizations.of(context)!.origin,
        subtitle: widget.origin,
        isSelectable: true,
      );

  Widget publicKey() => SectionedCardSection(
        title: AppLocalizations.of(context)!.public_key,
        subtitle: widget.publicKey,
        isSelectable: true,
      );

  Widget sourcePublicKey() => SectionedCardSection(
        title: AppLocalizations.of(context)!.source_public_key,
        subtitle: widget.sourcePublicKey,
        isSelectable: true,
      );

  Widget buttons() => Row(
        children: [
          Expanded(
            child: rejectButton(),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: submitButton(),
          ),
        ],
      );

  Widget rejectButton() => CustomOutlinedButton(
        onPressed: () => Navigator.of(widget.modalContext).pop(),
        text: AppLocalizations.of(context)!.reject,
      );

  Widget submitButton() => Consumer(
        builder: (context, ref, child) {
          return PrimaryElevatedButton(
            onPressed: () => onSubmitPressed(widget.publicKey),
            text: AppLocalizations.of(context)!.submit,
          );
        },
      );

  Future<void> onSubmitPressed(String selectedPublicKey) async {
    final password = await getPasswordFromBiometry(
      context: context,
      publicKey: selectedPublicKey,
    );

    if (!mounted) return;

    if (password != null) {
      Navigator.of(widget.modalContext).pop(password);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => PasswordEnterPage(
            modalContext: widget.modalContext,
            publicKey: selectedPublicKey,
            onSubmit: (password) => Navigator.of(widget.modalContext).pop(password),
          ),
        ),
      );
    }
  }
}
