import 'dart:async';

import 'package:ever_wallet/application/common/extensions.dart';
import 'package:ever_wallet/application/common/general/button/menu_dropdown.dart';
import 'package:ever_wallet/application/common/general/button/primary_elevated_button.dart';
import 'package:ever_wallet/application/common/general/button/push_state_ink_widget.dart';
import 'package:ever_wallet/application/common/general/default_appbar.dart';
import 'package:ever_wallet/application/common/general/default_divider.dart';
import 'package:ever_wallet/application/common/general/default_list_tile.dart';
import 'package:ever_wallet/application/common/general/ew_bottom_sheet.dart';
import 'package:ever_wallet/application/common/general/flushbar.dart';
import 'package:ever_wallet/application/main/common/password_input_modal_body.dart';
import 'package:ever_wallet/application/main/profile/manage_seed/manage_seed_actions/change_seed_phrase_password_modal_body.dart';
import 'package:ever_wallet/application/main/profile/manage_seed/manage_seed_actions/export_seed_phrase_modal_body.dart';
import 'package:ever_wallet/application/main/profile/manage_seed/manage_seed_actions/rename_key_modal_body.dart';
import 'package:ever_wallet/application/main/profile/manage_seed/manage_seed_actions/seed_phrase_export_sheet.dart';
import 'package:ever_wallet/application/main/profile/manage_seed/manage_seed_actions/select_derive_keys/select_derive_keys_sheet.dart';
import 'package:ever_wallet/application/main/profile/manage_seed/manage_seed_actions/show_key_delete_sheet.dart';
import 'package:ever_wallet/application/main/profile/manage_seed/manage_seed_actions/show_seed_delete_sheet.dart';
import 'package:ever_wallet/application/main/profile/manage_seed/public_key_detailed_screen.dart';
import 'package:ever_wallet/application/main/profile/widgets/keys_builder.dart';
import 'package:ever_wallet/application/util/auth_utils.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/application/util/theme_styles.dart';
import 'package:ever_wallet/data/repositories/accounts_repository.dart';
import 'package:ever_wallet/data/repositories/biometry_repository.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:ever_wallet/generated/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

class SeedDetailScreenRoute extends MaterialPageRoute<void> {
  SeedDetailScreenRoute({required KeyStoreEntry seed})
      : super(builder: (_) => SeedDetailScreen(seed: seed));
}

class SeedDetailScreen extends StatefulWidget {
  const SeedDetailScreen({
    required this.seed,
    super.key,
  });

  final KeyStoreEntry seed;

  @override
  State<SeedDetailScreen> createState() => _SeedDetailScreenState();
}

class _SeedDetailScreenState extends State<SeedDetailScreen> {
  KeyStoreEntry get seed => widget.seed;

  @override
  Widget build(BuildContext context) {
    final localization = context.localization;
    final themeStyle = context.themeStyle;

    return Scaffold(
      appBar: DefaultAppBar(
        backText: localization.seeds_and_subscriptions,
      ),
      body: KeysBuilderWidget(
        builder: (keys, currentKey) {
          final isSelected = seed.publicKey == currentKey?.publicKey;
          final children = keys[seed];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EWListTile(
                height: 87,
                leading: Assets.images.seed.svg(width: 32, height: 32),
                subtitleWidget: !isSelected
                    ? null
                    : Text(
                        localization.current_seed.toUpperCase(),
                        style: themeStyle.styles.sectionCaption,
                      ),
                titleWidget: Text(
                  localization.seed_phrase_with_name(seed.name),
                  maxLines: 2,
                  style: themeStyle.styles.header3Style,
                ),
                trailing: _seedDropdown(
                  themeStyle,
                  localization,
                  seed,
                  children,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  localization.keys_word,
                  style: themeStyle.styles.sectionCaption,
                ),
              ),
              const DefaultDivider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ...?children?.map((e) => _keyItem(themeStyle, localization, e)).toList(),
                      PushStateInkWidget(
                        onPressed: () => _deriveKey(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          height: 46,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            localization.plus_add_key,
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
              if (!isSelected)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: PrimaryElevatedButton(
                    text: localization.use_this_seed,
                    onPressed: () => context.read<KeysRepository>().setCurrentKey(seed.publicKey),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _seedDropdown(
    ThemeStyle themeStyle,
    AppLocalizations localization,
    KeyStoreEntry seed,
    List<KeyStoreEntry>? children,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: ColorsRes.darkBlue.withOpacity(0.2)),
      ),
      child: MenuDropdown(
        buttonDecoration: const BoxDecoration(),
        items: [
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
            title: localization.change_password,
            onTap: () => showEWBottomSheet<void>(
              context,
              title: localization.change_seed_password,
              body: (_) => ChangeSeedPhrasePasswordModalBody(publicKey: seed.publicKey),
            ),
          ),
          MenuDropdownData(
            title: localization.delete_word,
            onTap: () => showSeedDeleteSheet(
              context: context,
              seed: seed,
              children: children,
            ),
            textStyle: themeStyle.styles.basicStyle.copyWith(
              color: themeStyle.colors.errorTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _keyItem(
    ThemeStyle themeStyle,
    AppLocalizations localization,
    KeyStoreEntry key,
  ) {
    final accounts = context.read<AccountsRepository>().accountsFor(key.publicKey);
    return EWListTile(
      onPressed: () => Navigator.of(context).push(KeyDetailScreenRoute(keyEntry: key)),
      leading: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: const BoxDecoration(color: ColorsRes.darkBlue, shape: BoxShape.circle),
        child: Assets.images.key.svg(width: 18, height: 18),
      ),
      titleText: key.name,
      subtitleText: localization.key_name_with_sub_count(
        key.publicKey.ellipsePublicKey(),
        accounts.length,
      ),
      trailing: _keyDropdown(themeStyle, localization, key),
    );
  }

  Widget _keyDropdown(
    ThemeStyle themeStyle,
    AppLocalizations localization,
    KeyStoreEntry seed,
  ) {
    return MenuDropdown(
      items: [
        MenuDropdownData(
          title: localization.hide_word,
          onTap: () {},
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
          title: localization.copy_key,
          onTap: () async {
            await Clipboard.setData(ClipboardData(text: seed.publicKey));
            if (!mounted) return;
            showFlushbar(
              context,
              message: context.localization.public_key_copied(seed.publicKey.ellipsePublicKey()),
            );
          },
        ),
        MenuDropdownData(
          title: localization.delete_word,
          onTap: () {
            final accounts = context.read<AccountsRepository>().accountsFor(seed.publicKey);
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
    );
  }

  Future<void> _deriveKey(BuildContext context) async {
    final localization = context.localization;
    final biometryRepo = context.read<BiometryRepository>();

    final isEnabled = biometryRepo.status;
    final isAvailable = biometryRepo.availability;

    if (isAvailable && isEnabled) {
      try {
        final password = await biometryRepo.getKeyPassword(
          localizedReason: localization.authentication_reason,
          publicKey: seed.publicKey,
        );

        await showSelectDeriveKeysSheet(context: context, password: password, seed: seed);
      } catch (err) {
        if (!mounted) return;

        showEWBottomSheet<void>(
          context,
          title: localization.derive_enter_password,
          body: (c) => PasswordInputModalBody(
            publicKey: seed.publicKey,
            onSubmit: (password) {
              Navigator.of(c).pop();
              showSelectDeriveKeysSheet(
                context: context,
                password: password,
                seed: seed,
              );
            },
          ),
        );
      }
    } else {
      if (!mounted) return;

      showEWBottomSheet<void>(
        context,
        title: localization.derive_enter_password,
        body: (c) => PasswordInputModalBody(
          publicKey: seed.publicKey,
          onSubmit: (password) {
            Navigator.of(c).pop();
            showSelectDeriveKeysSheet(
              context: context,
              password: password,
              seed: seed,
            );
          },
        ),
      );
    }
  }
}
