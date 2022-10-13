import 'package:ever_wallet/application/common/general/button/menu_dropdown.dart';
import 'package:ever_wallet/application/common/general/button/push_state_ink_widget.dart';
import 'package:ever_wallet/application/common/general/default_appbar.dart';
import 'package:ever_wallet/application/common/general/default_divider.dart';
import 'package:ever_wallet/application/common/general/default_list_tile.dart';
import 'package:ever_wallet/application/common/general/ew_bottom_sheet.dart';
import 'package:ever_wallet/application/main/profile/manage_seed/manage_seed_actions/add_new_seed_sheet/add_new_seed_sheet.dart';
import 'package:ever_wallet/application/main/profile/manage_seed/manage_seed_actions/change_seed_phrase_password_modal_body.dart';
import 'package:ever_wallet/application/main/profile/manage_seed/manage_seed_actions/export_seed_phrase_modal_body.dart';
import 'package:ever_wallet/application/main/profile/manage_seed/manage_seed_actions/rename_key_modal_body.dart';
import 'package:ever_wallet/application/main/profile/manage_seed/manage_seed_actions/seed_phrase_export_sheet.dart';
import 'package:ever_wallet/application/main/profile/manage_seed/manage_seed_actions/show_key_removement_modal.dart';
import 'package:ever_wallet/application/util/auth_utils.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/application/util/theme_styles.dart';
import 'package:ever_wallet/generated/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

class SeedDetailScreenRoute extends MaterialPageRoute<void> {
  SeedDetailScreenRoute({
    required KeyStoreEntry seed,
    required List<KeyStoreEntry>? children,
    required bool isSelected,
  }) : super(
          builder: (_) => SeedDetailScreen(seed: seed, isSelected: isSelected, children: children),
        );
}

class SeedDetailScreen extends StatefulWidget {
  const SeedDetailScreen({
    required this.seed,
    required this.children,
    required this.isSelected,
    super.key,
  });

  final KeyStoreEntry seed;
  final List<KeyStoreEntry>? children;
  final bool isSelected;

  @override
  State<SeedDetailScreen> createState() => _SeedDetailScreenState();
}

class _SeedDetailScreenState extends State<SeedDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final localization = context.localization;
    final themeStyle = context.themeStyle;

    return Scaffold(
      appBar: const DefaultAppBar(
        // TODO: replace text
        backText: 'Seeds & subscriptions',
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EWListTile(
            height: 87,
            leading: Assets.images.seed.svg(width: 32, height: 32),
            subtitleWidget: !widget.isSelected
                ? null
                : Text(
                    // TODO: replace text
                    'Current seed'.toUpperCase(),
                    style: themeStyle.styles.sectionCaption,
                  ),
            titleWidget: Text(
              // TODO: replace text
              '${widget.seed.name} seed phrase',
              maxLines: 2,
              style: themeStyle.styles.header3Style,
            ),
            trailing: _seedDropdown(themeStyle, localization, widget.seed),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              // TODO: replace text
              'Keys',
              style: themeStyle.styles.sectionCaption,
            ),
          ),
          const DefaultDivider(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ...?widget.children?.map((e) => _keyItem(themeStyle, localization, e)).toList(),
                  PushStateInkWidget(
                    onPressed: () => showEWBottomSheet<void>(
                      context,
                      body: (_) => const AddNewSeedSheet(),
                      needCloseButton: false,
                      avoidBottomInsets: false,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      height: 46,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        // TODO: replace text
                        '+ Add key',
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
      ),
    );
  }

  Widget _seedDropdown(
    ThemeStyle themeStyle,
    AppLocalizations localization,
    KeyStoreEntry seed,
  ) {
    // ignore: use_decorated_box
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
            // TODO: replace text
            title: 'Export',
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
            // TODO: replace text
            title: 'Change password',
            onTap: () => showEWBottomSheet<void>(
              context,
              title: localization.change_seed_password,
              body: (_) => ChangeSeedPhrasePasswordModalBody(publicKey: seed.publicKey),
            ),
          ),
          MenuDropdownData(
            // TODO: replace text
            title: 'Delete',
            onTap: () => showSeedDeleteSheet(
              context: context,
              seed: seed,
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
    return EWListTile(
      leading: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: const BoxDecoration(color: ColorsRes.darkBlue, shape: BoxShape.circle),
        child: Assets.images.key.svg(width: 18, height: 18),
      ),
      titleText: key.name,
      subtitleText: '${key.name} 3 accounts',
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
          // TODO: replace text
          title: 'Hide',
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
          // TODO: replace text
          title: 'Copy key',
          onTap: () {},
        ),
        MenuDropdownData(
          // TODO: replace text
          title: 'Delete',
          onTap: () => showSeedDeleteSheet(
            context: context,
            seed: seed,
          ),
          textStyle: themeStyle.styles.basicStyle.copyWith(
            color: themeStyle.colors.errorTextColor,
          ),
        ),
      ],
    );
  }
}
