import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';
import 'package:validators/validators.dart';

import '../../../../../../logger.dart';
import '../../../../../../providers/key/keys_provider.dart';
import '../../../../../../providers/key/public_keys_labels_provider.dart';
import '../../../../../../providers/token_wallet/token_wallet_info_provider.dart';
import '../../../../../design/design.dart';
import '../../../../../design/widgets/crystal_flushbar.dart';
import '../../../../../design/widgets/custom_checkbox.dart';
import '../../../../../design/widgets/custom_dropdown_button.dart';
import '../../../../../design/widgets/custom_elevated_button.dart';
import '../../../../../design/widgets/custom_text_form_field.dart';
import '../../../../../design/widgets/modal_header.dart';
import '../../../../../design/widgets/text_field_clear_button.dart';
import '../../../../../design/widgets/text_suffix_icon_button.dart';
import '../../../../../design/widgets/unfocusing_gesture_detector.dart';
import '../common/check_camera_permission.dart';
import '../common/parse_scan_result.dart';
import '../common/scanner_widget.dart';
import 'token_send_info_page.dart';

class PrepareTokenTransferPage extends StatefulWidget {
  final BuildContext modalContext;
  final String owner;
  final String rootTokenContract;
  final List<String> publicKeys;

  const PrepareTokenTransferPage({
    Key? key,
    required this.modalContext,
    required this.owner,
    required this.rootTokenContract,
    required this.publicKeys,
  }) : super(key: key);

  @override
  _PrepareTokenTransferPageState createState() => _PrepareTokenTransferPageState();
}

class _PrepareTokenTransferPageState extends State<PrepareTokenTransferPage> {
  final formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final amountFocusNode = FocusNode();
  final destinationController = TextEditingController();
  final destinationFocusNode = FocusNode();
  final commentController = TextEditingController();
  final commentFocusNode = FocusNode();
  final notifyReceiverNotifier = ValueNotifier<bool>(false);
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
    notifyReceiverNotifier.dispose();
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
                    text: 'Send your funds',
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
                          form(),
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
              const SizedBox(height: 16),
            ],
            amount(),
            const SizedBox(height: 8),
            balance(),
            const SizedBox(height: 16),
            destination(),
            const SizedBox(height: 16),
            comment(),
            const SizedBox(height: 16),
            notifyReceiver(),
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

  Widget dropdownButton() => Consumer(
        builder: (context, ref, child) {
          final publicKeysLabels = ref.watch(publicKeysLabelsProvider).asData?.value ?? {};
          final keys = ref.watch(keysProvider).asData?.value ?? {};
          final keysList = [
            ...keys.keys,
            ...keys.values.whereNotNull().expand((e) => e),
          ];

          return ValueListenableBuilder<String>(
            valueListenable: publicKeyNotifier,
            builder: (context, value, child) => CustomDropdownButton<String>(
              items: widget.publicKeys.map(
                (e) {
                  final title = keysList.firstWhereOrNull((el) => el.publicKey == e)?.name ??
                      publicKeysLabels[e] ??
                      e.ellipsePublicKey();

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
        name: 'amount',
        controller: amountController,
        focusNode: amountFocusNode,
        keyboardType: const TextInputType.numberWithOptions(
          signed: true,
          decimal: true,
        ),
        textInputAction: TextInputAction.next,
        autocorrect: false,
        enableSuggestions: false,
        hintText: 'Amount...',
        onSubmitted: (value) => destinationFocusNode.requestFocus(),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFieldClearButton(controller: amountController),
            maxButton(),
          ],
        ),
        inputFormatters: [
          FilteringTextInputFormatter.deny(RegExp(r'\s')),
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
        ],
        validator: (value) {
          if (value == null || value.isEmpty) {
            return null;
          }

          if (!isNumeric(value) && !isFloat(value)) {
            return 'Invalid value';
          }
          return null;
        },
      );

  Widget maxButton() => Consumer(
        builder: (context, ref, child) {
          final tokenWalletInfo = ref
              .watch(
                tokenWalletInfoProvider(
                  Tuple2(widget.owner, widget.rootTokenContract),
                ),
              )
              .asData
              ?.value;

          return SuffixIconButton(
            onPressed: () async {
              amountController.text =
                  tokenWalletInfo?.balance.toTokens(tokenWalletInfo.symbol.decimals).removeZeroes() ?? '0';
              amountController.selection =
                  TextSelection.fromPosition(TextPosition(offset: amountController.text.length));

              Form.of(context)?.validate();
            },
            icon: const SizedBox(
              width: 64,
              child: Text(
                'Max',
                style: TextStyle(
                  color: CrystalColor.accent,
                ),
              ),
            ),
          );
        },
      );

  Widget balance() => Consumer(
        builder: (context, ref, child) {
          final tokenWalletInfo = ref
              .watch(
                tokenWalletInfoProvider(
                  Tuple2(widget.owner, widget.rootTokenContract),
                ),
              )
              .asData
              ?.value;

          return Text(
            'Your balance: ${tokenWalletInfo?.balance.toTokens(tokenWalletInfo.symbol.decimals).removeZeroes() ?? '0'} ${tokenWalletInfo?.symbol.name}',
            style: const TextStyle(
              color: Colors.black54,
            ),
          );
        },
      );

  Widget destination() => CustomTextFormField(
        name: 'destination',
        controller: destinationController,
        focusNode: destinationFocusNode,
        textInputAction: TextInputAction.next,
        autocorrect: false,
        enableSuggestions: false,
        hintText: 'Receiver address...',
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
            return 'Invalid value';
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
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (!mounted) return;

    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => const ScannerWidget(),
      ),
    );

    if (result != null) {
      try {
        final parsed = await parseScanResult(result);

        destinationController.text = parsed.item1;
        if (parsed.item2 != null) amountController.text = parsed.item2!;
      } catch (err, st) {
        logger.e(err, err, st);

        if (!mounted) return;

        await showErrorCrystalFlushbar(
          context,
          message: err.toString(),
        );
      }
    }
  }

  Widget comment() => CustomTextFormField(
        name: 'Comment',
        controller: commentController,
        focusNode: commentFocusNode,
        autocorrect: false,
        enableSuggestions: false,
        hintText: 'Comment...',
        suffixIcon: TextFieldClearButton(controller: commentController),
      );

  Widget notifyReceiver() => Row(
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: notifyReceiverNotifier,
            builder: (context, value, child) => CustomCheckbox(
              value: value,
              onChanged: (value) => notifyReceiverNotifier.value = value ?? false,
            ),
          ),
          const Expanded(
            child: Text('Notify receiver'),
          ),
        ],
      );

  Widget submitButton() => Consumer(
        builder: (context, ref, child) {
          final tokenWalletInfo = ref
              .watch(
                tokenWalletInfoProvider(
                  Tuple2(widget.owner, widget.rootTokenContract),
                ),
              )
              .asData
              ?.value;

          return ValueListenableBuilder<bool>(
            valueListenable: formValidityNotifier,
            builder: (context, value, child) => CustomElevatedButton(
              onPressed: value && tokenWalletInfo != null ? () => onPressed(tokenWalletInfo.symbol.decimals) : null,
              text: 'Next',
            ),
          );
        },
      );

  void onPressed(int decimals) {
    final destination = destinationController.text;
    final amount = amountController.text.fromTokens(decimals);
    final notifyReceiver = notifyReceiverNotifier.value;
    final comment = commentController.text.isNotEmpty ? commentController.text : null;
    final publicKey = publicKeyNotifier.value;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TokenSendInfoPage(
          modalContext: widget.modalContext,
          owner: widget.owner,
          rootTokenContract: widget.rootTokenContract,
          publicKey: publicKey,
          destination: destination,
          amount: amount,
          notifyReceiver: notifyReceiver,
          comment: comment,
        ),
      ),
    );
  }
}
