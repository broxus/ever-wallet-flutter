import 'package:ever_wallet/application/common/general/button/primary_elevated_button.dart';
import 'package:ever_wallet/application/common/widgets/crystal_subtitle.dart';
import 'package:ever_wallet/application/common/widgets/custom_back_button.dart';
import 'package:ever_wallet/application/common/widgets/custom_text_form_field.dart';
import 'package:ever_wallet/application/common/widgets/text_field_clear_button.dart';
import 'package:ever_wallet/application/common/widgets/unfocusing_gesture_detector.dart';
import 'package:ever_wallet/application/main/wallet/modals/add_account_flow/add_new_account_type_page.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class AddNewAccountNamePage extends StatefulWidget {
  final BuildContext modalContext;
  final String publicKey;

  const AddNewAccountNamePage({
    super.key,
    required this.modalContext,
    required this.publicKey,
  });

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
              context.localization.new_account_name,
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
            mainAxisSize: MainAxisSize.min,
            children: [
              subtitle(),
              const Gap(16),
              Expanded(child: field()),
              const Gap(16),
              submitButton(),
            ],
          ),
        ),
      );

  Widget subtitle() => CrystalSubtitle(
        text: context.localization.new_account_description,
      );

  Widget field() => CustomTextFormField(
        name: context.localization.name,
        controller: controller,
        autocorrect: false,
        cursorColor: ColorsRes.black,
        enableSuggestions: false,
        hintText: '${context.localization.name}...',
        suffixIcon: TextFieldClearButton(
          controller: controller,
        ),
      );

  Widget submitButton() => PrimaryElevatedButton(
        onPressed: onPressed,
        text: context.localization.next,
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
