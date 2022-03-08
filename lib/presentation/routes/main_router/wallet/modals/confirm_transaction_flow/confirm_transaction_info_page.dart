import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../data/repositories/biometry_repository.dart';
import '../../../../../../injection.dart';
import '../../../../../../providers/biometry/biometry_availability_provider.dart';
import '../../../../../../providers/biometry/biometry_status_provider.dart';
import '../../../../../../providers/ton_wallet/ton_wallet_prepare_confirm_transaction_provider.dart';
import '../../../../../design/extension.dart';
import '../../../../../design/widgets/custom_back_button.dart';
import '../../../../../design/widgets/custom_elevated_button.dart';
import '../../../../../design/widgets/sectioned_card.dart';
import '../../../../../design/widgets/sectioned_card_section.dart';
import '../common/password_enter_page/password_enter_page.dart';
import '../common/send_result_page.dart';

class ConfirmTransactionInfoPage extends ConsumerStatefulWidget {
  final BuildContext modalContext;
  final String address;
  final String publicKey;
  final String transactionId;
  final String destination;
  final String amount;
  final String? comment;

  const ConfirmTransactionInfoPage({
    Key? key,
    required this.modalContext,
    required this.address,
    required this.publicKey,
    required this.transactionId,
    required this.destination,
    required this.amount,
    this.comment,
  }) : super(key: key);

  @override
  _NewSelectWalletTypePageState createState() => _NewSelectWalletTypePageState();
}

class _NewSelectWalletTypePageState extends ConsumerState<ConfirmTransactionInfoPage> {
  @override
  void initState() {
    super.initState();
    ref.read(tonWalletPrepareConfirmTransactionProvider.notifier).prepareConfirmTransaction(
          publicKey: widget.publicKey,
          address: widget.address,
          transactionId: widget.transactionId,
        );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: const CustomBackButton(),
          title: const Text(
            'Confirm transaction',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        body: body(),
      );

  Widget body() => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              SingleChildScrollView(
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
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    submitButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget card() => SectionedCard(
        sections: [
          recipient(),
          amount(),
          fee(),
          if (widget.comment != null) comment(),
        ],
      );

  Widget recipient() => SectionedCardSection(
        title: 'Recipient',
        subtitle: widget.destination,
        isSelectable: true,
      );

  Widget amount() => SectionedCardSection(
        title: 'Amount',
        subtitle: '${widget.amount.toTokens().removeZeroes()} EVER',
      );

  Widget fee() => Consumer(
        builder: (context, ref, child) {
          final result = ref.watch(tonWalletPrepareConfirmTransactionProvider);

          final subtitle = result.when(
            data: (data) => '${data.item2.toTokens().removeZeroes()} EVER',
            error: (err, st) => err.toString(),
            loading: () => null,
          );

          final hasError = result.maybeWhen(
            error: (error, stackTrace) => true,
            orElse: () => false,
          );

          return SectionedCardSection(
            title: 'Blockchain fee',
            subtitle: subtitle,
            hasError: hasError,
          );
        },
      );

  Widget comment() => SectionedCardSection(
        title: 'Comment',
        subtitle: widget.comment,
      );

  Widget submitButton() => Consumer(
        builder: (context, ref, child) {
          final result = ref.watch(tonWalletPrepareConfirmTransactionProvider).asData?.value;

          return CustomElevatedButton(
            onPressed: result?.item1 != null && result?.item2 != null
                ? () => onPressed(
                      read: ref.read,
                      message: result!.item1,
                      publicKey: widget.publicKey,
                    )
                : null,
            text: 'Send',
          );
        },
      );

  Future<void> onPressed({
    required Reader read,
    required UnsignedMessage message,
    required String publicKey,
  }) async {
    String? password;

    final isEnabled = await read(biometryStatusProvider.future);
    final isAvailable = await read(biometryAvailabilityProvider.future);

    if (isAvailable && isEnabled) {
      password = await getPasswordFromBiometry(publicKey);
    }

    if (!mounted) return;

    if (password != null) {
      pushDeploymentResult(
        message: message,
        password: password,
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => PasswordEnterPage(
            modalContext: widget.modalContext,
            publicKey: publicKey,
            onSubmit: (password) => pushDeploymentResult(
              message: message,
              password: password,
            ),
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

  Future<void> pushDeploymentResult({
    required UnsignedMessage message,
    required String password,
  }) =>
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => SendResultPage(
            modalContext: widget.modalContext,
            address: widget.address,
            message: message,
            publicKey: widget.publicKey,
            password: password,
            sendingText: 'Message is sending...',
            successText: 'Message has been sent successfully',
          ),
        ),
        (_) => false,
      );
}
