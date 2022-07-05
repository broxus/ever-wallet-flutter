import 'package:flutter/material.dart';

import '../../../../../data/repositories/keys_repository.dart';
import '../../../../../injection.dart';
import '../../../../data/repositories/accounts_repository.dart';
import '../../../../data/repositories/biometry_repository.dart';
import '../../../../data/repositories/bookmarks_repository.dart';
import '../../../../data/repositories/keys_repository.dart';
import '../../../../data/repositories/search_history_repository.dart';
import '../../../../data/repositories/sites_meta_data_repository.dart';
import '../../../../data/repositories/token_currencies_repository.dart';
import '../../../../data/repositories/ton_assets_repository.dart';
import '../../../../injection.dart';
import '../../../common/general/dialog/default_dialog_controller.dart';
import '../../../util/extensions/context_extensions.dart';

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
      await getIt.get<KeysRepository>().clear();
      await getIt.get<AccountsRepository>().clear();
      await getIt.get<BiometryRepository>().clear();
      await getIt.get<TonAssetsRepository>().clear();
      await getIt.get<BookmarksRepository>().clear();
      await getIt.get<SearchHistoryRepository>().clear();
      await getIt.get<SitesMetaDataRepository>().clear();
      await getIt.get<TokenCurrenciesRepository>().clear();

      /// TODO: fix
      Navigator.of(context).pop();
    },
  );
}
