import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../data/repositories/keys_repository.dart';
import '../../../../../../injection.dart';
import '../../../../../generated/assets.gen.dart';
import '../../../../common/general/button/primary_elevated_button.dart';
import '../../../../common/general/default_divider.dart';
import '../../../../common/general/default_list_tile.dart';
import '../../../../common/widgets/ew_bottom_sheet.dart';
import '../../../../util/colors.dart';
import '../../../../util/extensions/context_extensions.dart';
import '../../../../util/theme_styles.dart';

Future<void> showSeedDeleteSheet({
  required BuildContext context,
  required KeyStoreEntry seed,
}) {
  return showEWBottomSheet(
    context,
    // TODO: replace text
    title: 'Delete seed phrase',
    // title: context.localization.remove_seed,
    body: SeedDeleteSheet(seed: seed),
  );
}

class SeedDeleteSheet extends StatelessWidget {
  final KeyStoreEntry seed;

  const SeedDeleteSheet({
    Key? key,
    required this.seed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeStyle = context.themeStyle;
    // final localization = context.localization;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            // TODO: replace text
            'After deletion seed phrase will disappear from your list. You will be able to get it back by importing.',
            style: themeStyle.styles.basicStyle.copyWith(color: ColorsRes.text),
          ),
        ),
        Text(
          // TODO: replace text
          'Seed',
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
          // TODO: replace text
          'Keys',
          style: themeStyle.styles.basicStyle.copyWith(color: ColorsRes.grey),
        ),
        const SizedBox(height: 8),
        const DefaultDivider(),
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(1, (_) => _accountItem(themeStyle)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        PrimaryElevatedButton(
          // TODO: replace text
          text: 'Delete',
          onPressed: () {
            getIt.get<KeysRepository>().removeKey(seed.publicKey);

            Navigator.of(context).pop();
          },
          isDestructive: true,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _accountItem(ThemeStyle themeStyle) {
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
        // TODO: replace text
        'Key name',
        style: themeStyle.styles.basicStyle.copyWith(color: ColorsRes.text),
      ),
      // TODO: replace text
      subtitleText: '0:9f9...1e0  3 accounts',
    );
  }
}
