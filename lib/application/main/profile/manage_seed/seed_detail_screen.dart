import 'dart:async';

import 'package:ever_wallet/application/common/extensions.dart';
import 'package:ever_wallet/application/common/general/button/menu_dropdown.dart';
import 'package:ever_wallet/application/common/general/button/primary_elevated_button.dart';
import 'package:ever_wallet/application/common/general/button/text_button.dart';
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
import 'package:flutter/cupertino.dart';
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
  @override
  Widget build(BuildContext context) {
    final localization = context.localization;
    final themeStyle = context.themeStyle;

    return Scaffold(
      appBar: DefaultAppBar(
        backText: localization.seeds_and_accounts,
      ),
      body: KeysBuilderWidget(
        builder: (keys, currentKey) {
          final seed = context
              .read<KeysRepository>()
              .keys
              .firstWhere((k) => k.publicKey == widget.seed.publicKey);
          final isSeedSelected = seed.publicKey == currentKey?.masterKey;
          final children = keys[seed];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StreamBuilder<Map<String, String>>(
                initialData: context.read<KeysRepository>().seeds,
                stream: context.read<KeysRepository>().seedsStream,
                builder: (context, labels) {
                  final label = labels.data?[seed.publicKey];

                  return EWListTile(
                    height: 87,
                    leading: Assets.images.seed.svg(width: 32, height: 32),
                    subtitleWidget: !isSeedSelected
                        ? null
                        : Text(
                            localization.current_seed.toUpperCase(),
                            style: themeStyle.styles.sectionCaption,
                          ),
                    titleWidget: Text(
                      label ?? seed.publicKey.ellipsePublicKey(),
                      maxLines: 2,
                      style: themeStyle.styles.header3Style,
                    ),
                    trailing: _seedDropdown(
                      themeStyle,
                      localization,
                      seed,
                      children,
                      isSeedSelected,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        localization.keys_word,
                        style: themeStyle.styles.sectionCaption,
                      ),
                    ),
                    if (!seed.isLegacy)
                      TextPrimaryButton.appBar(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        text: localization.plus_add_key,
                        style: themeStyle.styles.basicStyle.copyWith(
                          color: ColorsRes.darkBlue,
                          fontWeight: FontWeight.w500,
                        ),
                        onPressed: () => _deriveKey(
                          context,
                          seed,
                        ),
                      ),
                  ],
                ),
              ),
              const DefaultDivider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ...[seed, ...?children]
                          .map(
                            (e) => _keyItem(
                              themeStyle,
                              localization,
                              e,
                              [seed, ...?children],
                              isSeedSelected,
                            ),
                          )
                          .toList(),
                    ],
                  ),
                ),
              ),
              if (!isSeedSelected)
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
    bool isSelected,
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
                body: (_) => RenameKeyModalBody(
                  publicKey: seed.publicKey,
                  type: RenameModalBodyType.seed,
                ),
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
          if (!isSelected)
            MenuDropdownData(
              title: localization.delete_word,
              onTap: () => showSeedDeleteSheet(
                context: context,
                seed: seed,
                children: children,
              ).then((deleted) {
                if (deleted ?? false) {
                  Navigator.of(context).pop();
                }
              }),
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
    List<KeyStoreEntry>? children,
    bool isSeedSelected,
  ) {
    return StreamBuilder<Map<String, String>>(
      initialData: context.read<KeysRepository>().keyLabels,
      stream: context.read<KeysRepository>().keyLabelsStream,
      builder: (context, labels) {
        final label = labels.data?[key.publicKey];

        return StreamBuilder<List<AssetsList>>(
          stream: context.read<AccountsRepository>().accountsForStream(key.publicKey),
          builder: (context, accounts) {
            return StreamBuilder<String?>(
              initialData: context.read<KeysRepository>().currentKey,
              stream: context.read<KeysRepository>().currentKeyStream,
              builder: (context, snap) {
                final currentKey = snap.data;
                final isSelected = currentKey == key.publicKey;

                return EWListTile(
                  onPressed: () => Navigator.of(context).push(KeyDetailScreenRoute(keyEntry: key)),
                  leading: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration:
                        const BoxDecoration(color: ColorsRes.darkBlue, shape: BoxShape.circle),
                    child: Assets.images.key.svg(width: 18, height: 18),
                  ),
                  titleText: label ?? key.name,
                  subtitleText: localization.key_name_with_sub_count(
                    key.publicKey.ellipsePublicKey(),
                    accounts.data?.length ?? 0,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected)
                        Icon(
                          CupertinoIcons.checkmark_alt,
                          color: themeStyle.colors.primaryButtonTextColor,
                          size: 20,
                        ),
                      _keyDropdown(
                        themeStyle,
                        localization,
                        key,
                        children,
                        !(key.isMaster && isSeedSelected),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _keyDropdown(
    ThemeStyle themeStyle,
    AppLocalizations localization,
    KeyStoreEntry key,
    List<KeyStoreEntry>? children,
    bool allowDeleting,
  ) {
    return MenuDropdown(
      items: [
        MenuDropdownData(
          title: localization.use_this_key,
          onTap: () => context.read<KeysRepository>().setCurrentKey(key.publicKey),
        ),
        MenuDropdownData(
          title: localization.rename,
          onTap: () {
            showEWBottomSheet<void>(
              context,
              title: localization.enter_new_name,
              body: (_) => RenameKeyModalBody(
                publicKey: key.publicKey,
                type: RenameModalBodyType.key,
              ),
            );
          },
        ),
        MenuDropdownData(
          title: localization.copy_key,
          onTap: () async {
            await Clipboard.setData(ClipboardData(text: key.publicKey));
            if (!mounted) return;
            showFlushbar(
              context,
              message: context.localization.public_key_copied(key.publicKey.ellipsePublicKey()),
            );
          },
        ),
        if (allowDeleting)
          MenuDropdownData(
            title: localization.delete_word,
            onTap: () {
              final accounts = context.read<AccountsRepository>().accountsFor(key.publicKey);
              showKeyDeleteSheet(
                context: context,
                key: key,
                assets: accounts,
              ).then((value) {
                if ((value ?? false) && children?.length == 1 ||
                    key.publicKey == widget.seed.publicKey) {
                  Navigator.of(context).pop();
                }
              });
            },
            textStyle: themeStyle.styles.basicStyle.copyWith(
              color: themeStyle.colors.errorTextColor,
            ),
          ),
      ],
    );
  }

  Future<void> _deriveKey(BuildContext context, KeyStoreEntry seed) async {
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
