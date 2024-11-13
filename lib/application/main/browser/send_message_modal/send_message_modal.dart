import 'package:ever_wallet/application/bloc/ton_wallet/ton_wallet_prepare_transfer_bloc.dart';
import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/async_value_stream_provider.dart';
import 'package:ever_wallet/application/common/extensions.dart';
import 'package:ever_wallet/application/common/widgets/custom_dropdown_button.dart';
import 'package:ever_wallet/application/common/widgets/custom_elevated_button.dart';
import 'package:ever_wallet/application/common/widgets/custom_outlined_button.dart';
import 'package:ever_wallet/application/common/widgets/modal_header.dart';
import 'package:ever_wallet/application/common/widgets/sectioned_card.dart';
import 'package:ever_wallet/application/common/widgets/sectioned_card_section.dart';
import 'package:ever_wallet/application/common/widgets/transport_builder.dart';
import 'package:ever_wallet/application/common/widgets/tx_errors.dart';
import 'package:ever_wallet/application/main/browser/common/selected_public_key_cubit.dart';
import 'package:ever_wallet/application/main/common/extensions.dart';
import 'package:ever_wallet/application/main/common/get_password_from_biometry.dart';
import 'package:ever_wallet/application/main/wallet/modals/common/password_enter_page/password_enter_page.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:ever_wallet/data/repositories/ton_wallets_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

class SendMessagePage extends StatefulWidget {
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
    super.key,
    required this.modalContext,
    required this.origin,
    required this.sender,
    required this.publicKeys,
    required this.recipient,
    required this.amount,
    required this.bounce,
    required this.payload,
    required this.knownPayload,
  });

  @override
  _SendMessageModalState createState() => _SendMessageModalState();
}

class _SendMessageModalState extends State<SendMessagePage> {
  bool isConfirmed = false;

  @override
  Widget build(BuildContext context) => BlocProvider<SelectedPublicKeyCubit>(
        create: (context) => SelectedPublicKeyCubit(widget.publicKeys.first),
        child: BlocProvider<TonWalletPrepareTransferBloc>(
          key: ValueKey(widget.sender),
          create: (context) => TonWalletPrepareTransferBloc(
            context.read<TonWalletsRepository>(),
            widget.sender,
          )..add(
              TonWalletPrepareTransferEvent.prepareTransfer(
                publicKey: widget.publicKeys.first,
                destination: widget.recipient,
                amount: widget.amount,
              ),
            ),
          child: BlocListener<SelectedPublicKeyCubit, String>(
            listener: (context, state) =>
                context.read<TonWalletPrepareTransferBloc>().add(
                      TonWalletPrepareTransferEvent.prepareTransfer(
                        publicKey: state,
                        destination: widget.recipient,
                        amount: widget.amount,
                      ),
                    ),
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ModalHeader(
                        text: AppLocalizations.of(context)!.send_message,
                        onCloseButtonPressed:
                            Navigator.of(widget.modalContext).pop,
                      ),
                      const Gap(16),
                      if (widget.publicKeys.length > 1) ...[
                        dropdownButton(),
                        const Gap(16),
                      ],
                      Expanded(
                        child: SingleChildScrollView(
                          controller: ModalScrollController.of(context),
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
            ),
          ),
        ),
      );

  Widget dropdownButton() => BlocBuilder<SelectedPublicKeyCubit, String?>(
        builder: (context, state) {
          if (state == null) return const SizedBox();

          return AsyncValueStreamProvider<Map<String, String>>(
            create: (context) => context.read<KeysRepository>().keyLabelsStream,
            builder: (context, child) {
              final publicKeysLabels =
                  context.watch<AsyncValue<Map<String, String>>>().maybeWhen(
                        ready: (value) => value,
                        orElse: () => <String, String>{},
                      );

              return CustomDropdownButton<String>(
                items: widget.publicKeys
                    .map(
                      (e) => Tuple2(
                        e,
                        publicKeysLabels[e] ?? e.ellipsePublicKey(),
                      ),
                    )
                    .toList(),
                value: state,
                onChanged: (value) {
                  if (value != null) {
                    context.read<SelectedPublicKeyCubit>().select(value);
                  }
                },
              );
            },
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

  Widget amount() => TransportBuilderWidget(
        builder: (context, data) {
          return SectionedCardSection(
            title: AppLocalizations.of(context)!.amount,
            subtitle:
                '${widget.amount.toTokens().removeZeroes()} ${data.config.symbol}',
            isSelectable: true,
          );
        },
      );

  Widget fee() => TransportBuilderWidget(
        builder: (context, data) {
          return BlocBuilder<TonWalletPrepareTransferBloc,
              TonWalletPrepareTransferState>(
            builder: (context, state) {
              final subtitle = state.when(
                initial: () => null,
                loading: () => null,
                ready: (unsignedMessage, fees, txErrors) =>
                    '${fees.toTokens().removeZeroes()} ${data.config.symbol}',
                error: (error) => error,
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

  Widget bounce() => SectionedCardSection(
        title: AppLocalizations.of(context)!.bounce,
        subtitle: widget.bounce
            ? AppLocalizations.of(context)!.yes
            : AppLocalizations.of(context)!.no,
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

  Widget buttons() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          txError(),
          Row(
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
          ),
        ],
      );

  Widget txError() =>
      BlocBuilder<TonWalletPrepareTransferBloc, TonWalletPrepareTransferState>(
        builder: (context, state) {
          final txErrors = state.maybeWhen(
            ready: (_, __, txErrors) => txErrors,
            orElse: () => null,
          );

          if (txErrors == null || txErrors.isEmpty) return const SizedBox();

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TxErrors(
              errors: txErrors,
              isConfirmed: isConfirmed,
              onConfirm: (value) => setState(() => isConfirmed = value),
            ),
          );
        },
      );

  Widget rejectButton() => CustomOutlinedButton(
        onPressed: () => Navigator.of(widget.modalContext).pop(),
        text: AppLocalizations.of(context)!.reject,
      );

  Widget submitButton() => BlocBuilder<SelectedPublicKeyCubit, String?>(
        builder: (context, state) {
          final selectedPublicKey = state;

          return BlocBuilder<TonWalletPrepareTransferBloc,
              TonWalletPrepareTransferState>(
            builder: (context, state) {
              final result = state.when(
                initial: () => null,
                loading: () => null,
                ready: (unsignedMessage, fees, txErrors) =>
                    Tuple3(unsignedMessage, fees, txErrors),
                error: (error) => null,
              );

              return CustomElevatedButton(
                onPressed: selectedPublicKey != null &&
                        result != null &&
                        (result.item3.isEmpty || isConfirmed)
                    ? () => onSubmitPressed(selectedPublicKey)
                    : null,
                text: AppLocalizations.of(context)!.send,
              );
            },
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
      Navigator.of(widget.modalContext)
          .pop(Tuple2(selectedPublicKey, password));
    } else {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => PasswordEnterPage(
            modalContext: widget.modalContext,
            publicKey: selectedPublicKey,
            onSubmit: (password) => Navigator.of(widget.modalContext)
                .pop(Tuple2(selectedPublicKey, password)),
          ),
        ),
      );
    }
  }
}
