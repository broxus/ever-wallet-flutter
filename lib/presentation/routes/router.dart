import 'package:auto_route/auto_route.dart';

import 'common/seed_creation/new_seed_name_page.dart';
import 'common/seed_creation/password_creation_page.dart';
import 'common/seed_creation/seed_name_page.dart';
import 'common/seed_creation/seed_phrase_check_page.dart';
import 'common/seed_creation/seed_phrase_import_page.dart';
import 'common/seed_creation/seed_phrase_save_page.dart';
import 'common/seed_creation/seed_phrase_type_page.dart';
import 'loading_page/loading_page.dart';
import 'main_router/main_router_page.dart';
import 'main_router/settings/seed_phrase_export_page.dart';
import 'main_router/settings/settings_page.dart';
import 'main_router/wallet/new_account_flow/new_account_name_page.dart';
import 'main_router/wallet/new_account_flow/new_account_type_page.dart';
import 'main_router/wallet/wallet_page.dart';
import 'main_router/wallet/webview/webview_page.dart';
import 'welcome_router/decentralization_policy_page.dart';
import 'welcome_router/welcome_page.dart';

@AdaptiveAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: [
    AdaptiveRoute(page: LoadingPage, initial: true),
    AdaptiveRoute(
      name: 'WelcomeRouterRoute',
      page: EmptyRouterPage,
      children: [
        AdaptiveRoute(page: WelcomePage, initial: true),
        AdaptiveRoute(page: DecentralizationPolicyPage),
        AdaptiveRoute(page: SeedPhraseTypePage),
        AdaptiveRoute(page: SeedNamePage),
        AdaptiveRoute(page: SeedPhraseSavePage),
        AdaptiveRoute(page: SeedPhraseCheckPage),
        AdaptiveRoute(page: SeedPhraseImportPage),
        AdaptiveRoute(page: PasswordCreationPage),
      ],
    ),
    AdaptiveRoute(
      page: MainRouterPage,
      children: [
        AdaptiveRoute(
          name: 'WalletRouterRoute',
          page: EmptyRouterPage,
          initial: true,
          children: [
            AdaptiveRoute(page: WalletPage, initial: true),
            AdaptiveRoute(
              name: 'NewAccountRouterRoute',
              page: EmptyRouterPage,
              children: [
                AdaptiveRoute(page: NewAccountTypePage, initial: true),
                AdaptiveRoute(page: NewAccountNamePage),
              ],
            ),
          ],
        ),
        AdaptiveRoute(page: WebviewPage),
        AdaptiveRoute(
          name: 'SettingsRouterRoute',
          page: EmptyRouterPage,
          children: [
            AdaptiveRoute(page: SettingsPage, initial: true),
            AdaptiveRoute(
              name: 'NewSeedRouterRoute',
              page: EmptyRouterPage,
              children: [
                AdaptiveRoute(page: NewSeedNamePage, initial: true),
                AdaptiveRoute(page: SeedPhraseSavePage),
                AdaptiveRoute(page: SeedPhraseCheckPage),
                AdaptiveRoute(page: SeedPhraseImportPage),
                AdaptiveRoute(page: PasswordCreationPage),
              ],
            ),
            AdaptiveRoute(page: SeedPhraseExportPage),
          ],
        ),
      ],
    ),
  ],
)
class $AppRouter {}
