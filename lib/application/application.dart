import 'package:ever_wallet/application/application_injection.dart';
import 'package:ever_wallet/application/application_lifecycle_listener.dart';
import 'package:ever_wallet/application/application_localization.dart';
import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/application/main/app_lifecycle_wrapper.dart';
import 'package:ever_wallet/application/main/browser/browser_page.dart';
import 'package:ever_wallet/application/main/main_screen.dart';
import 'package:ever_wallet/application/onboarding/start_screen/onboarding_screen.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/application/utils.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_portal/flutter_portal.dart';

class AppRouter {
  static String onboarding = 'onboarding';
  static String main = 'main';

  static final Map<String, Route Function(Object?)> routes = {
    AppRouter.onboarding: (_) => MaterialPageRoute(builder: (_) => const BrowserPage()),
    AppRouter.main: (_) => MainScreenRoute(),
  };
}

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) => ApplicationInjection(
        child: ApplicationLifecycleListener(
          builder: () => ApplicationLocalization(
            builder: (locale) => Portal(
              child: Builder(
                builder: (context) {
                  final navigatorKey = context.read<GlobalKey<NavigatorState>>();

                  return AppLifecycleWrapper(
                    child: MaterialApp(
                      navigatorKey: navigatorKey,
                      scrollBehavior: NoGlowBehavior(),
                      debugShowCheckedModeBanner: false,
                      onGenerateTitle: (context) => context.localization.application_title,
                      locale: locale?.toLocale(),
                      localizationsDelegates: AppLocalizations.localizationsDelegates,
                      supportedLocales: AppLocalizations.supportedLocales,
                      themeMode: ThemeMode.light,
                      theme: materialTheme(context, Brightness.light),
                      darkTheme: materialTheme(context, Brightness.dark),
                      // TODO: remove CupertinoTheme after full rewriting
                      builder: (context, child) => CupertinoTheme(
                        data: cupertinoTheme(context),
                        child: MediaQuery(
                          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                          child: child!,
                        ),
                      ),
                      initialRoute: context.read<KeysRepository>().keys.isEmpty
                          ? AppRouter.onboarding
                          : AppRouter.main,
                      onGenerateRoute: (routeSettings) =>
                          AppRouter.routes[routeSettings.name]!(routeSettings.arguments),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
}

class NoGlowBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) => const BouncingScrollPhysics();
}
