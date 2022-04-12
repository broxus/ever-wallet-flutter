import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../data/repositories/biometry_repository.dart';
import '../../../../../../injection.dart';
import '../../../../../../providers/biometry/biometry_availability_provider.dart';
import '../../../../../../providers/biometry/biometry_status_provider.dart';
import '../../../../../../providers/ton_wallet/ton_wallet_prepare_confirm_transaction_provider.dart';
import '../../../../../data/extensions.dart';
import '../../../../../generated/codegen_loader.g.dart';
import '../../../../common/constants.dart';
import '../../../../common/extensions.dart';
import '../../../../common/widgets/custom_back_button.dart';
import '../../../../common/widgets/custom_elevated_button.dart';
import '../../../../common/widgets/sectioned_card.dart';
import '../../../../common/widgets/sectioned_card_section.dart';
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
          title: Text(
            LocaleKeys.confirm_transaction.tr(),
            style: const TextStyle(
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
        title: LocaleKeys.recipient.tr(),
        subtitle: widget.destination,
        isSelectable: true,
      );

  Widget amount() => SectionedCardSection(
        title: LocaleKeys.amount.tr(),
        subtitle: '${widget.amount.toTokens().removeZeroes().formatValue()} $kEverTicker',
      );

  Widget fee() => Consumer(
        builder: (context, ref, child) {
          final result = ref.watch(tonWalletPrepareConfirmTransactionProvider);

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
            title: LocaleKeys.blockchain_fee.tr(),
            subtitle: subtitle,
            hasError: hasError,
          );
        },
      );

  Widget comment() => SectionedCardSection(
        title: LocaleKeys.comment.tr(),
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
            text: LocaleKeys.send.tr(),
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
            localizedReason: LocaleKeys.authentication_reason.tr(),
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
            sendingText: LocaleKeys.message_sending.tr(),
            successText: LocaleKeys.message_sent.tr(),
          ),
        ),
        (_) => false,
      );
}
