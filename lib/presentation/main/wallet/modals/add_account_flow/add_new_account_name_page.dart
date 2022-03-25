import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../../../common/widgets/crystal_subtitle.dart';
import '../../../../common/widgets/custom_back_button.dart';
import '../../../../common/widgets/custom_elevated_button.dart';
import '../../../../common/widgets/custom_text_form_field.dart';
import '../../../../common/widgets/text_field_clear_button.dart';
import '../../../../common/widgets/unfocusing_gesture_detector.dart';
import 'add_new_account_type_page.dart';

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
            title: const Text(
              'New account name',
              style: TextStyle(
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
                      const SizedBox(height: 16),
                      field(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              submitButton(),
            ],
          ),
        ),
      );

  Widget subtitle() => const CrystalSubtitle(
        text:
            'You will get a new account based on the selected public key. To create an address with a new public key, use Manage seeds & accounts.',
      );

  Widget field() => CustomTextFormField(
        name: 'name',
        controller: controller,
        autocorrect: false,
        enableSuggestions: false,
        hintText: 'Name...',
        suffixIcon: TextFieldClearButton(
          controller: controller,
        ),
      );

  Widget submitButton() => CustomElevatedButton(
        onPressed: onPressed,
        text: 'Next',
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
