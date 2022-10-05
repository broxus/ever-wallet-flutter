import 'dart:async';

import 'package:ever_wallet/application/common/general/button/ew_dropdown_button.dart';
import 'package:ever_wallet/application/common/general/button/primary_elevated_button.dart';
import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/application/common/widgets/custom_text_button.dart';
import 'package:ever_wallet/application/common/widgets/custom_text_form_field.dart';
import 'package:ever_wallet/application/common/widgets/modal_header.dart';
import 'package:ever_wallet/application/common/widgets/text_field_clear_button.dart';
import 'package:ever_wallet/application/common/widgets/text_suffix_icon_button.dart';
import 'package:ever_wallet/application/common/widgets/unfocusing_gesture_detector.dart';
import 'package:ever_wallet/application/main/wallet/modals/deploy_wallet_flow/deployment_info_page.dart';
import 'package:ever_wallet/generated/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:tuple/tuple.dart';
import 'package:validators/validators.dart';

class PrepareDeployPage extends StatefulWidget {
  final BuildContext modalContext;
  final String address;
  final String publicKey;

  const PrepareDeployPage({
    super.key,
    required this.modalContext,
    required this.address,
    required this.publicKey,
  });

  @override
  _PrepareDeployPageState createState() => _PrepareDeployPageState();
}

class _PrepareDeployPageState extends State<PrepareDeployPage> {
  final formKey = GlobalKey<FormState>();
  final initialCustodiansCount = 3;
  final minCustodiansCount = 2;
  final maxCustodiansCount = 32;
  final optionNotifier = ValueNotifier<_WalletCreationOptions>(_WalletCreationOptions.standard);
  late ValueNotifier<int> custodiansNotifier;
  final countController = TextEditingController();
  final countFocusNode = FocusNode();
  late final List<TextEditingController> controllers;
  late final List<FocusNode> focusNodes;
  final formValidityNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    custodiansNotifier = ValueNotifier<int>(initialCustodiansCount);
    controllers = List.generate(initialCustodiansCount, (_) => TextEditingController());
    focusNodes = List.generate(initialCustodiansCount, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final item in controllers) {
      item.dispose();
    }
    for (final item in focusNodes) {
      item.dispose();
    }
    optionNotifier.dispose();
    custodiansNotifier.dispose();
    countController.dispose();
    countFocusNode.dispose();
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
                    text: AppLocalizations.of(context)!.select_wallet_type,
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
                          const Gap(16),
                          multisigOptions(),
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

  Widget dropdownButton() => ValueListenableBuilder<_WalletCreationOptions>(
        valueListenable: optionNotifier,
        builder: (context, value, child) => EWDropdownButton<_WalletCreationOptions>(
          items: _WalletCreationOptions.values.map((e) => Tuple2(e, e.describe(context))).toList(),
          value: value,
          onChanged: (value) {
            if (value != null) {
              optionNotifier.value = value;
            }
          },
        ),
      );

  Widget multisigOptions() => ValueListenableBuilder<_WalletCreationOptions>(
        valueListenable: optionNotifier,
        builder: (context, value, child) => value == _WalletCreationOptions.multisignature
            ? Column(
                children: [
                  Form(
                    key: formKey,
                    onChanged: onFormChanged,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        fieldHeader(AppLocalizations.of(context)!.transaction_required_confirms),
                        const Gap(8),
                        countField(),
                        const Gap(16),
                        sectionTitle(AppLocalizations.of(context)!.custodians),
                        const Gap(16),
                        list(),
                        addButton(),
                      ],
                    ),
                  ),
                  const Gap(16),
                ],
              )
            : const SizedBox(),
      );

  void onFormChanged() {
    if (countController.text.isEmpty || controllers.any((e) => e.text.isEmpty)) {
      formValidityNotifier.value = false;
      return;
    }

    formValidityNotifier.value = formKey.currentState?.validate() ?? false;
  }

  Widget fieldHeader(String text) => Text(
        text,
        style: const TextStyle(
          color: Colors.black54,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      );

  Widget sectionTitle(String text) => Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      );

  Widget countField() => ValueListenableBuilder<int>(
        valueListenable: custodiansNotifier,
        builder: (context, custodiansValue, child) => CustomTextFormField(
          name: AppLocalizations.of(context)!.count,
          controller: countController,
          focusNode: countFocusNode,
          keyboardType: const TextInputType.numberWithOptions(signed: true),
          textInputAction: TextInputAction.next,
          autocorrect: false,
          enableSuggestions: false,
          hintText: '${AppLocalizations.of(context)!.enter_number}...',
          suffixIcon: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              AppLocalizations.of(context)!.out_of_n_custodians('$custodiansValue'),
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          onSubmitted: (value) => focusNodes.first.requestFocus(),
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'\s')),
            FilteringTextInputFormatter.allow(RegExp('[0-9]')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return null;
            }

            final number = int.tryParse(value);

            if (number == null) {
              return AppLocalizations.of(context)!.invalid_value;
            }

            if (number < 1 || number > custodiansValue) {
              return AppLocalizations.of(context)!.invalid_value;
            }
            return null;
          },
        ),
      );

  Widget list() => ValueListenableBuilder<int>(
        valueListenable: custodiansNotifier,
        builder: (context, value, child) => ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: value,
          separatorBuilder: (context, index) => const Gap(16),
          itemBuilder: (context, index) => item(
            custodians: value,
            index: index,
          ),
        ),
      );

  Widget item({
    required int custodians,
    required int index,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          fieldHeader(AppLocalizations.of(context)!.public_key_of_custodian_n('${index + 1}')),
          const Gap(8),
          CustomTextFormField(
            name: AppLocalizations.of(context)!.custodian_n('${index + 1}'),
            controller: controllers[index],
            focusNode: focusNodes[index],
            textInputAction: index != custodians - 1 ? TextInputAction.next : TextInputAction.done,
            autocorrect: false,
            enableSuggestions: false,
            hintText: '${AppLocalizations.of(context)!.enter_public_key}...',
            suffixIcon: suffixIcons(index),
            onSubmitted: (value) {
              if (index != custodians - 1) {
                focusNodes[index + 1].requestFocus();
              }
            },
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'\s')),
              FilteringTextInputFormatter.allow(RegExp('[a-fA-F0-9]')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return null;
              }

              if (!isAlphanumeric(value)) {
                return AppLocalizations.of(context)!.invalid_value;
              }

              if (value.length != 64) {
                return AppLocalizations.of(context)!.invalid_value;
              }
              return null;
            },
            maxLength: 64,
          ),
        ],
      );

  Widget suffixIcons(int index) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFieldClearButton(
            controller: controllers[index],
          ),
          if (index != 0 && index != 1)
            SuffixIconButton(
              onPressed: () => removeCustodian(index),
              icon: Assets.images.iconTrash.svg(color: CrystalColor.error),
            ),
        ],
      );

  Future<void> removeCustodian(int index) async {
    if (custodiansNotifier.value > minCustodiansCount) {
      final controller = controllers.removeAt(index);
      final focusNode = focusNodes.removeAt(index);

      custodiansNotifier.value -= 1;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.dispose();
        focusNode.dispose();
        onFormChanged();
      });
    }
  }

  Widget addButton() => ValueListenableBuilder<int>(
        valueListenable: custodiansNotifier,
        builder: (context, value, child) => value < maxCustodiansCount
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Gap(16),
                  CustomTextButton(
                    onPressed: addCustodian,
                    text: AppLocalizations.of(context)!.add_public_key,
                    style: const TextStyle(
                      color: CrystalColor.accent,
                    ),
                  ),
                ],
              )
            : const SizedBox(),
      );

  void addCustodian() {
    if (custodiansNotifier.value < maxCustodiansCount) {
      controllers.add(TextEditingController());
      focusNodes.add(FocusNode());

      custodiansNotifier.value += 1;

      onFormChanged();
    }
  }

  Widget submitButton() => ValueListenableBuilder<_WalletCreationOptions>(
        valueListenable: optionNotifier,
        builder: (context, value, child) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: value == _WalletCreationOptions.multisignature
              ? ValueListenableBuilder<bool>(
                  valueListenable: formValidityNotifier,
                  builder: (context, value, child) => PrimaryElevatedButton(
                    onPressed: value
                        ? () {
                            final custodians = controllers.map((e) => e.text).toList();
                            final reqConfirms = int.tryParse(countController.text);

                            onPressed(
                              custodians: custodians,
                              reqConfirms: reqConfirms,
                            );
                          }
                        : null,
                    text: AppLocalizations.of(context)!.next,
                  ),
                )
              : PrimaryElevatedButton(
                  onPressed: onPressed,
                  text: AppLocalizations.of(context)!.next,
                ),
        ),
      );

  void onPressed({
    List<String>? custodians,
    int? reqConfirms,
  }) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => DeploymentInfoPage(
            modalContext: widget.modalContext,
            address: widget.address,
            publicKey: widget.publicKey,
            custodians: custodians,
            reqConfirms: reqConfirms,
          ),
        ),
      );
}

enum _WalletCreationOptions {
  standard,
  multisignature,
}

extension on _WalletCreationOptions {
  String describe(BuildContext context) {
    switch (this) {
      case _WalletCreationOptions.standard:
        return AppLocalizations.of(context)!.standard_wallet;
      case _WalletCreationOptions.multisignature:
        return AppLocalizations.of(context)!.multisignature_wallet;
    }
  }
}
