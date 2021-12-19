import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../data/repositories/accounts_repository.dart';
import '../../../../../../data/repositories/external_accounts_repository.dart';
import '../../../../../../domain/blocs/account/account_info_bloc.dart';
import '../../../../../../domain/models/account.dart';
import '../../../../../../injection.dart';
import '../../../../../../logger.dart';
import '../../../../../design/design.dart';
import '../../../../../design/explorer.dart';
import '../../../../../design/widgets/address_card.dart';
import '../../../../../design/widgets/crystal_flushbar.dart';
import '../../../../../design/widgets/custom_outlined_button.dart';
import '../../../../../design/widgets/custom_text_form_field.dart';
import '../../../../../design/widgets/modal_header.dart';
import '../../../../../design/widgets/text_field_clear_button.dart';
import '../../../../../design/widgets/text_suffix_icon_button.dart';

class PreferencesModalBody extends StatefulWidget {
  final String address;
  final bool isExternal;
  final String? publicKey;

  const PreferencesModalBody({
    Key? key,
    required this.address,
    this.isExternal = false,
    this.publicKey,
  }) : super(key: key);

  @override
  State<PreferencesModalBody> createState() => _PreferencesModalBodyState();
}

class _PreferencesModalBodyState extends State<PreferencesModalBody> {
  final controller = TextEditingController();
  late final AccountInfoBloc accountInfoBloc;

  @override
  void initState() {
    super.initState();
    accountInfoBloc = getIt.get<AccountInfoBloc>();
    accountInfoBloc.add(
      AccountInfoEvent.load(
        address: widget.address,
        isExternal: widget.isExternal,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant PreferencesModalBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.address != widget.address) {
      if (!widget.isExternal) {
        accountInfoBloc.add(
          AccountInfoEvent.load(
            address: widget.address,
            isExternal: widget.isExternal,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    if (!widget.isExternal) {
      accountInfoBloc.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocListener<AccountInfoBloc, Account?>(
        bloc: accountInfoBloc,
        listener: (context, state) {
          if (state != null) {
            controller.text = state.when(
              internal: (assetsList) => assetsList.name,
              external: (assetsList) => assetsList.name,
            );
            controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
          }
        },
        child: body(),
      );

  Widget body() => Material(
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
                  if (!widget.isExternal) {
                    await getIt.get<AccountsRepository>().renameAccount(
                          address: widget.address,
                          name: controller.text,
                        );
                  } else {
                    await getIt.get<ExternalAccountsRepository>().renameExternalAccount(
                          address: widget.address,
                          name: controller.text,
                        );
                  }

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
