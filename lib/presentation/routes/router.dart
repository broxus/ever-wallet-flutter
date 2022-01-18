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
        AdaptiveRoute(page: WalletPage, initial: true),
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

// // **************************************************************************
// // AutoRouteGenerator
// // **************************************************************************

// // GENERATED CODE - DO NOT MODIFY BY HAND

// // **************************************************************************
// // AutoRouteGenerator
// // **************************************************************************
// //
// // ignore_for_file: type=lint

// import 'package:auto_route/auto_route.dart' as _i2;
// import 'package:ever_wallet/presentation/routes/common/seed_creation/new_seed_name_page.dart'
//     as _i16;
// import 'package:ever_wallet/presentation/routes/common/seed_creation/password_creation_page.dart'
//     as _i11;
// import 'package:ever_wallet/presentation/routes/common/seed_creation/seed_name_page.dart'
//     as _i7;
// import 'package:ever_wallet/presentation/routes/common/seed_creation/seed_phrase_check_page.dart'
//     as _i9;
// import 'package:ever_wallet/presentation/routes/common/seed_creation/seed_phrase_import_page.dart'
//     as _i10;
// import 'package:ever_wallet/presentation/routes/common/seed_creation/seed_phrase_save_page.dart'
//     as _i8;
// import 'package:ever_wallet/presentation/routes/common/seed_creation/seed_phrase_type_page.dart'
//     as _i6;
// import 'package:ever_wallet/presentation/routes/loading_page/loading_page.dart'
//     as _i1;
// import 'package:ever_wallet/presentation/routes/main_router/main_router_page.dart'
//     as _i3;
// import 'package:ever_wallet/presentation/routes/main_router/settings/seed_phrase_export_page.dart'
//     as _i15;
// import 'package:ever_wallet/presentation/routes/main_router/settings/settings_page.dart'
//     as _i14;
// import 'package:ever_wallet/presentation/routes/main_router/wallet/wallet_page.dart'
//     as _i12;
// import 'package:ever_wallet/presentation/routes/main_router/wallet/webview/webview_page.dart'
//     as _i13;
// import 'package:ever_wallet/presentation/routes/welcome_router/decentralization_policy_page.dart'
//     as _i5;
// import 'package:ever_wallet/presentation/routes/welcome_router/welcome_page.dart'
//     as _i4;
// import 'package:flutter/material.dart' as _i17;
// import 'package:nekoton_flutter/nekoton_flutter.dart' as _i18;

// class AppRouter extends _i2.RootStackRouter {
//   AppRouter([_i17.GlobalKey<_i17.NavigatorState>? navigatorKey])
//       : super(navigatorKey);

//   @override
//   final Map<String, _i2.PageFactory> pagesMap = {
//     LoadingRoute.name: (routeData) {
//       return _i2.AdaptivePage<dynamic>(
//           routeData: routeData, child: const _i1.LoadingPage());
//     },
//     WelcomeRouterRoute.name: (routeData) {
//       return _i2.AdaptivePage<dynamic>(
//           routeData: routeData, child: const _i2.EmptyRouterPage());
//     },
//     MainRouterRoute.name: (routeData) {
//       return _i2.AdaptivePage<dynamic>(
//           routeData: routeData, child: const _i3.MainRouterPage());
//     },
//     WelcomeRoute.name: (routeData) {
//       return _i2.AdaptivePage<dynamic>(
//           routeData: routeData, child: const _i4.WelcomePage());
//     },
//     DecentralizationPolicyRoute.name: (routeData) {
//       final args = routeData.argsAs<DecentralizationPolicyRouteArgs>();
//       return _i2.AdaptivePage<dynamic>(
//           routeData: routeData,
//           child: _i5.DecentralizationPolicyPage(
//               key: args.key, onPressed: args.onPressed));
//     },
//     SeedPhraseTypeRoute.name: (routeData) {
//       final args = routeData.argsAs<SeedPhraseTypeRouteArgs>();
//       return _i2.AdaptivePage<dynamic>(
//           routeData: routeData,
//           child: _i6.SeedPhraseTypePage(
//               key: args.key, onSelected: args.onSelected));
//     },
//     SeedNameRoute.name: (routeData) {
//       final args = routeData.argsAs<SeedNameRouteArgs>();
//       return _i2.AdaptivePage<dynamic>(
//           routeData: routeData,
//           child: _i7.SeedNamePage(key: args.key, onSubmit: args.onSubmit));
//     },
//     SeedPhraseSaveRoute.name: (routeData) {
//       final args = routeData.argsAs<SeedPhraseSaveRouteArgs>();
//       return _i2.AdaptivePage<dynamic>(
//           routeData: routeData,
//           child:
//               _i8.SeedPhraseSavePage(key: args.key, seedName: args.seedName));
//     },
//     SeedPhraseCheckRoute.name: (routeData) {
//       final args = routeData.argsAs<SeedPhraseCheckRouteArgs>();
//       return _i2.AdaptivePage<dynamic>(
//           routeData: routeData,
//           child: _i9.SeedPhraseCheckPage(
//               key: args.key, seedName: args.seedName, phrase: args.phrase));
//     },
//     SeedPhraseImportRoute.name: (routeData) {
//       final args = routeData.argsAs<SeedPhraseImportRouteArgs>();
//       return _i2.AdaptivePage<dynamic>(
//           routeData: routeData,
//           child: _i10.SeedPhraseImportPage(
//               key: args.key, seedName: args.seedName, isLegacy: args.isLegacy));
//     },
//     PasswordCreationRoute.name: (routeData) {
//       final args = routeData.argsAs<PasswordCreationRouteArgs>();
//       return _i2.AdaptivePage<dynamic>(
//           routeData: routeData,
//           child: _i11.PasswordCreationPage(
//               key: args.key, phrase: args.phrase, seedName: args.seedName));
//     },
//     WalletRoute.name: (routeData) {
//       return _i2.AdaptivePage<dynamic>(
//           routeData: routeData, child: _i12.WalletPage());
//     },
//     WebviewRoute.name: (routeData) {
//       return _i2.AdaptivePage<dynamic>(
//           routeData: routeData, child: _i13.WebviewPage());
//     },
//     SettingsRouterRoute.name: (routeData) {
//       return _i2.AdaptivePage<dynamic>(
//           routeData: routeData, child: const _i2.EmptyRouterPage());
//     },
//     SettingsRoute.name: (routeData) {
//       return _i2.AdaptivePage<dynamic>(
//           routeData: routeData, child: _i14.SettingsPage());
//     },
//     NewSeedRouterRoute.name: (routeData) {
//       return _i2.AdaptivePage<dynamic>(
//           routeData: routeData, child: const _i2.EmptyRouterPage());
//     },
//     SeedPhraseExportRoute.name: (routeData) {
//       final args = routeData.argsAs<SeedPhraseExportRouteArgs>();
//       return _i2.AdaptivePage<dynamic>(
//           routeData: routeData,
//           child: _i15.SeedPhraseExportPage(key: args.key, phrase: args.phrase));
//     },
//     AddNewSeedRoute.name: (routeData) {
//       return _i2.AdaptivePage<dynamic>(
//           routeData: routeData, child: const _i16.AddNewSeedPage());
//     }
//   };

//   @override
//   List<_i2.RouteConfig> get routes => [
//         _i2.RouteConfig(LoadingRoute.name, path: '/'),
//         _i2.RouteConfig(WelcomeRouterRoute.name,
//             path: '/empty-router-page',
//             children: [
//               _i2.RouteConfig(WelcomeRoute.name,
//                   path: '', parent: WelcomeRouterRoute.name),
//               _i2.RouteConfig(DecentralizationPolicyRoute.name,
//                   path: 'decentralization-policy-page',
//                   parent: WelcomeRouterRoute.name),
//               _i2.RouteConfig(SeedPhraseTypeRoute.name,
//                   path: 'seed-phrase-type-page',
//                   parent: WelcomeRouterRoute.name),
//               _i2.RouteConfig(SeedNameRoute.name,
//                   path: 'seed-name-page', parent: WelcomeRouterRoute.name),
//               _i2.RouteConfig(SeedPhraseSaveRoute.name,
//                   path: 'seed-phrase-save-page',
//                   parent: WelcomeRouterRoute.name),
//               _i2.RouteConfig(SeedPhraseCheckRoute.name,
//                   path: 'seed-phrase-check-page',
//                   parent: WelcomeRouterRoute.name),
//               _i2.RouteConfig(SeedPhraseImportRoute.name,
//                   path: 'seed-phrase-import-page',
//                   parent: WelcomeRouterRoute.name),
//               _i2.RouteConfig(PasswordCreationRoute.name,
//                   path: 'password-creation-page',
//                   parent: WelcomeRouterRoute.name)
//             ]),
//         _i2.RouteConfig(MainRouterRoute.name,
//             path: '/main-router-page',
//             children: [
//               _i2.RouteConfig(WalletRoute.name,
//                   path: '', parent: MainRouterRoute.name),
//               _i2.RouteConfig(WebviewRoute.name,
//                   path: 'webview-page', parent: MainRouterRoute.name),
//               _i2.RouteConfig(SettingsRouterRoute.name,
//                   path: 'empty-router-page',
//                   parent: MainRouterRoute.name,
//                   children: [
//                     _i2.RouteConfig(SettingsRoute.name,
//                         path: '', parent: SettingsRouterRoute.name),
//                     _i2.RouteConfig(NewSeedRouterRoute.name,
//                         path: 'empty-router-page',
//                         parent: SettingsRouterRoute.name,
//                         children: [
//                           _i2.RouteConfig(AddNewSeedRoute.name,
//                               path: '', parent: NewSeedRouterRoute.name),
//                           _i2.RouteConfig(SeedNameRoute.name,
//                               path: 'seed-name-page',
//                               parent: NewSeedRouterRoute.name),
//                           _i2.RouteConfig(SeedPhraseSaveRoute.name,
//                               path: 'seed-phrase-save-page',
//                               parent: NewSeedRouterRoute.name),
//                           _i2.RouteConfig(SeedPhraseCheckRoute.name,
//                               path: 'seed-phrase-check-page',
//                               parent: NewSeedRouterRoute.name),
//                           _i2.RouteConfig(SeedPhraseImportRoute.name,
//                               path: 'seed-phrase-import-page',
//                               parent: NewSeedRouterRoute.name),
//                           _i2.RouteConfig(PasswordCreationRoute.name,
//                               path: 'password-creation-page',
//                               parent: NewSeedRouterRoute.name)
//                         ]),
//                     _i2.RouteConfig(SeedPhraseExportRoute.name,
//                         path: 'seed-phrase-export-page',
//                         parent: SettingsRouterRoute.name)
//                   ])
//             ])
//       ];
// }

// /// generated route for
// /// [_i1.LoadingPage]
// class LoadingRoute extends _i2.PageRouteInfo<void> {
//   const LoadingRoute() : super(LoadingRoute.name, path: '/');

//   static const String name = 'LoadingRoute';
// }

// /// generated route for
// /// [_i2.EmptyRouterPage]
// class WelcomeRouterRoute extends _i2.PageRouteInfo<void> {
//   const WelcomeRouterRoute({List<_i2.PageRouteInfo>? children})
//       : super(WelcomeRouterRoute.name,
//             path: '/empty-router-page', initialChildren: children);

//   static const String name = 'WelcomeRouterRoute';
// }

// /// generated route for
// /// [_i3.MainRouterPage]
// class MainRouterRoute extends _i2.PageRouteInfo<void> {
//   const MainRouterRoute({List<_i2.PageRouteInfo>? children})
//       : super(MainRouterRoute.name,
//             path: '/main-router-page', initialChildren: children);

//   static const String name = 'MainRouterRoute';
// }

// /// generated route for
// /// [_i4.WelcomePage]
// class WelcomeRoute extends _i2.PageRouteInfo<void> {
//   const WelcomeRoute() : super(WelcomeRoute.name, path: '');

//   static const String name = 'WelcomeRoute';
// }

// /// generated route for
// /// [_i5.DecentralizationPolicyPage]
// class DecentralizationPolicyRoute
//     extends _i2.PageRouteInfo<DecentralizationPolicyRouteArgs> {
//   DecentralizationPolicyRoute(
//       {_i17.Key? key, required void Function() onPressed})
//       : super(DecentralizationPolicyRoute.name,
//             path: 'decentralization-policy-page',
//             args: DecentralizationPolicyRouteArgs(
//                 key: key, onPressed: onPressed));

//   static const String name = 'DecentralizationPolicyRoute';
// }

// class DecentralizationPolicyRouteArgs {
//   const DecentralizationPolicyRouteArgs({this.key, required this.onPressed});

//   final _i17.Key? key;

//   final void Function() onPressed;

//   @override
//   String toString() {
//     return 'DecentralizationPolicyRouteArgs{key: $key, onPressed: $onPressed}';
//   }
// }

// /// generated route for
// /// [_i6.SeedPhraseTypePage]
// class SeedPhraseTypeRoute extends _i2.PageRouteInfo<SeedPhraseTypeRouteArgs> {
//   SeedPhraseTypeRoute(
//       {_i17.Key? key, required void Function(_i18.MnemonicType) onSelected})
//       : super(SeedPhraseTypeRoute.name,
//             path: 'seed-phrase-type-page',
//             args: SeedPhraseTypeRouteArgs(key: key, onSelected: onSelected));

//   static const String name = 'SeedPhraseTypeRoute';
// }

// class SeedPhraseTypeRouteArgs {
//   const SeedPhraseTypeRouteArgs({this.key, required this.onSelected});

//   final _i17.Key? key;

//   final void Function(_i18.MnemonicType) onSelected;

//   @override
//   String toString() {
//     return 'SeedPhraseTypeRouteArgs{key: $key, onSelected: $onSelected}';
//   }
// }

// /// generated route for
// /// [_i7.SeedNamePage]
// class SeedNameRoute extends _i2.PageRouteInfo<SeedNameRouteArgs> {
//   SeedNameRoute({_i17.Key? key, required void Function(String?) onSubmit})
//       : super(SeedNameRoute.name,
//             path: 'seed-name-page',
//             args: SeedNameRouteArgs(key: key, onSubmit: onSubmit));

//   static const String name = 'SeedNameRoute';
// }

// class SeedNameRouteArgs {
//   const SeedNameRouteArgs({this.key, required this.onSubmit});

//   final _i17.Key? key;

//   final void Function(String?) onSubmit;

//   @override
//   String toString() {
//     return 'SeedNameRouteArgs{key: $key, onSubmit: $onSubmit}';
//   }
// }

// /// generated route for
// /// [_i8.SeedPhraseSavePage]
// class SeedPhraseSaveRoute extends _i2.PageRouteInfo<SeedPhraseSaveRouteArgs> {
//   SeedPhraseSaveRoute({_i17.Key? key, required String? seedName})
//       : super(SeedPhraseSaveRoute.name,
//             path: 'seed-phrase-save-page',
//             args: SeedPhraseSaveRouteArgs(key: key, seedName: seedName));

//   static const String name = 'SeedPhraseSaveRoute';
// }

// class SeedPhraseSaveRouteArgs {
//   const SeedPhraseSaveRouteArgs({this.key, required this.seedName});

//   final _i17.Key? key;

//   final String? seedName;

//   @override
//   String toString() {
//     return 'SeedPhraseSaveRouteArgs{key: $key, seedName: $seedName}';
//   }
// }

// /// generated route for
// /// [_i9.SeedPhraseCheckPage]
// class SeedPhraseCheckRoute extends _i2.PageRouteInfo<SeedPhraseCheckRouteArgs> {
//   SeedPhraseCheckRoute(
//       {_i17.Key? key, required String? seedName, required List<String> phrase})
//       : super(SeedPhraseCheckRoute.name,
//             path: 'seed-phrase-check-page',
//             args: SeedPhraseCheckRouteArgs(
//                 key: key, seedName: seedName, phrase: phrase));

//   static const String name = 'SeedPhraseCheckRoute';
// }

// class SeedPhraseCheckRouteArgs {
//   const SeedPhraseCheckRouteArgs(
//       {this.key, required this.seedName, required this.phrase});

//   final _i17.Key? key;

//   final String? seedName;

//   final List<String> phrase;

//   @override
//   String toString() {
//     return 'SeedPhraseCheckRouteArgs{key: $key, seedName: $seedName, phrase: $phrase}';
//   }
// }

// /// generated route for
// /// [_i10.SeedPhraseImportPage]
// class SeedPhraseImportRoute
//     extends _i2.PageRouteInfo<SeedPhraseImportRouteArgs> {
//   SeedPhraseImportRoute(
//       {_i17.Key? key, String? seedName, required bool isLegacy})
//       : super(SeedPhraseImportRoute.name,
//             path: 'seed-phrase-import-page',
//             args: SeedPhraseImportRouteArgs(
//                 key: key, seedName: seedName, isLegacy: isLegacy));

//   static const String name = 'SeedPhraseImportRoute';
// }

// class SeedPhraseImportRouteArgs {
//   const SeedPhraseImportRouteArgs(
//       {this.key, this.seedName, required this.isLegacy});

//   final _i17.Key? key;

//   final String? seedName;

//   final bool isLegacy;

//   @override
//   String toString() {
//     return 'SeedPhraseImportRouteArgs{key: $key, seedName: $seedName, isLegacy: $isLegacy}';
//   }
// }

// /// generated route for
// /// [_i11.PasswordCreationPage]
// class PasswordCreationRoute
//     extends _i2.PageRouteInfo<PasswordCreationRouteArgs> {
//   PasswordCreationRoute(
//       {_i17.Key? key, required List<String> phrase, String? seedName})
//       : super(PasswordCreationRoute.name,
//             path: 'password-creation-page',
//             args: PasswordCreationRouteArgs(
//                 key: key, phrase: phrase, seedName: seedName));

//   static const String name = 'PasswordCreationRoute';
// }

// class PasswordCreationRouteArgs {
//   const PasswordCreationRouteArgs(
//       {this.key, required this.phrase, this.seedName});

//   final _i17.Key? key;

//   final List<String> phrase;

//   final String? seedName;

//   @override
//   String toString() {
//     return 'PasswordCreationRouteArgs{key: $key, phrase: $phrase, seedName: $seedName}';
//   }
// }

// /// generated route for
// /// [_i12.WalletPage]
// class WalletRoute extends _i2.PageRouteInfo<void> {
//   const WalletRoute() : super(WalletRoute.name, path: '');

//   static const String name = 'WalletRoute';
// }

// /// generated route for
// /// [_i13.WebviewPage]
// class WebviewRoute extends _i2.PageRouteInfo<void> {
//   const WebviewRoute() : super(WebviewRoute.name, path: 'webview-page');

//   static const String name = 'WebviewRoute';
// }

// /// generated route for
// /// [_i2.EmptyRouterPage]
// class SettingsRouterRoute extends _i2.PageRouteInfo<void> {
//   const SettingsRouterRoute({List<_i2.PageRouteInfo>? children})
//       : super(SettingsRouterRoute.name,
//             path: 'empty-router-page', initialChildren: children);

//   static const String name = 'SettingsRouterRoute';
// }

// /// generated route for
// /// [_i14.SettingsPage]
// class SettingsRoute extends _i2.PageRouteInfo<void> {
//   const SettingsRoute() : super(SettingsRoute.name, path: '');

//   static const String name = 'SettingsRoute';
// }

// /// generated route for
// /// [_i2.EmptyRouterPage]
// class NewSeedRouterRoute extends _i2.PageRouteInfo<void> {
//   const NewSeedRouterRoute({List<_i2.PageRouteInfo>? children})
//       : super(NewSeedRouterRoute.name,
//             path: 'empty-router-page', initialChildren: children);

//   static const String name = 'NewSeedRouterRoute';
// }

// /// generated route for
// /// [_i15.SeedPhraseExportPage]
// class SeedPhraseExportRoute
//     extends _i2.PageRouteInfo<SeedPhraseExportRouteArgs> {
//   SeedPhraseExportRoute({_i17.Key? key, required List<String> phrase})
//       : super(SeedPhraseExportRoute.name,
//             path: 'seed-phrase-export-page',
//             args: SeedPhraseExportRouteArgs(key: key, phrase: phrase));

//   static const String name = 'SeedPhraseExportRoute';
// }

// class SeedPhraseExportRouteArgs {
//   const SeedPhraseExportRouteArgs({this.key, required this.phrase});

//   final _i17.Key? key;

//   final List<String> phrase;

//   @override
//   String toString() {
//     return 'SeedPhraseExportRouteArgs{key: $key, phrase: $phrase}';
//   }
// }

// /// generated route for
// /// [_i16.AddNewSeedPage]
// class AddNewSeedRoute extends _i2.PageRouteInfo<void> {
//   const AddNewSeedRoute() : super(AddNewSeedRoute.name, path: '');

//   static const String name = 'AddNewSeedRoute';
// }
