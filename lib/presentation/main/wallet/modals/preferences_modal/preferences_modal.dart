import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../../../data/repositories/accounts_repository.dart';
import '../../../../../../injection.dart';
import '../../../../../../logger.dart';
import '../../../../../../providers/account/account_info_provider.dart';
import '../../../../../data/extensions.dart';
import '../../../../../providers/common/network_type_provider.dart';
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
      controller.selection =
          TextSelection.fromPosition(TextPosition(offset: controller.text.length));
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
                  text: AppLocalizations.of(context)!.preferences,
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
                  await getIt.get<AccountsRepository>().renameAccount(
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

  Widget explorerButton() => Consumer(
        builder: (context, ref, child) {
          final accountExplorerLink = ref.watch(networkTypeProvider).asData?.value == 'Ever'
              ? everAccountExplorerLink
              : venomAccountExplorerLink;

          return CustomOutlinedButton(
            onPressed: () => launchUrlString(accountExplorerLink(widget.address)),
            text: AppLocalizations.of(context)!.see_in_the_explorer,
          );
        },
      );
}
