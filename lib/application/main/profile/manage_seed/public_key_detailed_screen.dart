import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/async_value_stream_provider.dart';
import 'package:ever_wallet/application/common/extensions.dart';
import 'package:ever_wallet/application/common/general/button/menu_dropdown.dart';
import 'package:ever_wallet/application/common/general/button/push_state_ink_widget.dart';
import 'package:ever_wallet/application/common/general/button/push_state_scale_widget.dart';
import 'package:ever_wallet/application/common/general/default_appbar.dart';
import 'package:ever_wallet/application/common/general/default_divider.dart';
import 'package:ever_wallet/application/common/general/default_list_tile.dart';
import 'package:ever_wallet/application/common/general/ew_bottom_sheet.dart';
import 'package:ever_wallet/application/common/general/flushbar.dart';
import 'package:ever_wallet/application/main/profile/manage_seed/account_detail_screen.dart';
import 'package:ever_wallet/application/main/profile/manage_seed/manage_seed_actions/export_seed_phrase_modal_body.dart';
import 'package:ever_wallet/application/main/profile/manage_seed/manage_seed_actions/rename_account_sheet.dart';
import 'package:ever_wallet/application/main/profile/manage_seed/manage_seed_actions/rename_key_modal_body.dart';
import 'package:ever_wallet/application/main/profile/manage_seed/manage_seed_actions/seed_phrase_export_sheet.dart';
import 'package:ever_wallet/application/main/profile/manage_seed/manage_seed_actions/show_account_delete_sheet.dart';
import 'package:ever_wallet/application/main/profile/manage_seed/manage_seed_actions/show_key_delete_sheet.dart';
import 'package:ever_wallet/application/main/wallet/modals/add_account_flow/start_add_account_flow.dart';
import 'package:ever_wallet/application/util/auth_utils.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/application/util/styles.dart';
import 'package:ever_wallet/application/util/theme_styles.dart';
import 'package:ever_wallet/data/repositories/accounts_repository.dart';
import 'package:ever_wallet/generated/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

class KeyDetailScreenRoute extends MaterialPageRoute<void> {
  KeyDetailScreenRoute({required KeyStoreEntry keyEntry})
      : super(builder: (_) => KeyDetailScreen(keyEntry: keyEntry));
}

class KeyDetailScreen extends StatefulWidget {
  const KeyDetailScreen({
    required this.keyEntry,
    super.key,
  });

  final KeyStoreEntry keyEntry;

  @override
  State<KeyDetailScreen> createState() => _KeyDetailScreenState();
}

class _KeyDetailScreenState extends State<KeyDetailScreen> {
  KeyStoreEntry get key => widget.keyEntry;

  @override
  Widget build(BuildContext context) {
    final localization = context.localization;
    final themeStyle = context.themeStyle;

    return Scaffold(
      appBar: DefaultAppBar(
        backText: localization.seed_word,
      ),
      body: AsyncValueStreamProvider(
        create: (context) => context.read<AccountsRepository>().accountsForStream(key.publicKey),
        builder: (context, child) {
          /// TODO: decide if there external accounts or only local
          final allAccounts = context.watch<AsyncValue<List<AssetsList>>>().maybeWhen(
                ready: (value) => value,
                orElse: () => <AssetsList>[],
              );
          final externalAccountsAddresses =
              context.read<AccountsRepository>().externalAccounts[key.publicKey] ?? [];
          final accounts = <AssetsList>[];
          final externalAccounts = <AssetsList>[];

          allAccounts.forEach((a) {
            if (externalAccountsAddresses.contains(a.address)) {
              externalAccounts.add(a);
            } else {
              accounts.add(a);
            }
          });

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EWListTile(
                height: 87,
                leading: Container(
                  height: 32,
                  width: 32,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: ColorsRes.darkBlue,
                  ),
                  child: Assets.images.key.svg(width: 18, height: 18),
                ),
                subtitleWidget: Text(
                  localization.public_key.toUpperCase(),
                  style: themeStyle.styles.sectionCaption,
                ),
                titleWidget: Text(
                  key.name,
                  maxLines: 2,
                  style: themeStyle.styles.header3Style,
                ),
                trailing: _keyDropdown(
                  themeStyle,
                  localization,
                  key,
                  allAccounts,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                child: Text(
                  localization.public_key,
                  style: StylesRes.medium14Caption.copyWith(color: ColorsRes.grey4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PushStateScaleWidget(
                  onLongPress: () {
                    Clipboard.setData(ClipboardData(text: key.publicKey));
                    showFlushbar(
                      context,
                      message: localization.public_key_copied(key.publicKey.ellipsePublicKey()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ColorsRes.notWhite,
                      border: Border.all(color: ColorsRes.grey2),
                    ),
                    child: Text(
                      key.publicKey,
                      style: StylesRes.regular16.copyWith(color: ColorsRes.black),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          localization.accounts_word,
                          style: StylesRes.bold18Body.copyWith(color: ColorsRes.black),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          localization.my_accounts,
                          style: StylesRes.medium14Caption.copyWith(color: ColorsRes.grey4),
                        ),
                      ),
                      const DefaultDivider(),
                      ...accounts.map((e) => _accountItem(themeStyle, localization, e)).toList(),
                      PushStateInkWidget(
                        onPressed: () => startAddLocalAccountFlow(
                          context: context,
                          publicKey: key.publicKey,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          height: 46,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            localization.plus_add_account,
                            style: themeStyle.styles.basicStyle.copyWith(
                              color: ColorsRes.darkBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          localization.external_accounts,
                          style: StylesRes.medium14Caption.copyWith(color: ColorsRes.grey4),
                        ),
                      ),
                      const DefaultDivider(),
                      ...externalAccounts
                          .map((e) => _accountItem(themeStyle, localization, e, isExternal: true))
                          .toList(),
                      PushStateInkWidget(
                        onPressed: () => startAddExternalAccountFlow(
                          context: context,
                          publicKey: key.publicKey,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          height: 46,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            localization.plus_add_account,
                            style: themeStyle.styles.basicStyle.copyWith(
                              color: ColorsRes.darkBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _accountDropDown(
    ThemeStyle themeStyle,
    AppLocalizations localization,
    AssetsList asset, {
    bool isExternal = false,
  }) {
    return StreamBuilder<bool>(
      stream: context.read<AccountsRepository>().hiddenAccountByAddress(asset.address),
      builder: (context, snapshot) {
        final isHidden = snapshot.data ?? false;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isHidden)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Assets.images.closeEye.svg(),
              ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: ColorsRes.darkBlue.withOpacity(0.2)),
              ),
              child: MenuDropdown(
                buttonDecoration: const BoxDecoration(),
                items: [
                  MenuDropdownData(
                    title: isHidden ? localization.show_word : localization.hide_word,
                    onTap: () =>
                        context.read<AccountsRepository>().toggleHiddenAccount(asset.address),
                  ),
                  MenuDropdownData(
                    title: localization.rename,
                    onTap: () => showRenameAccountSheet(context: context, address: asset.address),
                  ),
                  MenuDropdownData(
                    title: localization.delete_word,
                    onTap: () => showAccountDeleteSheet(
                      context: context,
                      account: asset,
                      isExternal: isExternal,
                      linkedPublicKey: key.publicKey,
                    ),
                    textStyle: themeStyle.styles.basicStyle.copyWith(
                      color: themeStyle.colors.errorTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _accountItem(
    ThemeStyle themeStyle,
    AppLocalizations localization,
    AssetsList asset, {
    bool isExternal = false,
  }) {
    return EWListTile(
      onPressed: () => Navigator.of(context).push(
        AccountDetailRoute(asset, isExternal, key.publicKey),
      ),
      leading: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: Assets.images.account.svg(width: 32, height: 32),
      ),
      titleText: asset.name,
      subtitleText: asset.address.ellipseAddress(),
      trailing: _accountDropDown(themeStyle, localization, asset, isExternal: isExternal),
    );
  }

  Widget _keyDropdown(
    ThemeStyle themeStyle,
    AppLocalizations localization,
    KeyStoreEntry seed,
    List<AssetsList> accounts,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: ColorsRes.darkBlue.withOpacity(0.2)),
      ),
      child: MenuDropdown(
        items: [
          MenuDropdownData(
            title: localization.export_word,
            onTap: () => AuthUtils.askPasswordBeforeExport(
              context: context,
              seed: seed,
              goExport: (phrase) {
                if (!mounted) return;
                showEWBottomSheet<void>(
                  context,
                  title: context.localization.save_seed_phrase,
                  body: (_) => SeedPhraseExportSheet(phrase: phrase),
                );
              },
              enterPassword: (seed) {
                if (!mounted) return;

                showEWBottomSheet<void>(
                  context,
                  title: context.localization.export_enter_password,
                  body: (_) => ExportSeedPhraseModalBody(publicKey: seed.publicKey),
                );
              },
            ),
          ),
          MenuDropdownData(
            title: localization.rename,
            onTap: () {
              showEWBottomSheet<void>(
                context,
                title: localization.enter_new_name,
                body: (_) => RenameKeyModalBody(publicKey: seed.publicKey),
              );
            },
          ),
          MenuDropdownData(
            title: localization.delete_word,
            onTap: () {
              showKeyDeleteSheet(
                context: context,
                key: seed,
                assets: accounts,
              );
            },
            textStyle: themeStyle.styles.basicStyle.copyWith(
              color: themeStyle.colors.errorTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
