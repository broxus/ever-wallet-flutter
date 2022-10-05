import 'package:ever_wallet/application/common/general/button/primary_elevated_button.dart';
import 'package:ever_wallet/application/common/widgets/custom_outlined_button.dart';
import 'package:ever_wallet/application/common/widgets/modal_header.dart';
import 'package:ever_wallet/application/common/widgets/sectioned_card.dart';
import 'package:ever_wallet/application/common/widgets/sectioned_card_section.dart';
import 'package:ever_wallet/application/main/common/get_password_from_biometry.dart';
import 'package:ever_wallet/application/main/wallet/modals/common/password_enter_page/password_enter_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

class CallContractMethodPage extends StatefulWidget {
  final BuildContext modalContext;
  final String origin;
  final String publicKey;
  final String recipient;
  final FunctionCall? payload;

  const CallContractMethodPage({
    super.key,
    required this.modalContext,
    required this.origin,
    required this.publicKey,
    required this.recipient,
    required this.payload,
  });

  @override
  _CallContractMethodPageState createState() => _CallContractMethodPageState();
}

class _CallContractMethodPageState extends State<CallContractMethodPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ModalHeader(
                  text: AppLocalizations.of(context)!.call_contract_method,
                  onCloseButtonPressed: Navigator.of(widget.modalContext).pop,
                ),
                const Gap(16),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: card(),
                  ),
                ),
                const Gap(16),
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
          recipient(),
        ],
      );

  Widget origin() => SectionedCardSection(
        title: AppLocalizations.of(context)!.origin,
        subtitle: widget.origin,
        isSelectable: true,
      );

  Widget publicKey() => SectionedCardSection(
        title: AppLocalizations.of(context)!.account_public_key,
        subtitle: widget.publicKey,
        isSelectable: true,
      );

  Widget recipient() => SectionedCardSection(
        title: AppLocalizations.of(context)!.recipient_address,
        subtitle: widget.recipient,
        isSelectable: true,
      );

  Widget buttons() => Row(
        children: [
          Expanded(
            child: rejectButton(),
          ),
          const Gap(16),
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

  Widget submitButton() => PrimaryElevatedButton(
        onPressed: () => onSubmitPressed(widget.publicKey),
        text: AppLocalizations.of(context)!.call,
      );

  Future<void> onSubmitPressed(String publicKey) async {
    final password = await getPasswordFromBiometry(context: context, publicKey: publicKey);

    if (!mounted) return;

    if (password != null) {
      Navigator.of(widget.modalContext).pop(password);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => PasswordEnterPage(
            modalContext: widget.modalContext,
            publicKey: publicKey,
            onSubmit: (password) => Navigator.of(widget.modalContext).pop(password),
          ),
        ),
      );
    }
  }
}
