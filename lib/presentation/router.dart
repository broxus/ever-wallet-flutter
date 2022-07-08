import 'package:auto_route/auto_route.dart';

import 'loading/loading_page.dart';
import 'main/browser/browser_page.dart';
import 'main/main_router_page.dart';
import 'main/profile/profile_page.dart';
import 'main/wallet/wallet_page.dart';
import 'onboarding/start_screen/start_screen.dart';

@AdaptiveAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: [
    AdaptiveRoute(page: LoadingPage, initial: true),
    AdaptiveRoute(
      name: 'WizardRouterRoute',
      page: EmptyRouterPage,
      children: [
        AdaptiveRoute(page: StartScreen, initial: true),
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
          ],
        ),
      ],
    ),
  ],
)
class $AppRouter {}
