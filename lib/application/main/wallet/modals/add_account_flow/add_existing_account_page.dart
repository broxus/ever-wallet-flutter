import 'package:ever_wallet/application/common/general/button/primary_elevated_button.dart';
import 'package:ever_wallet/application/common/general/flushbar.dart';
import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/application/common/widgets/crystal_subtitle.dart';
import 'package:ever_wallet/application/common/widgets/custom_back_button.dart';
import 'package:ever_wallet/application/common/widgets/custom_text_form_field.dart';
import 'package:ever_wallet/application/common/widgets/text_field_clear_button.dart';
import 'package:ever_wallet/application/common/widgets/unfocusing_gesture_detector.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/application/util/styles.dart';
import 'package:ever_wallet/data/extensions.dart';
import 'package:ever_wallet/data/repositories/accounts_repository.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

class AddExistingAccountPage extends StatefulWidget {
  final BuildContext modalContext;
  final String publicKey;

  const AddExistingAccountPage({
    super.key,
    required this.modalContext,
    required this.publicKey,
  });

  @override
  _NewSelectWalletTypePageState createState() => _NewSelectWalletTypePageState();
}

class _NewSelectWalletTypePageState extends State<AddExistingAccountPage> {
  final formKey = GlobalKey<FormState>();
  final addressController = TextEditingController();
  final nameController = TextEditingController();
  final addressFocusNode = FocusNode();
  final nameFocusNode = FocusNode();
  final formValidityNotifier = ValueNotifier<String?>('');

  @override
  void dispose() {
    addressController.dispose();
    nameController.dispose();
    addressFocusNode.dispose();
    nameFocusNode.dispose();
    formValidityNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => UnfocusingGestureDetector(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            leading: const CustomBackButton(),
            title: Text(
              context.localization.add_existing_account,
              style: StylesRes.header3Text.copyWith(color: ColorsRes.black),
            ),
          ),
          body: body(),
        ),
      );

  Widget body() => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              subtitle(),
              const Gap(16),
              Expanded(child: form()),
              const Gap(16),
              submitButton(),
            ],
          ),
        ),
      );

  Widget subtitle() => CrystalSubtitle(
        text: context.localization.add_existing_account_description,
      );

  Widget form() => Form(
        key: formKey,
        onChanged: onChanged,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            addressField(),
            const Gap(16),
            nameField(),
            validationText(),
          ],
        ),
      );

  void onChanged() {
    formKey.currentState?.validate();

    String? text;

    if (!validateAddress(addressController.text)) {
      text = context.localization.invalid_address;
    }

    if (addressController.text.isEmpty && nameController.text.isEmpty) {
      text = '';
    }

    formValidityNotifier.value = text;
  }

  Widget addressField() => CustomTextFormField(
        name: context.localization.address,
        controller: addressController,
        focusNode: addressFocusNode,
        autocorrect: false,
        cursorColor: ColorsRes.black,
        enableSuggestions: false,
        textInputAction: TextInputAction.next,
        hintText: '${context.localization.address}...',
        suffixIcon: TextFieldClearButton(controller: addressController),
        onSubmitted: (value) => nameFocusNode.requestFocus(),
        validator: (String? value) {
          if (value == null || value.isEmpty) {
            return null;
          }

          if (!validateAddress(value)) {
            return value;
          }
          return null;
        },
      );

  Widget nameField() => CustomTextFormField(
        name: context.localization.name,
        controller: nameController,
        focusNode: nameFocusNode,
        autocorrect: false,
        enableSuggestions: false,
        cursorColor: ColorsRes.black,
        hintText: '${context.localization.name}...',
        suffixIcon: TextFieldClearButton(
          controller: nameController,
        ),
      );

  Widget validationText() => ValueListenableBuilder<String?>(
        valueListenable: formValidityNotifier,
        builder: (context, value, child) => value != null && value.isNotEmpty
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Gap(16),
                  Container(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        color: CrystalColor.error,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.25,
                      ),
                    ),
                  ),
                ],
              )
            : const SizedBox(),
      );

  Widget submitButton() => ValueListenableBuilder<String?>(
        valueListenable: formValidityNotifier,
        builder: (context, value, child) => PrimaryElevatedButton(
          onPressed: value != null ? null : onPressed,
          text: context.localization.confirm,
        ),
      );

  Future<void> onPressed() async {
    final name = nameController.text.trim().isNotEmpty ? nameController.text.trim() : null;

    Navigator.of(widget.modalContext).pop();

    try {
      final currentKey = context.read<KeysRepository>().currentKey;

      await context.read<AccountsRepository>().addExternalAccount(
            publicKey: currentKey!,
            address: addressController.text,
            name: name,
          );
    } catch (err) {
      logger.e(err, err);

      if (!mounted) return;

      showErrorFlushbar(
        widget.modalContext,
        message: (err as Exception).toUiMessage(),
      );
    }
  }
}
