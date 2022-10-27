import 'package:ever_wallet/application/common/general/button/primary_elevated_button.dart';
import 'package:ever_wallet/application/common/widgets/modal_header.dart';
import 'package:ever_wallet/application/common/widgets/selectable_button.dart';
import 'package:ever_wallet/application/main/wallet/modals/add_account_flow/add_existing_account_page.dart';
import 'package:ever_wallet/application/main/wallet/modals/add_account_flow/add_new_account_name_page.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/generated/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class AddAccountPage extends StatefulWidget {
  final BuildContext modalContext;
  final String publicKey;

  const AddAccountPage({
    super.key,
    required this.modalContext,
    required this.publicKey,
  });

  @override
  _AddAccountPageState createState() => _AddAccountPageState();
}

class _AddAccountPageState extends State<AddAccountPage> {
  final optionNotifier = ValueNotifier<_Options>(_Options.createNew);

  @override
  void dispose() {
    optionNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ModalHeader(
                  text: context.localization.add_account,
                  onCloseButtonPressed: Navigator.of(widget.modalContext).pop,
                ),
                const Gap(16),
                Expanded(child: selector()),
                const Gap(16),
                submitButton(),
              ],
            ),
          ),
        ),
      );

  Widget selector() => ValueListenableBuilder<_Options>(
        valueListenable: optionNotifier,
        builder: (context, value, child) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SelectableButton(
                icon: Assets.images.iconCreate,
                text: _Options.createNew.describe(context),
                onPressed: () => optionNotifier.value = _Options.createNew,
                isSelected: value == _Options.createNew,
              ),
            ),
            const Gap(16),
            Expanded(
              child: SelectableButton(
                icon: Assets.images.iconAdd,
                text: _Options.addExisting.describe(context),
                onPressed: () => optionNotifier.value = _Options.addExisting,
                isSelected: value == _Options.addExisting,
              ),
            ),
          ],
        ),
      );

  Widget submitButton() => ValueListenableBuilder<_Options>(
        valueListenable: optionNotifier,
        builder: (context, value, child) => PrimaryElevatedButton(
          onPressed: () => onPressed(value),
          text: context.localization.next,
        ),
      );

  void onPressed(_Options value) {
    late Widget page;

    switch (value) {
      case _Options.createNew:
        page = AddNewAccountNamePage(
          modalContext: widget.modalContext,
          publicKey: widget.publicKey,
        );
        break;
      case _Options.addExisting:
        page = AddExistingAccountPage(
          modalContext: widget.modalContext,
          publicKey: widget.publicKey,
        );
        break;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => page,
      ),
    );
  }
}

enum _Options {
  createNew,
  addExisting,
}

extension on _Options {
  String describe(BuildContext context) {
    switch (this) {
      case _Options.createNew:
        return context.localization.create_new_account;
      case _Options.addExisting:
        return context.localization.add_existing_account;
    }
  }
}
