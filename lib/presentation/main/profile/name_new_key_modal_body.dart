import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/widgets/crystal_text_form_field.dart';
import '../../common/widgets/custom_elevated_button.dart';

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
            const SizedBox(height: 24),
            CrystalTextFormField(
              controller: nameController,
              autofocus: true,
              hintText: AppLocalizations.of(context)!.name,
            ),
            const SizedBox(height: 24),
            PrimaryElevatedButton(
              onPressed: () {
                context.router.pop<String>(nameController.text);
              },
              text: AppLocalizations.of(context)!.submit,
            ),
          ],
        ),
      );
}
