import 'package:auto_route/auto_route.dart';

import 'presentation/loading_screen/loading_screen.dart';
import 'presentation/ordinary/main_flow.dart';
import 'presentation/ordinary/settings/new_account_flow/name_new_account_screen.dart';
import 'presentation/ordinary/settings/new_account_flow/new_account_flow.dart';
import 'presentation/ordinary/settings/new_account_flow/new_account_type_screen.dart';
import 'presentation/ordinary/settings/new_seed_flow/name_new_seed_screen.dart';
import 'presentation/ordinary/settings/new_seed_flow/new_seed_flow.dart';
import 'presentation/ordinary/settings/seed_phrase_export_screen.dart';
import 'presentation/ordinary/settings/settings_flow.dart';
import 'presentation/ordinary/settings/settings_screen.dart';
import 'presentation/ordinary/wallet/wallet_screen.dart';
import 'presentation/ordinary/wallet_flow.dart';
import 'presentation/seed_creation_flow/password_creation_screen.dart';
import 'presentation/seed_creation_flow/seed_phrase_check_screen.dart';
import 'presentation/seed_creation_flow/seed_phrase_import_screen.dart';
import 'presentation/seed_creation_flow/seed_phrase_save_screen.dart';
import 'presentation/welcome/name_seed_screen.dart';
import 'presentation/welcome/welcome_flow.dart';
import 'presentation/welcome/welcome_policy_screen.dart';
import 'presentation/welcome/welcome_screen.dart';

@AdaptiveAutoRouter(
  routes: [
    CustomRoute(
      page: LoadingScreen,
      initial: true,
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: WelcomeFlow,
      children: [
        AdaptiveRoute(page: WelcomeScreen, initial: true),
        AdaptiveRoute(page: WelcomePolicyScreen),
        AdaptiveRoute(page: NameSeedScreen),
        AdaptiveRoute(page: SeedPhraseSaveScreen),
        AdaptiveRoute(page: SeedPhraseCheckScreen),
        AdaptiveRoute(page: SeedPhraseImportScreen),
        AdaptiveRoute(page: PasswordCreationScreen),
      ],
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: MainFlow,
      transitionsBuilder: TransitionsBuilders.fadeIn,
      children: [
        CustomRoute(
          initial: true,
          page: WalletFlow,
          children: [
            AdaptiveRoute(page: WalletScreen, initial: true),
            AdaptiveRoute(
              page: NewAccountFlow,
              children: [
                AdaptiveRoute(page: NameNewAccountScreen, initial: true),
                AdaptiveRoute(page: NewAccountTypeScreen),
              ],
            ),
          ],
          transitionsBuilder: TransitionsBuilders.fadeIn,
        ),
        CustomRoute(
          page: SettingsFlow,
          children: [
            AdaptiveRoute(page: SettingsScreen, initial: true),
            AdaptiveRoute(
              page: NewSeedFlow,
              children: [
                AdaptiveRoute(page: NameNewSeedScreen, initial: true),
                AdaptiveRoute(page: SeedPhraseSaveScreen),
                AdaptiveRoute(page: SeedPhraseCheckScreen),
                AdaptiveRoute(page: SeedPhraseImportScreen),
                AdaptiveRoute(page: PasswordCreationScreen),
              ],
            ),
            AdaptiveRoute(
              page: NewAccountFlow,
              children: [
                AdaptiveRoute(page: NameNewAccountScreen, initial: true),
                AdaptiveRoute(page: NewAccountTypeScreen),
              ],
            ),
            AdaptiveRoute(page: SeedPhraseExportScreen),
          ],
          transitionsBuilder: TransitionsBuilders.fadeIn,
        ),
      ],
    ),
  ],
)
class $AppRouter {}
