import 'package:auto_route/auto_route.dart';

import 'common/seed_creation/add_new_seed_page.dart';
import 'common/seed_creation/password_creation_page.dart';
import 'common/seed_creation/seed_name_page.dart';
import 'common/seed_creation/seed_phrase_check_page.dart';
import 'common/seed_creation/seed_phrase_import_page.dart';
import 'common/seed_creation/seed_phrase_save_page.dart';
import 'common/seed_creation/seed_phrase_type_page.dart';
import 'loading/loading_page.dart';
import 'main/browser/browser_page.dart';
import 'main/main_router_page.dart';
import 'main/profile/profile_page.dart';
import 'main/profile/seed_phrase_export_page.dart';
import 'main/wallet/wallet_page.dart';
import 'wizard/decentralization_policy_page.dart';
import 'wizard/network_selection_page.dart';
import 'wizard/welcome_page.dart';

@AdaptiveAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: [
    AdaptiveRoute(page: LoadingPage, initial: true),
    AdaptiveRoute(
      name: 'WizardRouterRoute',
      page: EmptyRouterPage,
      children: [
        AdaptiveRoute(page: NetworkSelectionPage, initial: true),
        AdaptiveRoute(page: WelcomePage),
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
        AdaptiveRoute(page: WalletPage, initial: true),
        AdaptiveRoute(page: BrowserPage),
        AdaptiveRoute(
          name: 'ProfileRouterRoute',
          page: EmptyRouterPage,
          children: [
            AdaptiveRoute(page: ProfilePage, initial: true),
            AdaptiveRoute(
              name: 'NewSeedRouterRoute',
              page: EmptyRouterPage,
              children: [
                AdaptiveRoute(page: AddNewSeedPage, initial: true),
                AdaptiveRoute(page: SeedNamePage),
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
