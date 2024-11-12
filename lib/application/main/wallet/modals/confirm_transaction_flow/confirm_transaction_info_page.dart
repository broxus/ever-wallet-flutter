import 'dart:async';

import 'package:ever_wallet/application/bloc/ton_wallet/ton_wallet_prepare_confirm_transaction_bloc.dart';
import 'package:ever_wallet/application/common/extensions.dart';
import 'package:ever_wallet/application/common/general/button/primary_elevated_button.dart';
import 'package:ever_wallet/application/common/widgets/custom_back_button.dart';
import 'package:ever_wallet/application/common/widgets/sectioned_card.dart';
import 'package:ever_wallet/application/common/widgets/sectioned_card_section.dart';
import 'package:ever_wallet/application/common/widgets/transport_builder.dart';
import 'package:ever_wallet/application/main/wallet/modals/common/password_enter_page/password_enter_page.dart';
import 'package:ever_wallet/application/main/wallet/modals/common/send_result_page.dart';
import 'package:ever_wallet/data/models/unsigned_message_with_additional_info.dart';
import 'package:ever_wallet/data/repositories/biometry_repository.dart';
import 'package:ever_wallet/data/repositories/ton_wallets_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class ConfirmTransactionInfoPage extends StatefulWidget {
  final BuildContext modalContext;
  final String address;
  final String publicKey;
  final String transactionId;
  final String destination;
  final String amount;
  final String? comment;

  const ConfirmTransactionInfoPage({
    super.key,
    required this.modalContext,
    required this.address,
    required this.publicKey,
    required this.transactionId,
    required this.destination,
    required this.amount,
    this.comment,
  });

  @override
  _NewSelectWalletTypePageState createState() =>
      _NewSelectWalletTypePageState();
}

class _NewSelectWalletTypePageState extends State<ConfirmTransactionInfoPage> {
  @override
  Widget build(BuildContext context) =>
      BlocProvider<TonWalletPrepareConfirmTransactionBloc>(
        key: ValueKey(widget.address),
        create: (context) => TonWalletPrepareConfirmTransactionBloc(
          context.read<TonWalletsRepository>(),
          widget.address,
        )..add(
            TonWalletPrepareConfirmTransactionEvent.prepareConfirmTransaction(
              publicKey: widget.publicKey,
              transactionId: widget.transactionId,
            ),
          ),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            leading: CustomBackButton(
              onPressed: () => Navigator.of(widget.modalContext).pop(),
            ),
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

  Widget amount() => TransportBuilderWidget(
        builder: (context, data) {
          final ticker = data.config.symbol;

          return SectionedCardSection(
            title: AppLocalizations.of(context)!.amount,
            subtitle:
                '${widget.amount.toTokens().removeZeroes().formatValue()} $ticker',
          );
        },
      );

  Widget fee() => TransportBuilderWidget(
        builder: (context, data) {
          return BlocBuilder<TonWalletPrepareConfirmTransactionBloc,
              TonWalletPrepareConfirmTransactionState>(
            builder: (context, state) {
              final subtitle = state.maybeWhen(
                ready: (unsignedMessage, fees) =>
                    '${fees.toTokens().removeZeroes()} ${data.config.symbol}',
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
        },
      );

  Widget comment() => SectionedCardSection(
        title: AppLocalizations.of(context)!.comment,
        subtitle: widget.comment,
      );

  Widget submitButton() => BlocBuilder<TonWalletPrepareConfirmTransactionBloc,
          TonWalletPrepareConfirmTransactionState>(
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
    required UnsignedMessageWithAdditionalInfo message,
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
      final password = await context.read<BiometryRepository>().getKeyPassword(
            localizedReason:
                AppLocalizations.of(context)!.authentication_reason,
            publicKey: publicKey,
          );

      return password;
    } catch (err) {
      return null;
    }
  }

  Future<void> pushDeploymentResult({
    required UnsignedMessageWithAdditionalInfo message,
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
            sendingText: AppLocalizations.of(context)!.message_sending,
            successText: AppLocalizations.of(context)!.message_sent,
          ),
        ),
        (_) => false,
      );
}
