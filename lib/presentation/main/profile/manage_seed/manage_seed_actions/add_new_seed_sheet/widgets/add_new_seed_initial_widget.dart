import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import '../../../../../../common/general/button/ew_dropdown_button.dart';
import '../../../../../../common/general/button/primary_elevated_button.dart';
import '../../../../../../common/general/button/primary_icon_button.dart';
import '../../../../../../common/general/field/bordered_input.dart';
import '../../../../../../util/colors.dart';
import '../../../../../../util/extensions/context_extensions.dart';
import '../add_new_seed_bloc.dart';

typedef AddNewSeedInitialAction = void Function(String name, AddNewSeedType type);

class AddNewSeedInitialWidget extends StatefulWidget {
  const AddNewSeedInitialWidget({
    required this.action,
    required this.savedName,
    required this.savedType,
    Key? key,
  }) : super(key: key);

  final String? savedName;
  final AddNewSeedType? savedType;
  final AddNewSeedInitialAction action;

  @override
  State<AddNewSeedInitialWidget> createState() => _AddNewSeedInitialWidgetState();
}

class _AddNewSeedInitialWidgetState extends State<AddNewSeedInitialWidget> {
  late final optionNotifier = ValueNotifier(widget.savedType ?? AddNewSeedType.create);
  late final nameController = TextEditingController(text: widget.savedName ?? '');
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    optionNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeStyle = context.themeStyle;

    return Stack(
      children: [
        Positioned(
          right: 0,
          top: 0,
          child: PrimaryIconButton(
            onPressed: () => Navigator.of(context).pop(),
            outerPadding: EdgeInsets.zero,
            icon: const Icon(Icons.close, color: ColorsRes.grey, size: 20),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                // TODO: replace text
                'Add seed phrase',
                style: themeStyle.styles.sheetHeaderStyle,
              ),
            ),
            const SizedBox(height: 32),
            Form(
              key: formKey,
              child: BorderedInput(
                controller: nameController,
                validator: (_) => nameController.text.trim().isEmpty ? '' : null,
                // TODO: replace text
                label: 'Seed name',
                cursorColor: ColorsRes.text,
                textStyle: themeStyle.styles.basicStyle.copyWith(color: ColorsRes.text),
                textInputAction: TextInputAction.done,
              ),
            ),
            ValueListenableBuilder<AddNewSeedType>(
              valueListenable: optionNotifier,
              builder: (context, value, child) => EWDropdownButton<AddNewSeedType>(
                items: AddNewSeedType.values.map((e) => Tuple2(e, e.describe(context))).toList(),
                value: value,
                onChanged: (value) {
                  if (value != null) {
                    optionNotifier.value = value;
                  }
                },
              ),
            ),
            const SizedBox(height: 170),
            PrimaryElevatedButton(
              text: context.localization.next,
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  widget.action(nameController.text.trim(), optionNotifier.value);
                }
              },
            )
          ],
        ),
      ],
    );
  }
}

extension AddNewSeedTypeX on AddNewSeedType {
  String describe(BuildContext context) {
    switch (this) {
      case AddNewSeedType.create:
        return context.localization.create_seed;
      case AddNewSeedType.import:
        // TODO: replace text
        return 'Import seed';
    }
  }
}
