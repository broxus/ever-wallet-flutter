import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/constants.dart';
import 'package:ever_wallet/application/common/extensions.dart';
import 'package:ever_wallet/application/common/widgets/custom_dropdown_button.dart';
import 'package:ever_wallet/application/common/widgets/custom_elevated_button.dart';
import 'package:ever_wallet/application/common/widgets/modal_header.dart';
import 'package:ever_wallet/application/main/wallet/modals/confirm_transaction_flow/confirm_transaction_info_page.dart';
import 'package:ever_wallet/data/models/ton_wallet_info.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:ever_wallet/data/repositories/ton_wallets_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class PrepareConfirmTransactionPage extends StatefulWidget {
  final BuildContext modalContext;
  final String address;
  final List<String> publicKeys;
  final String transactionId;
  final String destination;
  final String amount;
  final String? comment;

  const PrepareConfirmTransactionPage({
    Key? key,
    required this.modalContext,
    required this.address,
    required this.publicKeys,
    required this.transactionId,
    required this.destination,
    required this.amount,
    this.comment,
  }) : super(key: key);

  @override
  _PrepareConfirmTransactionPageState createState() => _PrepareConfirmTransactionPageState();
}

class _PrepareConfirmTransactionPageState extends State<PrepareConfirmTransactionPage> {
  late final ValueNotifier<String> publicKeyNotifier;

  @override
  void initState() {
    super.initState();
    publicKeyNotifier = ValueNotifier<String>(widget.publicKeys.first);
  }

  @override
  void dispose() {
    publicKeyNotifier.dispose();
    super.dispose();
  }

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
                      text: AppLocalizations.of(context)!.confirm_transaction,
                      onCloseButtonPressed: Navigator.of(widget.modalContext).pop,
                    ),
                    const Gap(16),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: ModalScrollController.of(context),
                        physics: const ClampingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            dropdownButton(),
                            const Gap(8),
                            balance(),
                            const Gap(64),
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
                      submitButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget dropdownButton() => StreamProvider<AsyncValue<Map<String, String>>>(
        create: (context) =>
            context.read<KeysRepository>().labelsStream.map((event) => AsyncValue.ready(event)),
        initialData: const AsyncValue.loading(),
        catchError: (context, error) => AsyncValue.error(error),
        builder: (context, child) {
          final publicKeysLabels = context.watch<AsyncValue<Map<String, String>>>().maybeWhen(
                ready: (value) => value,
                orElse: () => <String, String>{},
              );

          return ValueListenableBuilder<String>(
            valueListenable: publicKeyNotifier,
            builder: (context, value, child) => CustomDropdownButton<String>(
              items: widget.publicKeys.map(
                (e) {
                  final title = publicKeysLabels[e] ?? e.ellipsePublicKey();

                  return Tuple2(
                    e,
                    title,
                  );
                },
              ).toList(),
              value: value,
              onChanged: (value) {
                if (value != null) {
                  publicKeyNotifier.value = value;
                }
              },
            ),
          );
        },
      );

  Widget balance() => StreamProvider<AsyncValue<TonWalletInfo?>>(
        create: (context) => context
            .read<TonWalletsRepository>()
            .getInfoStream(widget.address)
            .map((event) => AsyncValue.ready(event)),
        initialData: const AsyncValue.loading(),
        catchError: (context, error) => AsyncValue.error(error),
        builder: (context, child) {
          final tonWalletInfo = context.watch<AsyncValue<TonWalletInfo?>>().maybeWhen(
                ready: (value) => value,
                orElse: () => null,
              );

          return Text(
            AppLocalizations.of(context)!.balance(
              tonWalletInfo?.contractState.balance.toTokens().removeZeroes() ?? '0',
              kEverTicker,
            ),
            style: const TextStyle(
              color: Colors.black54,
            ),
          );
        },
      );

  Widget submitButton() => ValueListenableBuilder<String>(
        valueListenable: publicKeyNotifier,
        builder: (context, value, child) => CustomElevatedButton(
          onPressed: () => onPressed(value),
          text: AppLocalizations.of(context)!.next,
        ),
      );

  void onPressed(String publicKey) => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => ConfirmTransactionInfoPage(
            modalContext: widget.modalContext,
            address: widget.address,
            publicKey: publicKey,
            transactionId: widget.transactionId,
            destination: widget.destination,
            amount: widget.amount,
            comment: widget.comment,
          ),
        ),
      );
}
