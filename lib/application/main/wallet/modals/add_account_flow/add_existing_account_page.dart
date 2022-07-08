import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/application/common/widgets/crystal_flushbar.dart';
import 'package:ever_wallet/application/common/widgets/crystal_subtitle.dart';
import 'package:ever_wallet/application/common/widgets/custom_back_button.dart';
import 'package:ever_wallet/application/common/widgets/custom_elevated_button.dart';
import 'package:ever_wallet/application/common/widgets/custom_text_form_field.dart';
import 'package:ever_wallet/application/common/widgets/text_field_clear_button.dart';
import 'package:ever_wallet/application/common/widgets/unfocusing_gesture_detector.dart';
import 'package:ever_wallet/data/extensions.dart';
import 'package:ever_wallet/data/repositories/accounts_repository.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

class AddExistingAccountPage extends StatefulWidget {
  final BuildContext modalContext;
  final String publicKey;

  const AddExistingAccountPage({
    Key? key,
    required this.modalContext,
    required this.publicKey,
  }) : super(key: key);

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
              AppLocalizations.of(context)!.add_existing_account,
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          body: body(),
        ),
      );

  Widget body() => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: ModalScrollController.of(context),
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    children: [
                      subtitle(),
                      const Gap(16),
                      form(),
                    ],
                  ),
                ),
              ),
              const Gap(16),
              submitButton(),
            ],
          ),
        ),
      );

  Widget subtitle() => CrystalSubtitle(
        text: AppLocalizations.of(context)!.add_existing_account_description,
      );

  Widget form() => Form(
        key: formKey,
        onChanged: onChanged,
        child: Column(
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
      text = AppLocalizations.of(context)!.invalid_address;
    }

    if (addressController.text.isEmpty && nameController.text.isEmpty) {
      text = '';
    }

    formValidityNotifier.value = text;
  }

  Widget addressField() => CustomTextFormField(
        name: AppLocalizations.of(context)!.address,
        controller: addressController,
        focusNode: addressFocusNode,
        autocorrect: false,
        enableSuggestions: false,
        textInputAction: TextInputAction.next,
        hintText: '${AppLocalizations.of(context)!.address}...',
        suffixIcon: TextFieldClearButton(
          controller: addressController,
        ),
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
        name: AppLocalizations.of(context)!.name,
        controller: nameController,
        focusNode: nameFocusNode,
        autocorrect: false,
        enableSuggestions: false,
        hintText: '${AppLocalizations.of(context)!.name}...',
        suffixIcon: TextFieldClearButton(
          controller: nameController,
        ),
      );

  Widget validationText() => ValueListenableBuilder<String?>(
        valueListenable: formValidityNotifier,
        builder: (context, value, child) => value != null && value.isNotEmpty
            ? Column(
                children: [
                  const Gap(16),
                  Container(
                    width: double.infinity,
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
        builder: (context, value, child) => CustomElevatedButton(
          onPressed: value != null ? null : onPressed,
          text: AppLocalizations.of(context)!.confirm,
        ),
      );

  Future<void> onPressed() async {
    final name = nameController.text.trim().isNotEmpty ? nameController.text.trim() : null;

    Navigator.of(widget.modalContext).pop();

    try {
      final currentKey = context.read<KeysRepository>().currentKey;

      await context.read<AccountsRepository>().addExternalAccount(
            publicKey: currentKey!.publicKey,
            address: addressController.text,
            name: name,
          );
    } catch (err) {
      logger.e(err, err);

      if (!mounted) return;

      showErrorCrystalFlushbar(
        widget.modalContext,
        message: (err as Exception).toUiMessage(),
      );
    }
  }
}
