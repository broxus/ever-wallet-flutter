import 'dart:async';

import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/constants.dart';
import 'package:ever_wallet/application/common/extensions.dart';
import 'package:ever_wallet/application/common/general/button/ew_dropdown_button.dart';
import 'package:ever_wallet/application/common/general/button/primary_elevated_button.dart';
import 'package:ever_wallet/application/common/general/flushbar.dart';
import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/application/common/widgets/custom_text_form_field.dart';
import 'package:ever_wallet/application/common/widgets/modal_header.dart';
import 'package:ever_wallet/application/common/widgets/text_field_clear_button.dart';
import 'package:ever_wallet/application/common/widgets/text_suffix_icon_button.dart';
import 'package:ever_wallet/application/common/widgets/unfocusing_gesture_detector.dart';
import 'package:ever_wallet/application/main/wallet/modals/common/check_camera_permission.dart';
import 'package:ever_wallet/application/main/wallet/modals/common/parse_scan_result.dart';
import 'package:ever_wallet/application/main/wallet/modals/common/scanner_widget.dart';
import 'package:ever_wallet/application/main/wallet/modals/send_transaction_flow/send_info_page.dart';
import 'package:ever_wallet/data/extensions.dart';
import 'package:ever_wallet/data/models/ton_wallet_info.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:ever_wallet/data/repositories/ton_wallets_repository.dart';
import 'package:ever_wallet/generated/assets.gen.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:validators/validators.dart';

class PrepareTransferPage extends StatefulWidget {
  final BuildContext modalContext;
  final String address;
  final List<String> publicKeys;

  const PrepareTransferPage({
    Key? key,
    required this.modalContext,
    required this.address,
    required this.publicKeys,
  }) : super(key: key);

  @override
  _PrepareTransferPageState createState() => _PrepareTransferPageState();
}

class _PrepareTransferPageState extends State<PrepareTransferPage> {
  final formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final amountFocusNode = FocusNode();
  final destinationController = TextEditingController();
  final destinationFocusNode = FocusNode();
  final commentController = TextEditingController();
  final commentFocusNode = FocusNode();
  final formValidityNotifier = ValueNotifier<bool>(false);
  late final ValueNotifier<String> publicKeyNotifier;

  @override
  void initState() {
    super.initState();
    publicKeyNotifier = ValueNotifier<String>(widget.publicKeys.first);
  }

  @override
  void dispose() {
    amountController.dispose();
    amountFocusNode.dispose();
    destinationController.dispose();
    destinationFocusNode.dispose();
    commentController.dispose();
    commentFocusNode.dispose();
    formValidityNotifier.dispose();
    publicKeyNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => UnfocusingGestureDetector(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: body(),
        ),
      );

  Widget body() => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Column(
                children: [
                  ModalHeader(
                    text: AppLocalizations.of(context)!.send_funds,
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
                          form(),
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
      );

  Widget form() => Form(
        key: formKey,
        onChanged: onFormChanged,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.publicKeys.length > 1) ...[
              dropdownButton(),
              const Gap(16),
            ],
            amount(),
            const Gap(8),
            balance(),
            const Gap(16),
            destination(),
            const Gap(16),
            comment(),
          ],
        ),
      );

  void onFormChanged() {
    if (amountController.text.isEmpty || destinationController.text.isEmpty) {
      formValidityNotifier.value = false;
      return;
    }

    formValidityNotifier.value = formKey.currentState?.validate() ?? false;
  }

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
            builder: (context, value, child) => EWDropdownButton<String>(
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

  Widget amount() => CustomTextFormField(
        name: AppLocalizations.of(context)!.amount,
        controller: amountController,
        focusNode: amountFocusNode,
        keyboardType: const TextInputType.numberWithOptions(
          signed: true,
          decimal: true,
        ),
        textInputAction: TextInputAction.next,
        autocorrect: false,
        enableSuggestions: false,
        hintText: '${AppLocalizations.of(context)!.amount}...',
        suffixIcon: TextFieldClearButton(controller: amountController),
        onSubmitted: (value) => destinationFocusNode.requestFocus(),
        inputFormatters: [
          FilteringTextInputFormatter.deny(RegExp(r'\s')),
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
        ],
        validator: (value) {
          if (value == null || value.isEmpty) {
            return null;
          }

          if (!isNumeric(value) && !isFloat(value)) {
            return AppLocalizations.of(context)!.invalid_value;
          }
          return null;
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

  Widget destination() => CustomTextFormField(
        name: AppLocalizations.of(context)!.destination,
        controller: destinationController,
        focusNode: destinationFocusNode,
        textInputAction: TextInputAction.next,
        autocorrect: false,
        enableSuggestions: false,
        hintText: '${AppLocalizations.of(context)!.receiver_address}...',
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFieldClearButton(controller: destinationController),
            pasteButton(),
            scanButton(),
          ],
        ),
        onSubmitted: (value) => commentFocusNode.requestFocus(),
        inputFormatters: [
          FilteringTextInputFormatter.deny(RegExp(r'\s')),
        ],
        validator: (value) {
          if (value == null || value.isEmpty) {
            return null;
          }

          if (!validateAddress(value)) {
            return AppLocalizations.of(context)!.invalid_value;
          }
          return null;
        },
      );

  Widget pasteButton() => SuffixIconButton(
        onPressed: () async {
          final data = await Clipboard.getData(Clipboard.kTextPlain);

          destinationController.text = data?.text ?? '';
          destinationController.selection =
              TextSelection.fromPosition(TextPosition(offset: destinationController.text.length));

          if (!mounted) return;

          Form.of(context)?.validate();
        },
        icon: Assets.images.iconPaste.svg(
          color: CrystalColor.accent,
        ),
      );

  Widget scanButton() => SuffixIconButton(
        onPressed: () async {
          await scan();

          if (!mounted) return;

          Form.of(context)?.validate();
        },
        icon: Assets.images.iconQr.svg(
          color: CrystalColor.accent,
        ),
      );

  Future<void> scan() async {
    if (!await checkCameraPermission()) {
      return;
    }

    if (!mounted) return;

    final focusNode = FocusScope.of(context);

    if (focusNode.hasFocus) {
      focusNode.unfocus();
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }

    if (!mounted) return;

    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => const ScannerWidget(),
      ),
    );

    if (result != null) {
      try {
        final parsed = await parseScanResult(context: context, value: result);

        destinationController.text = parsed.item1;
        if (parsed.item2 != null) amountController.text = parsed.item2!;
        if (parsed.item3 != null) commentController.text = parsed.item3!;
      } catch (err, st) {
        logger.e(err, err, st);

        if (!mounted) return;

        await showErrorFlushbar(
          context,
          message: (err as Exception).toUiMessage(),
        );
      }
    }
  }

  Widget comment() => CustomTextFormField(
        name: AppLocalizations.of(context)!.comment,
        controller: commentController,
        focusNode: commentFocusNode,
        autocorrect: false,
        enableSuggestions: false,
        hintText: '${AppLocalizations.of(context)!.comment}...',
        suffixIcon: TextFieldClearButton(controller: commentController),
      );

  Widget submitButton() => ValueListenableBuilder<bool>(
        valueListenable: formValidityNotifier,
        builder: (context, value, child) => PrimaryElevatedButton(
          onPressed: value ? onPressed : null,
          text: AppLocalizations.of(context)!.next,
        ),
      );

  void onPressed() {
    final destination = destinationController.text;
    final amount = amountController.text.toNanoTokens();
    final comment = commentController.text.isNotEmpty ? commentController.text : null;
    final publicKey = publicKeyNotifier.value;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => SendInfoPage(
          modalContext: widget.modalContext,
          address: widget.address,
          publicKey: publicKey,
          destination: destination,
          amount: amount,
          comment: comment,
        ),
      ),
    );
  }
}
