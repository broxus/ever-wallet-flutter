import 'package:ever_wallet/application/common/extensions.dart';
import 'package:ever_wallet/application/common/general/button/primary_elevated_button.dart';
import 'package:ever_wallet/application/common/general/default_divider.dart';
import 'package:ever_wallet/application/common/general/default_list_tile.dart';
import 'package:ever_wallet/application/common/general/ew_bottom_sheet.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/application/util/styles.dart';
import 'package:ever_wallet/application/util/theme_styles.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:ever_wallet/generated/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

Future<void> showKeyDeleteSheet({
  required BuildContext context,
  required KeyStoreEntry key,
  required List<AssetsList>? assets,
}) {
  return showEWBottomSheet(
    context,
    title: context.localization.delete_key,
    body: (_) => SeedKeySheet(seedKey: key, assets: assets),
  );
}

class SeedKeySheet extends StatelessWidget {
  final KeyStoreEntry seedKey;
  final List<AssetsList>? assets;

  const SeedKeySheet({
    super.key,
    required this.seedKey,
    required this.assets,
  });

  @override
  Widget build(BuildContext context) {
    final themeStyle = context.themeStyle;
    final localization = context.localization;

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
          localization.accounts_word,
          style: themeStyle.styles.basicStyle.copyWith(color: ColorsRes.grey),
        ),
        const SizedBox(height: 8),
        const DefaultDivider(),
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: assets
                      ?.map(
                        (e) => _accountItem(
                          e,
                          themeStyle,
                          localization,
                        ),
                      )
                      .toList() ??
                  [],
            ),
          ),
        ),
        const SizedBox(height: 16),
        PrimaryElevatedButton(
          text: localization.delete_word,
          onPressed: () {
            context.read<KeysRepository>().removeKey(seedKey.publicKey);

            Navigator.of(context).pop();
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
