import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../generated/codegen_loader.g.dart';
import '../../../common/widgets/custom_elevated_button.dart';
import '../../../common/widgets/custom_outlined_button.dart';
import '../../../common/widgets/modal_header.dart';
import '../../../common/widgets/sectioned_card.dart';
import '../../../common/widgets/sectioned_card_section.dart';
import '../../common/get_password_from_biometry.dart';
import '../../wallet/modals/common/password_enter_page/password_enter_page.dart';

class CallContractMethodPage extends StatefulWidget {
  final BuildContext modalContext;
  final String origin;
  final String publicKey;
  final String recipient;
  final FunctionCall? payload;

  const CallContractMethodPage({
    Key? key,
    required this.modalContext,
    required this.origin,
    required this.publicKey,
    required this.recipient,
    required this.payload,
  }) : super(key: key);

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
                  text: LocaleKeys.call_contract_method.tr(),
                  onCloseButtonPressed: Navigator.of(widget.modalContext).pop,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
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
          recipient(),
        ],
      );

  Widget origin() => SectionedCardSection(
        title: LocaleKeys.origin.tr(),
        subtitle: widget.origin,
        isSelectable: true,
      );

  Widget publicKey() => SectionedCardSection(
        title: LocaleKeys.account_public_key.tr(),
        subtitle: widget.publicKey,
        isSelectable: true,
      );

  Widget recipient() => SectionedCardSection(
        title: LocaleKeys.recipient_address.tr(),
        subtitle: widget.recipient,
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
        text: LocaleKeys.reject.tr(),
      );

  Widget submitButton() => Consumer(
        builder: (context, ref, child) => CustomElevatedButton(
          onPressed: () => onSubmitPressed(widget.publicKey),
          text: LocaleKeys.call.tr(),
        ),
      );

  Future<void> onSubmitPressed(String publicKey) async {
    final password = await getPasswordFromBiometry(publicKey);

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
