import 'package:ever_wallet/application/common/extensions.dart';
import 'package:ever_wallet/application/common/general/button/primary_elevated_button.dart';
import 'package:ever_wallet/application/common/general/default_divider.dart';
import 'package:ever_wallet/application/common/general/default_list_tile.dart';
import 'package:ever_wallet/application/common/general/ew_bottom_sheet.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/application/util/styles.dart';
import 'package:ever_wallet/application/util/theme_styles.dart';
import 'package:ever_wallet/data/repositories/accounts_repository.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:ever_wallet/generated/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

Future<bool?> showKeyDeleteSheet({
  required BuildContext context,
  required KeyStoreEntry key,
  required List<AssetsList> assets,
}) {
  return showEWBottomSheet<bool>(
    context,
    title: context.localization.delete_key,
    body: (_) => SeedKeySheet(seedKey: key, assets: assets),
  );
}

class SeedKeySheet extends StatelessWidget {
  final KeyStoreEntry seedKey;
  final List<AssetsList> assets;

  const SeedKeySheet({
    super.key,
    required this.seedKey,
    required this.assets,
  });

  @override
  Widget build(BuildContext context) {
    final themeStyle = context.themeStyle;
    final localization = context.localization;

    final externalAccountsAddresses =
        context.read<AccountsRepository>().externalAccounts[seedKey.publicKey] ?? [];
    final accounts = <AssetsList>[];
    final externalAccounts = <AssetsList>[];

    assets.forEach((a) {
      if (externalAccountsAddresses.contains(a.address)) {
        externalAccounts.add(a);
      } else {
        accounts.add(a);
      }
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            localization.after_deletion_public_disappear,
            style: themeStyle.styles.basicStyle.copyWith(color: ColorsRes.text),
          ),
        ),
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localization.public_key,
                  style: themeStyle.styles.basicStyle.copyWith(color: ColorsRes.grey),
                ),
                const SizedBox(height: 8),
                const DefaultDivider(),
                EWListTile(
                  leading: Assets.images.seed.svg(height: 32, width: 32),
                  titleWidget: Text(
                    seedKey.name,
                    style: themeStyle.styles.basicStyle.copyWith(color: ColorsRes.text),
                  ),
                  subtitleWidget: Text(
                    seedKey.publicKey.ellipsePublicKey(),
                    style: StylesRes.subtitleStyle.copyWith(color: ColorsRes.grey),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
                Text(
                  localization.my_accounts,
                  style: themeStyle.styles.basicStyle.copyWith(color: ColorsRes.grey),
                ),
                const SizedBox(height: 8),
                const DefaultDivider(),
                ...accounts.map(
                  (e) => _accountItem(e, themeStyle, localization),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    localization.external_accounts,
                    style: themeStyle.styles.basicStyle.copyWith(color: ColorsRes.grey),
                  ),
                ),
                const DefaultDivider(),
                ...externalAccounts.map(
                  (e) => _accountItem(e, themeStyle, localization),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        PrimaryElevatedButton(
          text: localization.delete_word,
          onPressed: () {
            Navigator.of(context).pop(true);

            context.read<KeysRepository>().removeKey(seedKey.publicKey);
          },
          isDestructive: true,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _accountItem(
    AssetsList assets,
    ThemeStyle themeStyle,
    AppLocalizations localization,
  ) {
    return EWListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: Assets.images.account.svg(width: 32, height: 32),
      ),
      titleWidget: Text(
        assets.name,
        style: themeStyle.styles.basicStyle.copyWith(color: ColorsRes.text),
      ),
      subtitleWidget: Text(
        assets.address.ellipseAddress(),
        style: StylesRes.subtitleStyle.copyWith(color: ColorsRes.grey),
      ),
    );
  }
}
