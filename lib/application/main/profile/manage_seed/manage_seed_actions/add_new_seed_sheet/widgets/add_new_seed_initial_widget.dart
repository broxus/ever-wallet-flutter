import 'package:ever_wallet/application/common/general/button/ew_dropdown_button.dart';
import 'package:ever_wallet/application/common/general/button/primary_elevated_button.dart';
import 'package:ever_wallet/application/common/general/button/primary_icon_button.dart';
import 'package:ever_wallet/application/common/general/field/bordered_input.dart';
import 'package:ever_wallet/application/main/profile/manage_seed/manage_seed_actions/add_new_seed_sheet/add_new_seed_bloc.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

typedef AddNewSeedInitialAction = void Function(String? name, AddNewSeedType type);

class AddNewSeedInitialWidget extends StatefulWidget {
  const AddNewSeedInitialWidget({
    required this.action,
    required this.savedName,
    required this.savedType,
    super.key,
  });

  final String? savedName;
  final AddNewSeedType? savedType;
  final AddNewSeedInitialAction action;

  @override
  State<AddNewSeedInitialWidget> createState() => _AddNewSeedInitialWidgetState();
}

class _AddNewSeedInitialWidgetState extends State<AddNewSeedInitialWidget> {
  late final optionNotifier = ValueNotifier(widget.savedType ?? AddNewSeedType.create);
  late final nameController = TextEditingController(text: widget.savedName ?? '');

  @override
  void dispose() {
    nameController.dispose();
    optionNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeStyle = context.themeStyle;
    final localization = context.localization;

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
                localization.add_seed_phrase,
                style: themeStyle.styles.sheetHeaderStyle,
              ),
            ),
            const SizedBox(height: 32),
            BorderedInput(
              controller: nameController,
              label: localization.seed_name,
              cursorColor: ColorsRes.text,
              textStyle: themeStyle.styles.basicStyle.copyWith(color: ColorsRes.text),
              textInputAction: TextInputAction.done,
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
                final trimmed = nameController.text.trim();
                widget.action(trimmed.isEmpty ? null : trimmed, optionNotifier.value);
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
        return context.localization.import_seed;
      case AddNewSeedType.importLegacy:
        return context.localization.import_legacy_seed;
    }
  }
}
