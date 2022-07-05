import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

import '../../../../../../providers/key/public_keys_labels_provider.dart';
import '../../../../data/extensions.dart';
import '../../../../providers/ton_wallet/ton_wallet_prepare_transfer_provider.dart';
import '../../../common/constants.dart';
import '../../../common/extensions.dart';
import '../../../common/widgets/custom_dropdown_button.dart';
import '../../../common/widgets/custom_elevated_button.dart';
import '../../../common/widgets/custom_outlined_button.dart';
import '../../../common/widgets/modal_header.dart';
import '../../../common/widgets/sectioned_card.dart';
import '../../../common/widgets/sectioned_card_section.dart';
import '../../common/extensions.dart';
import '../../common/get_password_from_biometry.dart';
import '../../wallet/modals/common/password_enter_page/password_enter_page.dart';
import 'send_message_modal_logic.dart';

class SendMessagePage extends ConsumerStatefulWidget {
  final BuildContext modalContext;
  final String origin;
  final String sender;
  final List<String> publicKeys;
  final String recipient;
  final String amount;
  final bool bounce;
  final FunctionCall? payload;
  final KnownPayload? knownPayload;

  const SendMessagePage({
    Key? key,
    required this.modalContext,
    required this.origin,
    required this.sender,
    required this.publicKeys,
    required this.recipient,
    required this.amount,
    required this.bounce,
    required this.payload,
    required this.knownPayload,
  }) : super(key: key);

  @override
  _SendMessageModalState createState() => _SendMessageModalState();
}

class _SendMessageModalState extends ConsumerState<SendMessagePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(selectedPublicKeyProvider.notifier).state = widget.publicKeys.firstOrNull,
    );
    ref.read(tonWalletPrepareTransferProvider.notifier).prepareTransfer(
          address: widget.sender,
          publicKey: widget.publicKeys.firstOrNull,
          destination: widget.recipient,
          amount: widget.amount,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(selectedPublicKeyProvider, (previous, next) {
      if (next != null) {
        ref.read(tonWalletPrepareTransferProvider.notifier).prepareTransfer(
              address: widget.sender,
              publicKey: next,
              destination: widget.recipient,
              amount: widget.amount,
            );
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ModalHeader(
                text: AppLocalizations.of(context)!.send_message,
                onCloseButtonPressed: Navigator.of(widget.modalContext).pop,
              ),
              const SizedBox(height: 16),
              if (widget.publicKeys.length > 1) ...[
                dropdownButton(),
                const SizedBox(height: 16),
              ],
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
  }

  Widget dropdownButton() => Consumer(
        builder: (context, ref, child) {
          final selectedPublicKey = ref.watch(selectedPublicKeyProvider);

          if (selectedPublicKey == null) return const SizedBox();

          final publicKeysLabels = ref.watch(publicKeysLabelsProvider).maybeWhen(
                data: (data) => data,
                orElse: () => <String, String>{},
              );

          return CustomDropdownButton<String>(
            items: widget.publicKeys.map((e) => Tuple2(e, publicKeysLabels[e] ?? e.ellipsePublicKey())).toList(),
            value: selectedPublicKey,
            onChanged: (value) => ref.read(selectedPublicKeyProvider.notifier).state = value,
          );
        },
      );

  Widget card() => SectionedCard(
        sections: [
          origin(),
          address(),
          if (widget.publicKeys.length == 1) publicKey(),
          recipient(),
          amount(),
          fee(),
          bounce(),
          ...knownPayload(),
        ],
      );

  Widget origin() => SectionedCardSection(
        title: AppLocalizations.of(context)!.origin,
        subtitle: widget.origin,
        isSelectable: true,
      );

  Widget address() => SectionedCardSection(
        title: AppLocalizations.of(context)!.account_address,
        subtitle: widget.sender,
        isSelectable: true,
      );

  Widget publicKey() => SectionedCardSection(
        title: AppLocalizations.of(context)!.account_public_key,
        subtitle: widget.publicKeys.first,
        isSelectable: true,
      );

  Widget recipient() => SectionedCardSection(
        title: AppLocalizations.of(context)!.recipient_address,
        subtitle: widget.recipient,
        isSelectable: true,
      );

  Widget amount() => SectionedCardSection(
        title: AppLocalizations.of(context)!.amount,
        subtitle: '${widget.amount.toTokens().removeZeroes()} $kEverTicker',
        isSelectable: true,
      );

  Widget fee() => Consumer(
        builder: (context, ref, child) {
          final result = ref.watch(tonWalletPrepareTransferProvider);

          final subtitle = result.when(
            data: (data) => '${data.item2.toTokens().removeZeroes()} $kEverTicker',
            error: (err, st) => (err as Exception).toUiMessage(),
            loading: () => null,
          );

          final hasError = result.maybeWhen(
            error: (error, stackTrace) => true,
            orElse: () => false,
          );

          return SectionedCardSection(
            title: AppLocalizations.of(context)!.blockchain_fee,
            subtitle: subtitle,
            hasError: hasError,
          );
        },
      );

  Widget bounce() => SectionedCardSection(
        title: AppLocalizations.of(context)!.bounce,
        subtitle: widget.bounce ? AppLocalizations.of(context)!.yes : AppLocalizations.of(context)!.no,
        isSelectable: true,
      );

  List<Widget> knownPayload() {
    final knownPayload = widget.knownPayload?.toRepresentableData(context);

    if (knownPayload == null) {
      return [
        const SizedBox(),
      ];
    }

    final list = {
      AppLocalizations.of(context)!.known_payload: knownPayload.item1,
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
        onPressed: () => Navigator.of(widget.modalContext).pop(),
        text: AppLocalizations.of(context)!.reject,
      );

  Widget submitButton() => Consumer(
        builder: (context, ref, child) {
          final selectedPublicKey = ref.watch(selectedPublicKeyProvider);
          final result = ref.watch(tonWalletPrepareTransferProvider).asData?.value;

          return PrimaryElevatedButton(
            onPressed: selectedPublicKey != null && result?.item1 != null && result?.item2 != null
                ? () => onSubmitPressed(selectedPublicKey)
                : null,
            text: AppLocalizations.of(context)!.send,
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
      Navigator.of(widget.modalContext).pop(Tuple2(selectedPublicKey, password));
    } else {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => PasswordEnterPage(
            modalContext: widget.modalContext,
            publicKey: selectedPublicKey,
            onSubmit: (password) => Navigator.of(widget.modalContext).pop(Tuple2(selectedPublicKey, password)),
          ),
        ),
      );
    }
  }
}
