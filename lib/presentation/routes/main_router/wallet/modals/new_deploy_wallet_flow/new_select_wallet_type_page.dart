import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:tuple/tuple.dart';

import '../../../../../design/design.dart';
import '../../../../../design/widgets/crystal_title.dart';
import '../../../../../design/widgets/custom_close_button.dart';
import '../../../../../design/widgets/custom_dropdown_button.dart';
import '../../../../../design/widgets/custom_elevated_button.dart';
import '../../../../../design/widgets/custom_text_button.dart';
import '../../../../../design/widgets/custom_text_form_field.dart';
import '../../../../../design/widgets/text_suffix_icon_button.dart';
import '../../../../../design/widgets/unfocusing_gesture_detector.dart';
import 'deploy_your_wallet_page.dart';

class NewSelectWalletTypePage extends StatefulWidget {
  final BuildContext modalContext;
  final String address;
  final String publicKey;

  const NewSelectWalletTypePage({
    Key? key,
    required this.modalContext,
    required this.address,
    required this.publicKey,
  }) : super(key: key);

  @override
  _NewSelectWalletTypePageState createState() => _NewSelectWalletTypePageState();
}

class _NewSelectWalletTypePageState extends State<NewSelectWalletTypePage> {
  final formKey = GlobalKey<FormState>();
  final initialCustodiansCount = 3;
  final minCustodiansCount = 2;
  final maxCustodiansCount = 32;
  final optionNotifier = ValueNotifier<_WalletCreationOptions>(_WalletCreationOptions.standard);
  late ValueNotifier<int> custodiansNotifier;
  final custodiansNumberController = TextEditingController();
  late final List<TextEditingController> controllers;
  late final List<FocusNode> focusNodes;
  final formValidityNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    custodiansNotifier = ValueNotifier<int>(initialCustodiansCount);
    controllers = List.generate(initialCustodiansCount, (index) => TextEditingController());
    focusNodes = List.generate(initialCustodiansCount, (index) => FocusNode());
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
    custodiansNumberController.dispose();
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
                    dropdownButton(),
                    const SizedBox(height: 16),
                    multisigOptions(),
                    const SizedBox(height: 64),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    nextButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget title() => const CrystalTitle(
        text: 'Select wallet type to create',
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

  Widget nextButton() => CustomElevatedButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => DeployYourWalletPage(
            modalContext: widget.modalContext,
            address: widget.address,
          ),
        )),
        text: 'Next',
      );

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
          controller: custodiansNumberController,
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
          onFieldSubmitted: (value) => focusNodes.first.requestFocus(),
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
            } else if (number < 1 || number > custodiansValue) {
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
            controller: controllers[index],
            focusNode: focusNodes[index],
            textInputAction: index != custodians - 1 ? TextInputAction.next : TextInputAction.done,
            autocorrect: false,
            enableSuggestions: false,
            hintText: 'Enter public key...',
            suffixIcon: suffixIcons(index),
            onFieldSubmitted: (value) {
              if (index != custodians - 1) {
                focusNodes[index + 1].requestFocus();
              }
            },
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'\s')),
              FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return null;
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
          SuffixIconButton(
            onPressed: () {
              controllers[index].clear();
              Form.of(context)?.validate();
            },
            icon: Assets.images.iconCross.svg(),
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

      await Future.delayed(const Duration(seconds: 1));

      controller.dispose();
      focusNode.dispose();
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
    }
  }
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
