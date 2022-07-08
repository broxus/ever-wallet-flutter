import 'package:ever_wallet/application/common/widgets/crystal_text_form_field.dart';
import 'package:ever_wallet/application/common/widgets/custom_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';

class NameNewKeyModalBody extends StatefulWidget {
  const NameNewKeyModalBody({
    Key? key,
  }) : super(key: key);

  static String title(BuildContext context) => AppLocalizations.of(context)!.name_new_key;

  @override
  NameNewKeyModalBodyState createState() => NameNewKeyModalBodyState();
}

class NameNewKeyModalBodyState extends State<NameNewKeyModalBody> {
  final nameController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        minimum: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(24),
            CrystalTextFormField(
              controller: nameController,
              autofocus: true,
              hintText: AppLocalizations.of(context)!.name,
            ),
            const Gap(24),
            CustomElevatedButton(
              onPressed: () {
                Navigator.of(context).pop<String>(nameController.text);
              },
              text: AppLocalizations.of(context)!.submit,
            ),
          ],
        ),
      );
}
