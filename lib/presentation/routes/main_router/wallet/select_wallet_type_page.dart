import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tuple/tuple.dart';

import '../../../design/design.dart';
import '../../../design/widgets/custom_dropdown_button.dart';
import '../../../design/widgets/custom_elevated_button.dart';
import '../../../design/widgets/custom_text_button.dart';
import '../../../design/widgets/custom_text_form_field.dart';
import '../../../design/widgets/keyboard_padding.dart';
import '../../../design/widgets/modal_title.dart';
import '../../router.gr.dart';

class SelectWalletTypePage extends StatefulWidget {
  const SelectWalletTypePage({Key? key}) : super(key: key);

  @override
  _SelectWalletTypePageState createState() => _SelectWalletTypePageState();
}

class _SelectWalletTypePageState extends State<SelectWalletTypePage> {
  final initialCustodiansCount = 3;
  final optionsNotifier = ValueNotifier<_WalletCreationOptions>(_WalletCreationOptions.standard);
  late final ValueNotifier<int> custodiansNotifier;
  final custodiansNumberController = TextEditingController();
  late final List<TextEditingController> list;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    custodiansNotifier = ValueNotifier<int>(initialCustodiansCount);
    list = List.generate(initialCustodiansCount, (index) => TextEditingController());
  }

  @override
  void dispose() {
    optionsNotifier.dispose();
    custodiansNotifier.dispose();
    for (final item in list) {
      item.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            final focusScope = FocusScope.of(context);

            if (focusScope.hasFocus) {
              focusScope.unfocus();
            }
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              backgroundColor: Colors.black,
            ),
            body: SafeArea(
              child: KeyboardPadding(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: title(),
                        ),
                      ],
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            dropdownButton(),
                            multisigOptions(),
                          ],
                        ),
                      ),
                    ),
                    nextButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Widget title() => const Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: ModalTitle('Select wallet type to create'),
      );

  Widget dropdownButton() => Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 16,
        ),
        child: ValueListenableBuilder<_WalletCreationOptions>(
          valueListenable: optionsNotifier,
          builder: (context, value, child) => CustomDropdownButton<_WalletCreationOptions>(
            items: _WalletCreationOptions.values.map((e) => Tuple2(e, e.describe())).toList(),
            value: value,
            onChanged: (value) {
              if (value != null) {
                optionsNotifier.value = value;
              }
            },
          ),
        ),
      );

  Widget multisigOptions() => ValueListenableBuilder<_WalletCreationOptions>(
        valueListenable: optionsNotifier,
        builder: (context, value, child) => value == _WalletCreationOptions.multisignature
            ? Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      smallTitle('Any transaction requires the confirmation of:'),
                      const SizedBox(height: 8),
                      custodiansNumberField(),
                      const SizedBox(height: 8),
                      bigTitle('Custodians'),
                      const SizedBox(height: 16),
                      publicKeyList(),
                      const SizedBox(height: 16),
                      addPublicKeyButton(),
                    ],
                  ),
                ),
              )
            : const SizedBox(),
      );

  Widget nextButton() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: CustomElevatedButton(
          onPressed: () => context.router.push(const DeployYourWalletRoute()),
          text: 'Next',
        ),
      );

  Widget smallTitle(String text) => Text(
        text,
        style: const TextStyle(
          color: Colors.black38,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      );

  Widget bigTitle(String text) => Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      );

  Widget custodiansNumberField() => ValueListenableBuilder<int>(
        valueListenable: custodiansNotifier,
        builder: (context, value, child) => CustomTextFormField(
          controller: custodiansNumberController,
          keyboardType: const TextInputType.numberWithOptions(signed: true),
          textInputAction: TextInputAction.next,
          autocorrect: false,
          enableSuggestions: false,
          hintText: 'Enter number...',
          suffixIcon: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'out of $value custodians',
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          onFieldSubmitted: (value) => FocusScope.of(context).nextFocus(),
        ),
      );

  Widget publicKeyList() => ValueListenableBuilder<int>(
        valueListenable: custodiansNotifier,
        builder: (context, value, child) => ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: value,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) => publicKeyListItem(
            value: value,
            index: index,
          ),
        ),
      );

  Widget publicKeyListItem({
    required int value,
    required int index,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          smallTitle('Public key of Custodian ${index + 1}'),
          const SizedBox(height: 8),
          CustomTextFormField(
            keyboardType: const TextInputType.numberWithOptions(signed: true),
            textInputAction: TextInputAction.next,
            autocorrect: false,
            enableSuggestions: false,
            hintText: 'Enter public key...',
            suffixIcon: value == index + 1 && value > 2
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomTextButton(
                          onPressed: () {
                            if (custodiansNotifier.value > 2) {
                              custodiansNotifier.value -= 1;
                            }
                          },
                          text: 'Delete',
                          style: const TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
            onFieldSubmitted: (value) => FocusScope.of(context).nextFocus(),
          ),
        ],
      );

  Widget addPublicKeyButton() => CustomTextButton(
        onPressed: () {
          if (custodiansNotifier.value < 32) {
            custodiansNotifier.value += 1;
          }
        },
        text: '+ Add one more public key',
        style: const TextStyle(
          color: CrystalColor.accent,
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
