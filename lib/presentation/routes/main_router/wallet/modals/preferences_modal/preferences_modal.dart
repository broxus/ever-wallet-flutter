import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../data/repositories/accounts_storage_repository.dart';
import '../../../../../../injection.dart';
import '../../../../../../logger.dart';
import '../../../../../../providers/account/account_info_provider.dart';
import '../../../../../design/design.dart';
import '../../../../../design/explorer.dart';
import '../../../../../design/widgets/address_card.dart';
import '../../../../../design/widgets/crystal_flushbar.dart';
import '../../../../../design/widgets/custom_outlined_button.dart';
import '../../../../../design/widgets/custom_text_form_field.dart';
import '../../../../../design/widgets/modal_header.dart';
import '../../../../../design/widgets/text_field_clear_button.dart';
import '../../../../../design/widgets/text_suffix_icon_button.dart';

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
                const ModalHeader(
                  text: 'Preferences',
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
        name: 'name',
        controller: controller,
        autocorrect: false,
        enableSuggestions: false,
        hintText: 'Name...',
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFieldClearButton(
              controller: controller,
            ),
            SuffixIconButton(
              onPressed: () async {
                try {
                  await getIt.get<AccountsStorageRepository>().renameAccount(
                        address: widget.address,
                        name: controller.text,
                      );

                  if (!mounted) return;

                  showCrystalFlushbar(
                    context,
                    message: LocaleKeys.preferences_modal_message_renamed.tr(),
                  );
                } catch (err, st) {
                  logger.e(err, err, st);

                  if (!mounted) return;

                  showErrorCrystalFlushbar(
                    context,
                    message: err.toString(),
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
        onPressed: () => launch(getAccountExplorerLink(widget.address)),
        text: 'See in the explorer',
      );
}
