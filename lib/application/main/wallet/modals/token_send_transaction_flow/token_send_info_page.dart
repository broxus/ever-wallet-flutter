import 'package:ever_wallet/application/bloc/token_wallet/token_wallet_prepare_transfer_bloc.dart';
import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/async_value_stream_provider.dart';
import 'package:ever_wallet/application/common/constants.dart';
import 'package:ever_wallet/application/common/extensions.dart';
import 'package:ever_wallet/application/common/general/button/primary_elevated_button.dart';
import 'package:ever_wallet/application/common/widgets/custom_back_button.dart';
import 'package:ever_wallet/application/common/widgets/sectioned_card.dart';
import 'package:ever_wallet/application/common/widgets/sectioned_card_section.dart';
import 'package:ever_wallet/application/main/wallet/modals/common/password_enter_page/password_enter_page.dart';
import 'package:ever_wallet/application/main/wallet/modals/common/token_send_result_page.dart';
import 'package:ever_wallet/data/models/unsigned_message_with_additional_info.dart';
import 'package:ever_wallet/data/repositories/biometry_repository.dart';
import 'package:ever_wallet/data/repositories/token_wallets_repository.dart';
import 'package:ever_wallet/data/repositories/ton_wallets_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class TokenSendInfoPage extends StatefulWidget {
  final BuildContext modalContext;
  final String owner;
  final String rootTokenContract;
  final String publicKey;
  final String destination;
  final String amount;
  final bool notifyReceiver;
  final String? comment;

  const TokenSendInfoPage({
    super.key,
    required this.modalContext,
    required this.owner,
    required this.rootTokenContract,
    required this.publicKey,
    required this.destination,
    required this.amount,
    required this.notifyReceiver,
    this.comment,
  });

  @override
  _NewSelectWalletTypePageState createState() => _NewSelectWalletTypePageState();
}

class _NewSelectWalletTypePageState extends State<TokenSendInfoPage> {
  @override
  Widget build(BuildContext context) => BlocProvider<TokenWalletPrepareTransferBloc>(
        key: ValueKey('${widget.owner}_${widget.rootTokenContract}'),
        create: (context) => TokenWalletPrepareTransferBloc(
          context.read<TokenWalletsRepository>(),
          context.read<TonWalletsRepository>(),
          widget.owner,
          widget.rootTokenContract,
        )..add(
            TokenWalletPrepareTransferEvent.prepareTransfer(
              publicKey: widget.publicKey,
              destination: widget.destination,
              amount: widget.amount,
              notifyReceiver: widget.notifyReceiver,
              payload: widget.comment,
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
          notifyReceiver(),
        ],
      );

  Widget recipient() => SectionedCardSection(
        title: AppLocalizations.of(context)!.recipient,
        subtitle: widget.destination,
        isSelectable: true,
      );

  Widget amount() => AsyncValueStreamProvider<TokenWalletInfo?>(
        create: (context) => context.read<TokenWalletsRepository>().getInfoStream(
              owner: widget.owner,
              rootTokenContract: widget.rootTokenContract,
            ),
        builder: (context, child) {
          final tokenWalletInfo = context.watch<AsyncValue<TokenWalletInfo?>>().maybeWhen(
                ready: (value) => value,
                orElse: () => null,
              );

          return SectionedCardSection(
            title: AppLocalizations.of(context)!.amount,
            subtitle: tokenWalletInfo != null
                ? '${widget.amount.toTokens(tokenWalletInfo.symbol.decimals).removeZeroes()} ${tokenWalletInfo.symbol.name}'
                : null,
          );
        },
      );

  Widget fee() => BlocBuilder<TokenWalletPrepareTransferBloc, TokenWalletPrepareTransferState>(
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

  Widget notifyReceiver() => SectionedCardSection(
        title: AppLocalizations.of(context)!.notify_receiver,
        subtitle: widget.notifyReceiver
            ? AppLocalizations.of(context)!.yes
            : AppLocalizations.of(context)!.no,
      );

  Widget submitButton() =>
      BlocBuilder<TokenWalletPrepareTransferBloc, TokenWalletPrepareTransferState>(
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
      pushTokenSendResult(
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
            onSubmit: (password) => pushTokenSendResult(
              message: message,
              publicKey: publicKey,
              password: password,
            ),
          ),
        ),
      );
    }
  }

  Future<String?> getPasswordFromBiometry(String ownerPublicKey) async {
    try {
      final password = await context.read<BiometryRepository>().getKeyPassword(
            localizedReason: AppLocalizations.of(context)!.authentication_reason,
            publicKey: ownerPublicKey,
          );

      return password;
    } catch (err) {
      return null;
    }
  }

  Future<void> pushTokenSendResult({
    required UnsignedMessageWithAdditionalInfo message,
    required String publicKey,
    required String password,
  }) =>
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => TokenSendResultPage(
            modalContext: widget.modalContext,
            owner: widget.owner,
            rootTokenContract: widget.rootTokenContract,
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
