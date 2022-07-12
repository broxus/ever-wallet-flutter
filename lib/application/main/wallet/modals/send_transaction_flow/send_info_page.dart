import 'package:ever_wallet/application/bloc/ton_wallet/ton_wallet_prepare_transfer_bloc.dart';
import 'package:ever_wallet/application/common/constants.dart';
import 'package:ever_wallet/application/common/extensions.dart';
import 'package:ever_wallet/application/common/general/button/primary_elevated_button.dart';
import 'package:ever_wallet/application/common/widgets/custom_back_button.dart';
import 'package:ever_wallet/application/common/widgets/sectioned_card.dart';
import 'package:ever_wallet/application/common/widgets/sectioned_card_section.dart';
import 'package:ever_wallet/application/main/wallet/modals/common/password_enter_page/password_enter_page.dart';
import 'package:ever_wallet/application/main/wallet/modals/common/send_result_page.dart';
import 'package:ever_wallet/data/repositories/biometry_repository.dart';
import 'package:ever_wallet/data/repositories/ton_wallets_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

class SendInfoPage extends StatefulWidget {
  final BuildContext modalContext;
  final String address;
  final String publicKey;
  final String destination;
  final String amount;
  final String? comment;

  const SendInfoPage({
    Key? key,
    required this.modalContext,
    required this.address,
    required this.publicKey,
    required this.destination,
    required this.amount,
    this.comment,
  }) : super(key: key);

  @override
  _NewSelectWalletTypePageState createState() => _NewSelectWalletTypePageState();
}

class _NewSelectWalletTypePageState extends State<SendInfoPage> {
  @override
  Widget build(BuildContext context) => BlocProvider<TonWalletPrepareTransferBloc>(
        key: ValueKey(widget.address),
        create: (context) => TonWalletPrepareTransferBloc(
          context.read<TonWalletsRepository>(),
          widget.address,
        )..add(
            TonWalletPrepareTransferEvent.prepareTransfer(
              publicKey: widget.publicKey,
              destination: widget.destination,
              amount: widget.amount,
              body: widget.comment,
            ),
          ),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            leading: const CustomBackButton(),
            title: Text(
              AppLocalizations.of(context)!.confirm_transaction,
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          body: body(),
        ),
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
                    const Gap(64),
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
        title: AppLocalizations.of(context)!.recipient,
        subtitle: widget.destination,
        isSelectable: true,
      );

  Widget amount() => SectionedCardSection(
        title: AppLocalizations.of(context)!.amount,
        subtitle: '${widget.amount.toTokens().removeZeroes()} $kEverTicker',
      );

  Widget fee() => BlocBuilder<TonWalletPrepareTransferBloc, TonWalletPrepareTransferState>(
        builder: (context, state) {
          final subtitle = state.maybeWhen(
            ready: (unsignedMessage, fees) => '${fees.toTokens().removeZeroes()} $kEverTicker',
            error: (error) => error,
            orElse: () => null,
          );

          final hasError = state.maybeWhen(
            error: (error) => true,
            orElse: () => false,
          );

          return SectionedCardSection(
            title: AppLocalizations.of(context)!.blockchain_fee,
            subtitle: subtitle,
            hasError: hasError,
          );
        },
      );

  Widget comment() => SectionedCardSection(
        title: AppLocalizations.of(context)!.comment,
        subtitle: widget.comment,
      );

  Widget submitButton() => BlocBuilder<TonWalletPrepareTransferBloc, TonWalletPrepareTransferState>(
        builder: (context, state) => PrimaryElevatedButton(
          onPressed: state.maybeWhen(
            ready: (unsignedMessage, fees) => () => onPressed(
                  message: unsignedMessage,
                  publicKey: widget.publicKey,
                ),
            orElse: () => null,
          ),
          text: AppLocalizations.of(context)!.send,
        ),
      );

  Future<void> onPressed({
    required UnsignedMessage message,
    required String publicKey,
  }) async {
    String? password;

    final isEnabled = context.read<BiometryRepository>().status;
    final isAvailable = context.read<BiometryRepository>().availability;

    if (isAvailable && isEnabled) {
      password = await getPasswordFromBiometry(publicKey);
    }

    if (!mounted) return;

    if (password != null) {
      pushSendResult(
        message: message,
        publicKey: publicKey,
        password: password,
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => PasswordEnterPage(
            modalContext: widget.modalContext,
            publicKey: publicKey,
            onSubmit: (password) => pushSendResult(
              message: message,
              publicKey: publicKey,
              password: password,
            ),
          ),
        ),
      );
    }
  }

  Future<String?> getPasswordFromBiometry(String publicKey) async {
    try {
      final password = await context.read<BiometryRepository>().getKeyPassword(
            localizedReason: AppLocalizations.of(context)!.authentication_reason,
            publicKey: publicKey,
          );

      return password;
    } catch (err) {
      return null;
    }
  }

  Future<void> pushSendResult({
    required UnsignedMessage message,
    required String publicKey,
    required String password,
  }) =>
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => SendResultPage(
            modalContext: widget.modalContext,
            address: widget.address,
            message: message,
            publicKey: publicKey,
            password: password,
            sendingText: AppLocalizations.of(context)!.message_sending,
            successText: AppLocalizations.of(context)!.message_sent,
          ),
        ),
        (_) => false,
      );
}
