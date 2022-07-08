import 'package:ever_wallet/data/repositories/accounts_repository.dart';
import 'package:ever_wallet/data/repositories/biometry_repository.dart';
import 'package:ever_wallet/data/repositories/bookmarks_repository.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:ever_wallet/data/repositories/search_history_repository.dart';
import 'package:ever_wallet/data/repositories/sites_meta_data_repository.dart';
import 'package:ever_wallet/data/repositories/token_currencies_repository.dart';
import 'package:ever_wallet/data/repositories/ton_assets_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

Future<void> showLogoutDialog({
  required BuildContext context,
}) =>
    showPlatformDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => PlatformAlertDialog(
        title: Text(AppLocalizations.of(context)!.logout_confirmation),
        actions: [
          PlatformDialogAction(
            onPressed: Navigator.of(context).pop,
            cupertino: (_, __) => CupertinoDialogActionData(
              isDefaultAction: true,
            ),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          PlatformDialogAction(
            onPressed: () async {
              await context.read<KeysRepository>().clear();
              await context.read<AccountsRepository>().clear();
              await context.read<BiometryRepository>().clear();
              await context.read<TonAssetsRepository>().clear();
              await context.read<BookmarksRepository>().clear();
              await context.read<SearchHistoryRepository>().clear();
              await context.read<SitesMetaDataRepository>().clear();
              await context.read<TokenCurrenciesRepository>().clear();
              Navigator.of(context).pop();
            },
            cupertino: (_, __) => CupertinoDialogActionData(
              isDestructiveAction: true,
            ),
            child: Text(AppLocalizations.of(context)!.logout),
          ),
        ],
      ),
    );
