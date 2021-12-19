import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../data/repositories/external_accounts_repository.dart';
import '../../../../../injection.dart';
import '../../../../../logger.dart';
import '../../../../design/design.dart';
import '../../../../design/widgets/crystal_flushbar.dart';
import '../../../../design/widgets/custom_elevated_button.dart';
import '../../../../design/widgets/custom_text_form_field.dart';
import '../../../../design/widgets/modal_header.dart';
import '../../../../design/widgets/text_field_clear_button.dart';

class AddExternalAccountModalBody extends StatefulWidget {
  final String publicKey;

  const AddExternalAccountModalBody({
    Key? key,
    required this.publicKey,
  }) : super(key: key);

  @override
  State<AddExternalAccountModalBody> createState() => _AddExternalAccountModalBodyState();
}

class _AddExternalAccountModalBodyState extends State<AddExternalAccountModalBody> {
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
  Widget build(BuildContext context) => SizedBox(
        height: MediaQuery.of(context).size.longestSide / 1.75,
        child: Material(
          color: Colors.white,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const ModalHeader(text: 'Add external account'),
                  const SizedBox(height: 16),
                  fields(),
                  const Spacer(),
                  submitButton(),
                ],
              ),
            ),
          ),
        ),
      );

  Widget fields() => Form(
        key: formKey,
        onChanged: onChanged,
        child: Column(
          children: [
            addressField(),
            const SizedBox(height: 16),
            nameField(),
            validationText(),
          ],
        ),
      );

  void onChanged() {
    formKey.currentState?.validate();

    String? text;

    if (!validateAddress(addressController.text)) {
      text = 'Invalid address';
    }

    if (addressController.text.isEmpty && nameController.text.isEmpty) {
      text = '';
    }

    formValidityNotifier.value = text;
  }

  Widget addressField() => CustomTextFormField(
        name: 'address',
        controller: addressController,
        focusNode: addressFocusNode,
        autocorrect: false,
        enableSuggestions: false,
        textInputAction: TextInputAction.next,
        hintText: 'Address...',
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
        },
      );

  Widget nameField() => CustomTextFormField(
        name: 'name',
        controller: nameController,
        focusNode: nameFocusNode,
        autocorrect: false,
        enableSuggestions: false,
        hintText: 'Name...',
        suffixIcon: TextFieldClearButton(
          controller: nameController,
        ),
      );

  Widget validationText() => ValueListenableBuilder<String?>(
        valueListenable: formValidityNotifier,
        builder: (context, value, child) => value != null && value.isNotEmpty
            ? Column(
                children: [
                  const SizedBox(height: 16),
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
          onPressed: value != null ? null : onSubmitButtonPressed,
          text: LocaleKeys.actions_confirm.tr(),
        ),
      );

  Future<void> onSubmitButtonPressed() async {
    try {
      await getIt.get<ExternalAccountsRepository>().addExternalAccount(
            address: addressController.text,
            name: nameController.text.trim().isNotEmpty ? nameController.text.trim() : null,
          );
    } catch (err, st) {
      logger.e(err, err, st);

      showErrorCrystalFlushbar(context, message: err.toString());
    }

    if (!mounted) return;

    Navigator.of(context).pop();
  }
}
