import 'package:ever_wallet/application/common/general/button/primary_elevated_button.dart';
import 'package:ever_wallet/application/common/general/default_divider.dart';
import 'package:ever_wallet/application/common/general/default_list_tile.dart';
import 'package:ever_wallet/application/common/general/ew_bottom_sheet.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/application/util/theme_styles.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:ever_wallet/generated/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

Future<void> showSeedDeleteSheet({
  required BuildContext context,
  required KeyStoreEntry seed,
}) {
  return showEWBottomSheet(
    context,
    title: context.localization.delete_seed_phrase,
    body: (_) => SeedDeleteSheet(seed: seed),
  );
}

class SeedDeleteSheet extends StatelessWidget {
  final KeyStoreEntry seed;

  const SeedDeleteSheet({
    super.key,
    required this.seed,
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
            localization.after_deletion_seed_disappear,
            style: themeStyle.styles.basicStyle.copyWith(color: ColorsRes.text),
          ),
        ),
        Text(
          localization.seed_word,
          style: themeStyle.styles.basicStyle.copyWith(color: ColorsRes.grey),
        ),
        const SizedBox(height: 8),
        const DefaultDivider(),
        EWListTile(
          leading: Assets.images.seed.svg(height: 32, width: 32),
          titleWidget: Text(
            seed.name,
            style: themeStyle.styles.basicStyle.copyWith(color: ColorsRes.text),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        Text(
          localization.keys_word,
          style: themeStyle.styles.basicStyle.copyWith(color: ColorsRes.grey),
        ),
        const SizedBox(height: 8),
        const DefaultDivider(),
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(1, (_) => _accountItem(themeStyle, localization)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        PrimaryElevatedButton(
          text: localization.delete_word,
          onPressed: () {
            context.read<KeysRepository>().removeKey(seed.publicKey);

            Navigator.of(context).pop();
          },
          isDestructive: true,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _accountItem(ThemeStyle themeStyle, AppLocalizations localization) {
    return EWListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 32,
        height: 32,
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: ColorsRes.darkBlue,
          shape: BoxShape.circle,
        ),
        child: Assets.images.key.svg(),
      ),
      titleWidget: Text(
        localization.key_name,
        style: themeStyle.styles.basicStyle.copyWith(color: ColorsRes.text),
      ),
      // TODO: replace text
      subtitleText: localization.key_name_with_sub_count('0:9f9...1e0', 3),
    );
  }
}
