import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../injection.dart';
import '../../../../../data/repositories/accounts_repository.dart';
import '../../../../design/widgets/crystal_title.dart';
import '../../../../design/widgets/custom_back_button.dart';
import '../../../../design/widgets/custom_elevated_button.dart';
import '../../../../design/widgets/custom_text_form_field.dart';
import '../../../../design/widgets/text_field_clear_button.dart';
import '../../../../design/widgets/unfocusing_gesture_detector.dart';
import '../../../router.gr.dart';

class NewAccountNamePage extends StatefulWidget {
  final String publicKey;
  final WalletType walletType;

  const NewAccountNamePage({
    Key? key,
    required this.publicKey,
    required this.walletType,
  }) : super(key: key);

  @override
  State<NewAccountNamePage> createState() => _NewAccountNamePageState();
}

class _NewAccountNamePageState extends State<NewAccountNamePage> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: UnfocusingGestureDetector(
          child: Scaffold(
            appBar: AppBar(
              leading: const CustomBackButton(),
            ),
            body: body(),
          ),
        ),
      );

  Widget body() => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16) - const EdgeInsets.only(top: 16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    title(),
                    const SizedBox(height: 32),
                    field(),
                  ],
                ),
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

  Widget title() => const CrystalTitle(
        text: 'Name new account',
      );

  Widget field() => CustomTextFormField(
        name: 'name',
        controller: controller,
        hintText: 'Enter the name...',
        suffixIcon: TextFieldClearButton(
          controller: controller,
        ),
      );

  Widget submitButton() => CustomElevatedButton(
        onPressed: () async {
          await getIt.get<AccountsRepository>().addAccount(
                name: controller.text.isNotEmpty ? controller.text : widget.walletType.describe(),
                publicKey: widget.publicKey,
                walletType: widget.walletType,
              );

          context.router.navigate(const WalletRouterRoute());
        },
        text: 'Submit',
      );
}
