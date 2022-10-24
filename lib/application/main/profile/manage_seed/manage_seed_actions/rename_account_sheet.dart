import 'package:ever_wallet/application/common/general/button/primary_elevated_button.dart';
import 'package:ever_wallet/application/common/general/ew_bottom_sheet.dart';
import 'package:ever_wallet/application/common/general/field/bordered_input.dart';
import 'package:ever_wallet/application/common/general/flushbar.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/data/extensions.dart';
import 'package:ever_wallet/data/repositories/accounts_repository.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> showRenameAccountSheet({
  required BuildContext context,
  required String address,
}) {
  return showEWBottomSheet<void>(
    context,
    title: context.localization.rename_account,
    body: (_) => RenameAccountSheet(address: address),
  );
}

class RenameAccountSheet extends StatefulWidget {
  final String address;

  const RenameAccountSheet({
    super.key,
    required this.address,
  });

  @override
  _RenameAccountSheetState createState() => _RenameAccountSheetState();
}

class _RenameAccountSheetState extends State<RenameAccountSheet> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          BorderedInput(
            controller: controller,
            autofocus: true,
            formatters: [LengthLimitingTextInputFormatter(50)],
            label: localization.name,
            textStyle: themeStyle.styles.basicStyle.copyWith(color: ColorsRes.text),
            cursorColor: ColorsRes.text,
          ),
          const SizedBox(height: 24),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, value, __) => PrimaryElevatedButton(
              onPressed: value.text.isEmpty
                  ? null
                  : () async {
                      try {
                        Navigator.of(context).pop();

                        await context
                            .read<AccountsRepository>()
                            .renameAccount(address: widget.address, name: value.text.trim());

                        if (!mounted) return;

                        await showFlushbar(
                          context,
                          message: localization.account_renamed,
                        );
                      } catch (err, st) {
                        logger.e(err, err, st);

                        if (!mounted) return;

                        await showErrorFlushbar(
                          context,
                          message: (err as Exception).toUiMessage(),
                        );
                      }
                    },
              text: localization.rename,
            ),
          )
        ],
      ),
    );
  }
}
