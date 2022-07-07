import 'package:flutter/material.dart';

import '../../common/general/button/primary_elevated_button.dart';
import '../../common/general/field/bordered_input.dart';
import '../../util/colors.dart';
import '../../util/extensions/context_extensions.dart';

class NameNewKeyModalBody extends StatefulWidget {
  const NameNewKeyModalBody({
    Key? key,
  }) : super(key: key);

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
  Widget build(BuildContext context) {
    final localization = context.localization;
    final themeStyle = context.themeStyle;

    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          BorderedInput(
            textStyle: themeStyle.styles.basicStyle.copyWith(color: ColorsRes.text),
            controller: nameController,
            autofocus: true,
            label: localization.name,
          ),
          const SizedBox(height: 24),
          PrimaryElevatedButton(
            onPressed: () => Navigator.of(context).pop(nameController.text),
            text: localization.submit,
          ),
        ],
      ),
    );
  }
}
