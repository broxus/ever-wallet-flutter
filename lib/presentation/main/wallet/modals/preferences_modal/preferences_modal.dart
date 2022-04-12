import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../data/repositories/accounts_repository.dart';
import '../../../../../../injection.dart';
import '../../../../../../logger.dart';
import '../../../../../../providers/account/account_info_provider.dart';
import '../../../../../data/extensions.dart';
import '../../../../../generated/codegen_loader.g.dart';
import '../../../../common/theme.dart';
import '../../../../common/utils.dart';
import '../../../../common/widgets/address_card.dart';
import '../../../../common/widgets/crystal_flushbar.dart';
import '../../../../common/widgets/custom_outlined_button.dart';
import '../../../../common/widgets/custom_text_form_field.dart';
import '../../../../common/widgets/modal_header.dart';
import '../../../../common/widgets/text_field_clear_button.dart';
import '../../../../common/widgets/text_suffix_icon_button.dart';

class PreferencesModalBody extends ConsumerStatefulWidget {
  final String address;
  final String? publicKey;

  const PreferencesModalBody({
    Key? key,
    required this.address,
    this.publicKey,
  }) : super(key: key);

  @override
  ConsumerState<PreferencesModalBody> createState() => _PreferencesModalBodyConsumerState();
}

class _PreferencesModalBodyConsumerState extends ConsumerState<PreferencesModalBody> {
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    ref.read(accountInfoProvider(widget.address).future).then((value) {
      controller.text = value.name;
      controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
    });
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
                  text: LocaleKeys.preferences.tr(),
                ),
                const SizedBox(height: 16),
                field(),
                const SizedBox(height: 16),
                card(),
                const SizedBox(height: 16),
                explorerButton(),
              ],
            ),
          ),
        ),
      );

  Widget card() => AddressCard(address: widget.address);

  Widget field() => CustomTextFormField(
        name: LocaleKeys.name.tr(),
        controller: controller,
        autocorrect: false,
        enableSuggestions: false,
        hintText: '${LocaleKeys.name.tr()}...',
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFieldClearButton(
              controller: controller,
            ),
            SuffixIconButton(
              onPressed: () async {
                try {
                  await getIt.get<AccountsRepository>().renameAccount(
                        address: widget.address,
                        name: controller.text,
                      );

                  if (!mounted) return;

                  showCrystalFlushbar(
                    context,
                    message: LocaleKeys.wallet_renamed.tr(),
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
        onPressed: () => launch(accountExplorerLink(widget.address)),
        text: LocaleKeys.see_in_the_explorer.tr(),
      );
}
