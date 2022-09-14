import 'package:ever_wallet/application/application.dart';
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
      final keyRepo = context.read<KeysRepository>();
      final accountsRepo = context.read<AccountsRepository>();
      final bioRepo = context.read<BiometryRepository>();
      final tonRepo = context.read<TonAssetsRepository>();
      final bookmarksRepo = context.read<BookmarksRepository>();
      final historyRepo = context.read<SearchHistoryRepository>();
      final metaRepo = context.read<SitesMetaDataRepository>();
      final tokenRepo = context.read<TokenCurrenciesRepository>();
      final navigator = Navigator.of(context, rootNavigator: true);

      await keyRepo.clear();
      await accountsRepo.clear();
      await bioRepo.clear();
      await tonRepo.clear();
      await bookmarksRepo.clear();
      await historyRepo.clear();
      await metaRepo.clear();
      await tokenRepo.clear();

      navigator.pushNamedAndRemoveUntil(AppRouter.onboarding, (route) => false);
    },
  );
}
