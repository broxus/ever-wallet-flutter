import 'package:flutter/material.dart';

import '../../../design/design.dart';

class NameNewKeyModalBody extends StatefulWidget {
  const NameNewKeyModalBody({
    Key? key,
  }) : super(key: key);

  static String get title => 'Name new key';

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
            const CrystalDivider(height: 24),
            CrystalTextFormField(
              controller: nameController,
              autofocus: true,
              hintText: 'Name',
            ),
            const CrystalDivider(height: 24),
            CrystalButton(
              text: 'Submit',
              onTap: () {
                context.router.pop<String>(nameController.text);
              },
            ),
          ],
        ),
      );
}
