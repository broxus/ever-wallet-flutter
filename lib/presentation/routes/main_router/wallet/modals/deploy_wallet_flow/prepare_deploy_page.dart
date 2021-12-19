import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:tuple/tuple.dart';
import 'package:validators/validators.dart';

import '../../../../../design/design.dart';
import '../../../../../design/widgets/custom_dropdown_button.dart';
import '../../../../../design/widgets/custom_elevated_button.dart';
import '../../../../../design/widgets/custom_text_button.dart';
import '../../../../../design/widgets/custom_text_form_field.dart';
import '../../../../../design/widgets/modal_header.dart';
import '../../../../../design/widgets/text_field_clear_button.dart';
import '../../../../../design/widgets/text_suffix_icon_button.dart';
import '../../../../../design/widgets/unfocusing_gesture_detector.dart';
import 'deployment_info_page.dart';

class PrepareDeployPage extends StatefulWidget {
  final BuildContext modalContext;
  final String address;
  final String publicKey;

  const PrepareDeployPage({
    Key? key,
    required this.modalContext,
    required this.address,
    required this.publicKey,
  }) : super(key: key);

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
                    text: 'Select wallet type to create',
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
                          dropdownButton(),
                          const SizedBox(height: 16),
                          multisigOptions(),
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

  Widget dropdownButton() => ValueListenableBuilder<_WalletCreationOptions>(
        valueListenable: optionNotifier,
        builder: (context, value, child) => CustomDropdownButton<_WalletCreationOptions>(
          items: _WalletCreationOptions.values.map((e) => Tuple2(e, e.describe())).toList(),
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
                        fieldHeader('Any transaction requires the confirmation of:'),
                        const SizedBox(height: 8),
                        countField(),
                        const SizedBox(height: 16),
                        sectionTitle('Custodians'),
                        const SizedBox(height: 16),
                        list(),
                        addButton(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
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
          name: 'count',
          controller: countController,
          focusNode: countFocusNode,
          keyboardType: const TextInputType.numberWithOptions(signed: true),
          textInputAction: TextInputAction.next,
          autocorrect: false,
          enableSuggestions: false,
          hintText: 'Enter number...',
          suffixIcon: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'out of $custodiansValue custodians',
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
              return 'Invalid value';
            }

            if (number < 1 || number > custodiansValue) {
              return 'Invalid value';
            }
          },
        ),
      );

  Widget list() => ValueListenableBuilder<int>(
        valueListenable: custodiansNotifier,
        builder: (context, value, child) => ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: value,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
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
          fieldHeader('Public key of Custodian ${index + 1}'),
          const SizedBox(height: 8),
          CustomTextFormField(
            name: 'custodian_${index + 1}',
            controller: controllers[index],
            focusNode: focusNodes[index],
            textInputAction: index != custodians - 1 ? TextInputAction.next : TextInputAction.done,
            autocorrect: false,
            enableSuggestions: false,
            hintText: 'Enter public key...',
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
                return 'Invalid value';
              }

              if (value.length != 64) {
                return 'Invalid value';
              }
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

      WidgetsBinding.instance?.addPostFrameCallback((_) {
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
                  const SizedBox(height: 16),
                  CustomTextButton(
                    onPressed: addCustodian,
                    text: '+ Add one more public key',
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
                  builder: (context, value, child) => CustomElevatedButton(
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
                    text: 'Next',
                  ),
                )
              : CustomElevatedButton(
                  onPressed: onPressed,
                  text: 'Next',
                ),
        ),
      );

  void onPressed({
    List<String>? custodians,
    int? reqConfirms,
  }) =>
      Navigator.of(context).push(
        MaterialPageRoute(
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
  String describe() {
    switch (this) {
      case _WalletCreationOptions.standard:
        return 'Standard wallet';
      case _WalletCreationOptions.multisignature:
        return 'Multisignature wallet';
    }
  }
}
