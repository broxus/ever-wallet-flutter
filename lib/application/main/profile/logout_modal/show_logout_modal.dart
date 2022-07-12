import 'package:ever_wallet/application/common/general/dialog/default_dialog_controller.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
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

Future<void> showLogoutDialog({
  required BuildContext context,
}) {
  final localization = context.localization;
  return DefaultDialogController.showAlertDialog(
    context: context,
    title: localization.logout_confirmation,
    cancelText: localization.cancel,
    onDisagreeClicked: Navigator.pop,
    agreeText: localization.logout,
    onAgreeClicked: (context) async {
      await context.read<KeysRepository>().clear();
      await context.read<AccountsRepository>().clear();
      await context.read<BiometryRepository>().clear();
      await context.read<TonAssetsRepository>().clear();
      await context.read<BookmarksRepository>().clear();
      await context.read<SearchHistoryRepository>().clear();
      await context.read<SitesMetaDataRepository>().clear();
      await context.read<TokenCurrenciesRepository>().clear();

      /// TODO: fix
      Navigator.of(context).pop();
    },
  );
}
