import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/application/common/utils.dart';
import 'package:ever_wallet/application/common/widgets/address_card.dart';
import 'package:ever_wallet/application/common/widgets/crystal_flushbar.dart';
import 'package:ever_wallet/application/common/widgets/custom_outlined_button.dart';
import 'package:ever_wallet/application/common/widgets/custom_text_form_field.dart';
import 'package:ever_wallet/application/common/widgets/modal_header.dart';
import 'package:ever_wallet/application/common/widgets/text_field_clear_button.dart';
import 'package:ever_wallet/application/common/widgets/text_suffix_icon_button.dart';
import 'package:ever_wallet/data/extensions.dart';
import 'package:ever_wallet/data/repositories/accounts_repository.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PreferencesModalBody extends StatefulWidget {
  final String address;
  final String? publicKey;

  const PreferencesModalBody({
    Key? key,
    required this.address,
    this.publicKey,
  }) : super(key: key);

  @override
  State<PreferencesModalBody> createState() => _PreferencesModalBodyState();
}

class _PreferencesModalBodyState extends State<PreferencesModalBody> {
  final controller = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final name = context
        .read<AccountsRepository>()
        .accounts
        .firstWhere((e) => e.address == widget.address)
        .name;
    controller.text = name;
    controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
  }

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ModalHeader(
                  text: AppLocalizations.of(context)!.preferences,
                ),
                const Gap(16),
                field(),
                const Gap(16),
                card(),
                const Gap(16),
                explorerButton(),
              ],
            ),
          ),
        ),
      );

  Widget card() => AddressCard(address: widget.address);

  Widget field() => CustomTextFormField(
        name: AppLocalizations.of(context)!.name,
        controller: controller,
        autocorrect: false,
        enableSuggestions: false,
        hintText: '${AppLocalizations.of(context)!.name}...',
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFieldClearButton(
              controller: controller,
            ),
            SuffixIconButton(
              onPressed: () async {
                try {
                  await context.read<AccountsRepository>().renameAccount(
                        address: widget.address,
                        name: controller.text,
                      );

                  if (!mounted) return;

                  showCrystalFlushbar(
                    context,
                    message: AppLocalizations.of(context)!.wallet_renamed,
                  );
                } catch (err, st) {
                  logger.e(err, err, st);

                  if (!mounted) return;

                  showErrorCrystalFlushbar(
                    context,
                    message: (err as Exception).toUiMessage(),
                  );
                }
              },
              icon: const Icon(
                Icons.save,
                color: CrystalColor.accent,
              ),
            ),
          ],
        ),
      );

  Widget explorerButton() => CustomOutlinedButton(
        onPressed: () => launchUrlString(accountExplorerLink(widget.address)),
        text: AppLocalizations.of(context)!.see_in_the_explorer,
      );
}
