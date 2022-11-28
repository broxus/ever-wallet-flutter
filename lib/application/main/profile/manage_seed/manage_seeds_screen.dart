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
import 'package:ever_wallet/application/main/profile/manage_seed/manage_seed_actions/show_seed_delete_sheet.dart';
import 'package:ever_wallet/application/main/profile/manage_seed/seed_detail_screen.dart';
import 'package:ever_wallet/application/main/profile/widgets/keys_builder.dart';
import 'package:ever_wallet/application/util/auth_utils.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/application/util/extensions/iterable_extensions.dart';
import 'package:ever_wallet/application/util/theme_styles.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:ever_wallet/generated/assets.gen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:provider/provider.dart';

class ManageSeedsRoute extends MaterialPageRoute<void> {
  ManageSeedsRoute() : super(builder: (_) => const ManageSeedsScreen());
}

class ManageSeedsScreen extends StatefulWidget {
  const ManageSeedsScreen({super.key});

  @override
  State<ManageSeedsScreen> createState() => _ManageSeedsScreenState();
}

class _ManageSeedsScreenState extends State<ManageSeedsScreen> {
  @override
  Widget build(BuildContext context) {
    final localization = context.localization;
    final themeStyle = context.themeStyle;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: DefaultAppBar(
        backText: localization.profile,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                localization.manage_seeds_subscriptions,
                style: themeStyle.styles.header3Style,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                localization.seed_phrases,
                style: themeStyle.styles.sectionCaption,
              ),
            ),
            const DefaultDivider(),
            KeysBuilderWidget(
              builder: (keys, currentKey) => _buildSeedItems(
                context.themeStyle,
                context.localization,
                keys,
                currentKey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeedItems(
    ThemeStyle themeStyle,
    AppLocalizations localization,
    Map<KeyStoreEntry, List<KeyStoreEntry>?> keys,
    KeyStoreEntry? currentKey,
  ) {
    final seedsList = keys.keys
        .map(
          (e) => _seedItem(
            themeStyle,
            localization,
            e,
            keys[e],
            e.publicKey == currentKey?.publicKey,
          ),
        )
        .separated(const DefaultDivider(bothIndent: 16));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ...seedsList,
        if (seedsList.isNotEmpty) const DefaultDivider(bothIndent: 16),
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
              localization.plus_add_new_seed,
              style: themeStyle.styles.basicStyle.copyWith(
                color: ColorsRes.darkBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _seedItem(
    ThemeStyle themeStyle,
    AppLocalizations localization,
    KeyStoreEntry seed,
    List<KeyStoreEntry>? children,
    bool isSelected,
  ) {
    return EWListTile(
      leading: Assets.images.seed.svg(width: 32, height: 32),
      titleText: seed.name,
      onPressed: () => Navigator.of(context).push(SeedDetailScreenRoute(seed: seed)),
      // +1 because seed is a public key itself
      subtitleText: localization.children_public_keys((children?.length ?? 0) + 1),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelected)
            Icon(
              CupertinoIcons.checkmark_alt,
              color: themeStyle.colors.primaryButtonTextColor,
              size: 20,
            ),
          _seedDropdown(themeStyle, localization, seed, children),
        ],
      ),
    );
  }

  Widget _seedDropdown(
    ThemeStyle themeStyle,
    AppLocalizations localization,
    KeyStoreEntry seed,
    List<KeyStoreEntry>? children,
  ) {
    return MenuDropdown(
      items: [
        MenuDropdownData(
          title: localization.use_this_seed,
          onTap: () => context.read<KeysRepository>().setCurrentKey(seed.publicKey),
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
    );
  }
}
