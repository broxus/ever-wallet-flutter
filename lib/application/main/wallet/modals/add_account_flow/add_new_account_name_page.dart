import 'package:ever_wallet/application/common/widgets/crystal_subtitle.dart';
import 'package:ever_wallet/application/common/widgets/custom_back_button.dart';
import 'package:ever_wallet/application/common/widgets/custom_elevated_button.dart';
import 'package:ever_wallet/application/common/widgets/custom_text_form_field.dart';
import 'package:ever_wallet/application/common/widgets/text_field_clear_button.dart';
import 'package:ever_wallet/application/common/widgets/unfocusing_gesture_detector.dart';
import 'package:ever_wallet/application/main/wallet/modals/add_account_flow/add_new_account_type_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class AddNewAccountNamePage extends StatefulWidget {
  final BuildContext modalContext;
  final String publicKey;

  const AddNewAccountNamePage({
    Key? key,
    required this.modalContext,
    required this.publicKey,
  }) : super(key: key);

  @override
  _NewSelectWalletTypePageState createState() => _NewSelectWalletTypePageState();
}

class _NewSelectWalletTypePageState extends State<AddNewAccountNamePage> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => UnfocusingGestureDetector(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            leading: const CustomBackButton(),
            title: Text(
              AppLocalizations.of(context)!.new_account_name,
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      subtitle(),
                      const Gap(16),
                      field(),
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
        text: AppLocalizations.of(context)!.new_account_description,
      );

  Widget field() => CustomTextFormField(
        name: AppLocalizations.of(context)!.name,
        controller: controller,
        autocorrect: false,
        enableSuggestions: false,
        hintText: '${AppLocalizations.of(context)!.name}...',
        suffixIcon: TextFieldClearButton(
          controller: controller,
        ),
      );

  Widget submitButton() => CustomElevatedButton(
        onPressed: onPressed,
        text: AppLocalizations.of(context)!.next,
      );

  Future<void> onPressed() async {
    final name = controller.text.trim().isNotEmpty ? controller.text.trim() : null;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => AddNewAccountTypePage(
          modalContext: widget.modalContext,
          publicKey: widget.publicKey,
          name: name,
        ),
      ),
    );
  }
}
