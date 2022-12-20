import 'package:ever_wallet/application/common/general/button/primary_icon_button.dart';
import 'package:ever_wallet/application/common/general/default_list_tile.dart';
import 'package:ever_wallet/application/main/profile/manage_seed/manage_seed_actions/add_seed_screens/create_seed_profile.dart';
import 'package:ever_wallet/application/main/profile/manage_seed/manage_seed_actions/add_seed_screens/enter_seed_name_profile.dart';
import 'package:ever_wallet/application/main/profile/manage_seed/manage_seed_actions/add_seed_screens/enter_seed_profile_screen.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/application/util/styles.dart';
import 'package:flutter/material.dart';

class AddNewSeedSheet extends StatefulWidget {
  const AddNewSeedSheet({super.key});

  @override
  State<AddNewSeedSheet> createState() => _AddNewSeedSheetState();
}

class _AddNewSeedSheetState extends State<AddNewSeedSheet> {
  @override
  Widget build(BuildContext context) {
    final localization = context.localization;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  localization.add_seed_phrase,
                  style: StylesRes.header2Faktum.copyWith(color: ColorsRes.black),
                ),
              ),
              PrimaryIconButton(
                onPressed: () => Navigator.of(context).pop(),
                outerPadding: EdgeInsets.zero,
                icon: const Icon(Icons.close, color: ColorsRes.neutral600, size: 25),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _sheetItem(
            localization.create_seed,
            () => Navigator.of(context).pushReplacement(
              EnterSeedNameProfileRoute(
                (context, name) => Navigator.of(context).push(CreateSeedProfileRoute(name)),
              ),
            ),
            Icons.add_rounded,
          ),
          const SizedBox(height: 8),
          _sheetItem(
            localization.import_seed,
            () => Navigator.of(context).pushReplacement(
              EnterSeedNameProfileRoute(
                (context, name) => Navigator.of(context).push(EnterSeedProfileRoute(name)),
              ),
            ),
            Icons.file_download_outlined,
          ),
        ],
      ),
    );
  }

  Widget _sheetItem(String title, VoidCallback action, IconData icon) {
    return EWListTile(
      height: 56,
      backgroundColor: ColorsRes.blue950,
      onPressed: action,
      leading: Icon(
        icon,
        color: ColorsRes.bluePrimary400,
        size: 27,
      ),
      trailing: const Icon(
        Icons.keyboard_arrow_right_rounded,
        color: ColorsRes.bluePrimary400,
        size: 27,
      ),
      titleWidget: Text(
        title,
        style: StylesRes.medium16.copyWith(color: ColorsRes.bluePrimary400),
      ),
    );
  }
}
