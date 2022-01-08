import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

import '../../../../../../data/repositories/biometry_repository.dart';
import '../../../../../../domain/blocs/biometry/biometry_info_provider.dart';
import '../../../../../../injection.dart';
import '../../../../../design/extension.dart';
import '../../../../../design/widgets/custom_elevated_button.dart';
import '../../../../../design/widgets/custom_outlined_button.dart';
import '../../../../../design/widgets/modal_header.dart';
import '../../../../../design/widgets/sectioned_card.dart';
import '../../../../../design/widgets/sectioned_card_section.dart';
import '../common/password_enter_page.dart';

class SendMessageModalBody extends StatefulWidget {
  final BuildContext modalContext;
  final String origin;
  final String sender;
  final String publicKey;
  final String recipient;
  final String amount;
  final bool bounce;
  final FunctionCall? payload;
  final KnownPayload? knownPayload;

  const SendMessageModalBody({
    Key? key,
    required this.modalContext,
    required this.origin,
    required this.sender,
    required this.publicKey,
    required this.recipient,
    required this.amount,
    required this.bounce,
    required this.payload,
    required this.knownPayload,
  }) : super(key: key);

  @override
  _SendMessageModalBodyState createState() => _SendMessageModalBodyState();
}

class _SendMessageModalBodyState extends State<SendMessageModalBody> {
  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Column(
                  children: [
                    ModalHeader(
                      text: 'Send message',
                      onCloseButtonPressed: Navigator.of(widget.modalContext).pop,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: ModalScrollController.of(context),
                        physics: const ClampingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            card(),
                            const SizedBox(height: 64),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      buttons(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget card() => SectionedCard(
        sections: [
          origin(),
          address(),
          publicKey(),
          recipient(),
          amount(),
          bounce(),
          ...knownPayload(),
        ],
      );

  Widget origin() => SectionedCardSection(
        title: 'Origin',
        subtitle: widget.origin,
        isSelectable: true,
      );

  Widget address() => SectionedCardSection(
        title: 'Account address',
        subtitle: widget.sender,
        isSelectable: true,
      );

  Widget publicKey() => SectionedCardSection(
        title: 'Account public key',
        subtitle: widget.publicKey,
        isSelectable: true,
      );

  Widget recipient() => SectionedCardSection(
        title: 'Recipient address',
        subtitle: widget.recipient,
        isSelectable: true,
      );

  Widget amount() => SectionedCardSection(
        title: 'Amount',
        subtitle: '${widget.amount.toTokens().removeZeroes()} TON',
        isSelectable: true,
      );

  Widget bounce() => SectionedCardSection(
        title: 'Bounce',
        subtitle: widget.bounce ? 'Yes' : 'No',
        isSelectable: true,
      );

  List<Widget> knownPayload() {
    final knownPayload = widget.knownPayload?.when(
      comment: (value) => value.isNotEmpty
          ? Tuple2(
              'Comment',
              {
                'Comment': value,
              },
            )
          : null,
      tokenOutgoingTransfer: (tokenOutgoingTransfer) => Tuple2(
        'Token outgoing transfer',
        {
          ...tokenOutgoingTransfer.to.when(
            ownerWallet: (address) => {
              'Owner wallet': address,
            },
            tokenWallet: (address) => {
              'Token wallet': address,
            },
          ),
          'Tokens': tokenOutgoingTransfer.tokens,
        },
      ),
      tokenSwapBack: (tokenSwapBack) => Tuple2(
        'Token swap back',
        {
          'Tokens': tokenSwapBack.tokens,
          'Callback address': tokenSwapBack.callbackAddress,
          'Callback payload': tokenSwapBack.callbackPayload,
        },
      ),
    );

    if (knownPayload == null) {
      return [
        const SizedBox(),
      ];
    }

    final list = {
      'Known payload': knownPayload.item1,
      ...knownPayload.item2,
    };

    return list.entries
        .map(
          (e) => SectionedCardSection(
            title: e.key,
            subtitle: e.value,
            isSelectable: true,
          ),
        )
        .toList();
  }

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
        onPressed: () => Navigator.of(widget.modalContext).pop(null),
        text: 'Reject',
      );

  Widget submitButton() => Consumer(
        builder: (context, ref, child) => CustomElevatedButton(
          onPressed: () => onSubmitPressed(read: ref.read, publicKey: widget.publicKey),
          text: 'Send',
        ),
      );

  Future<void> onSubmitPressed({
    required Reader read,
    required String publicKey,
  }) async {
    String? password;

    final info = await read(biometryInfoProvider.future);

    if (info.isAvailable && info.isEnabled) {
      password = await getPasswordFromBiometry(publicKey);
    }

    if (!mounted) return;

    if (password != null) {
      Navigator.of(widget.modalContext).pop(password);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PasswordEnterPage(
            modalContext: widget.modalContext,
            publicKey: publicKey,
            onSubmit: (password) => Navigator.of(widget.modalContext).pop(password),
          ),
        ),
      );
    }
  }

  Future<String?> getPasswordFromBiometry(String publicKey) async {
    try {
      final password = await getIt.get<BiometryRepository>().getKeyPassword(
            localizedReason: 'Please authenticate to interact with wallet',
            publicKey: publicKey,
          );

      return password;
    } catch (err) {
      return null;
    }
  }
}
