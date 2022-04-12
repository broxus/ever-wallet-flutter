import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../generated/codegen_loader.g.dart';
import '../../common/widgets/crystal_text_form_field.dart';
import '../../common/widgets/custom_elevated_button.dart';

class NameNewKeyModalBody extends StatefulWidget {
  const NameNewKeyModalBody({
    Key? key,
  }) : super(key: key);

  static String get title => LocaleKeys.name_new_key.tr();

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
              hintText: LocaleKeys.name.tr(),
            ),
            const SizedBox(height: 24),
            CustomElevatedButton(
              onPressed: () {
                context.router.pop<String>(nameController.text);
              },
              text: LocaleKeys.submit.tr(),
            ),
          ],
        ),
      );
}
