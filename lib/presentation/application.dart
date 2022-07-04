import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/biometry_repository.dart';
import '../injection.dart';
import '../providers/key/keys_presence_provider.dart';
import 'bloc/locale_cubit.dart';
import 'common/theme.dart';
import 'router.gr.dart';

class Application extends StatefulWidget {
  const Application({Key? key}) : super(key: key);

  @override
  _ApplicationState createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> with WidgetsBindingObserver {
  final appRouter = AppRouter();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) getIt.get<BiometryRepository>().checkAvailability();
  }

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => getIt.get<LocaleCubit>(),
        child: ProviderScope(
          child: Portal(
            child: ColoredBox(
              color: CrystalColor.background,
              child: Consumer(
                builder: (context, ref, child) {
                  ref.listen<AsyncValue<bool>>(
                    keysPresenceProvider,
                    (previous, next) {
                      next.whenData((value) {
                        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                          if (value) {
                            appRouter.root.pushAndPopUntil(
                              const MainRouterRoute(),
                              predicate: (route) => false,
                            );
                          } else {
                            appRouter.root.pushAndPopUntil(
                              const WizardRouterRoute(),
                              predicate: (route) => false,
                            );
                          }
                        });
                      });
                    },
                  );

                  return child!;
                },
                child: BlocBuilder<LocaleCubit, Locale?>(
                  builder: (context, state) => MaterialApp.router(
                    scrollBehavior: NoGlowBehavior(),
                    debugShowCheckedModeBanner: false,
                    onGenerateTitle: (context) => AppLocalizations.of(context)!.application_title,
                    locale: state,
                    localizationsDelegates: AppLocalizations.localizationsDelegates,
                    supportedLocales: AppLocalizations.supportedLocales,
                    // TODO: change after adding ability to change theme
                    themeMode: ThemeMode.light,
                    theme: materialTheme(context, Brightness.light),
                    darkTheme: materialTheme(context, Brightness.dark),
                    routerDelegate: appRouter.delegate(),
                    routeInformationParser: appRouter.defaultRouteParser(),
                    // TODO: remove CupertinoTheme after rewriting all UI
                    builder: (context, child) => CupertinoTheme(
                      data: cupertinoTheme(context),
                      child: MediaQuery(
                        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                        child: child!,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

const list = {
  'en': LocaleDescription(
    name: 'English',
    icon: 'us',
  ),
  'ko': LocaleDescription(
    name: 'Korean',
    icon: 'kr',
  ),
};

class LocaleDescription {
  final String name;
  final String icon;

  const LocaleDescription({
    required this.name,
    required this.icon,
  });
}

class NoGlowBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) => const BouncingScrollPhysics();
}
