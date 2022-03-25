import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../data/repositories/keys_repository.dart';
import '../../../../../injection.dart';
import '../../../../data/repositories/accounts_repository.dart';
import '../../../../data/repositories/biometry_repository.dart';
import '../../../../data/repositories/bookmarks_repository.dart';
import '../../../../data/repositories/keys_repository.dart';
import '../../../../data/repositories/search_history_repository.dart';
import '../../../../data/repositories/sites_meta_data_repository.dart';
import '../../../../data/repositories/ton_assets_repository.dart';
import '../../../../generated/codegen_loader.g.dart';
import '../../../../injection.dart';

Future<void> showLogoutDialog({
  required BuildContext context,
}) =>
    showPlatformDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => Consumer(
        builder: (context, ref, child) => PlatformAlertDialog(
          title: Text(LocaleKeys.settings_screen_sections_logout_confirmation.tr()),
          actions: [
            PlatformDialogAction(
              onPressed: context.router.pop,
              cupertino: (_, __) => CupertinoDialogActionData(
                isDefaultAction: true,
              ),
              child: Text(LocaleKeys.actions_cancel.tr()),
            ),
            PlatformDialogAction(
              onPressed: () async {
                await getIt.get<KeysRepository>().clear();
                await getIt.get<AccountsRepository>().clear();
                await getIt.get<BiometryRepository>().clear();
                await getIt.get<TonAssetsRepository>().clear();
                await getIt.get<BookmarksRepository>().clear();
                await getIt.get<SearchHistoryRepository>().clear();
                await getIt.get<SitesMetaDataRepository>().clear();
                context.router.pop();
              },
              cupertino: (_, __) => CupertinoDialogActionData(
                isDestructiveAction: true,
              ),
              child: Text(LocaleKeys.settings_screen_sections_logout_action.tr()),
            ),
          ],
        ),
      ),
    );
