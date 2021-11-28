import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:validators/validators.dart';

import '../../../../../../domain/blocs/ton_wallet/ton_wallet_info_bloc.dart';
import '../../../../../../domain/models/ton_wallet_info.dart';
import '../../../../../../injection.dart';
import '../../../../../design/design.dart';
import '../../../../../design/widgets/crystal_title.dart';
import '../../../../../design/widgets/custom_close_button.dart';
import '../../../../../design/widgets/custom_elevated_button.dart';
import '../../../../../design/widgets/custom_text_form_field.dart';
import '../../../../../design/widgets/text_field_clear_button.dart';
import '../../../../../design/widgets/text_suffix_icon_button.dart';
import '../../../../../design/widgets/unfocusing_gesture_detector.dart';
import '../../../main_router_page.dart';
import '../common/check_camera_permission.dart';
import '../common/parse_scan_result.dart';
import '../common/scanner_widget.dart';
import 'send_info_page.dart';

class PrepareTransferPage extends StatefulWidget {
  final BuildContext modalContext;
  final String address;

  const PrepareTransferPage({
    Key? key,
    required this.modalContext,
    required this.address,
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
  final bloc = getIt.get<TonWalletInfoBloc>();

  @override
  void initState() {
    super.initState();
    bloc.add(TonWalletInfoEvent.load(widget.address));
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
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => UnfocusingGestureDetector(
        child: Scaffold(
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: title(),
                        ),
                        CustomCloseButton(
                          onPressed: Navigator.of(widget.modalContext).pop,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    form(),
                    const SizedBox(height: 16),
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

  Widget title() => const CrystalTitle(
        text: 'Send your funds',
      );

  Widget form() => Form(
        key: formKey,
        onChanged: onFormChanged,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            amount(),
            const SizedBox(height: 8),
            balance(),
            const SizedBox(height: 16),
            destination(),
            const SizedBox(height: 16),
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
            return 'Invalid value';
          }
        },
      );

  Widget balance() => BlocBuilder<TonWalletInfoBloc, TonWalletInfo?>(
        bloc: bloc,
        builder: (context, state) => Text(
          'Your balance: ${state?.contractState.balance.toTokens().removeZeroes() ?? '0'} TON',
          style: const TextStyle(
            color: Colors.black54,
          ),
        ),
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

    final result = await Navigator.of(mainRouterPageKey.currentContext ?? context).push<String>(
      MaterialPageRoute(
        builder: (context) => const ScannerWidget(),
      ),
    );

    if (result != null) {
      try {
        final parsed = await parseScanResult(result);

        destinationController.text = parsed.item1;
        if (parsed.item2 != null) amountController.text = parsed.item2!;
        if (parsed.item3 != null) commentController.text = parsed.item3!;
      } catch (err) {
        if (!mounted) return;

        await showErrorCrystalFlushbar(
          context,
          message: err.toString(),
        );
      }
    }
  }

  Widget comment() => CustomTextFormField(
        name: 'comment',
        controller: commentController,
        focusNode: commentFocusNode,
        autocorrect: false,
        enableSuggestions: false,
        hintText: 'Comment...',
        suffixIcon: TextFieldClearButton(controller: commentController),
      );

  Widget submitButton() => ValueListenableBuilder<bool>(
        valueListenable: formValidityNotifier,
        builder: (context, value, child) => CustomElevatedButton(
          onPressed: value ? onPressed : null,
          text: 'Next',
        ),
      );

  void onPressed() {
    final destination = destinationController.text;
    final amount = amountController.text.fromTokens();
    final comment = commentController.text.isNotEmpty ? commentController.text : null;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SendInfoPage(
          modalContext: widget.modalContext,
          address: widget.address,
          destination: destination,
          amount: amount,
          comment: comment,
        ),
      ),
    );
  }
}
